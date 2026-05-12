import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class HeraldicShieldWidget extends StatefulWidget {
  final String surname;
  final double size;

  const HeraldicShieldWidget({
    super.key,
    required this.surname,
    this.size = 60.0,
  });

  @override
  State<HeraldicShieldWidget> createState() => _HeraldicShieldWidgetState();
}

class _HeraldicShieldWidgetState extends State<HeraldicShieldWidget> {
  static final Map<String, String?> _shieldUrlCache = {};
  late Future<String?> _shieldUrlFuture;

  @override
  void initState() {
    super.initState();
    _shieldUrlFuture = _fetchShieldUrl();
  }

  @override
  void didUpdateWidget(covariant HeraldicShieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.surname != oldWidget.surname) {
      setState(() {
        _shieldUrlFuture = _fetchShieldUrl();
      });
    }
  }

  Future<String?> _fetchShieldUrl() async {
    if (widget.surname.isEmpty) {
      return null;
    }

    if (_shieldUrlCache.containsKey(widget.surname)) {
      return _shieldUrlCache[widget.surname];
    }

    final normalized = widget.surname
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'[áàâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ç', 'c');

    final searchUrl = 'https://heraldicahispana.com/escudos?var=$normalized';

    try {
      final response = await http.get(Uri.parse(searchUrl));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final imageElement = document.querySelector('img[title="ABRIR SIN LAMBREQUINES"]');

        if (imageElement != null) {
          final relativeUrl = imageElement.attributes['src'];
          if (relativeUrl != null) {
            final absoluteUrl = Uri.parse(searchUrl).resolve(relativeUrl).toString();
            final headResponse = await http.head(Uri.parse(absoluteUrl));
            if (headResponse.statusCode == 200) {
              _shieldUrlCache[widget.surname] = absoluteUrl;
              return absoluteUrl;
            }
          }
        }
      }
    } catch (e, s) {
      developer.log(
        'Error fetching shield image for ${widget.surname}',
        name: 'HeraldicShieldWidget',
        error: e,
        stackTrace: s,
      );
    }

    _shieldUrlCache[widget.surname] = null;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _shieldUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(widget.size * 0.2),
                child: const CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(snapshot.data!),
                fit: BoxFit.contain,
              ),
            ),
          );
        }

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.shield_outlined,
            color: Colors.grey[400],
            size: widget.size * 0.6,
          ),
        );
      },
    );
  }
}
