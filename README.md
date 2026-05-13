# Genealogic

Una aplicació de Flutter dissenyada per analitzar, visualitzar i navegar per dades genealògiques d'un fitxer GEDCOM.

## Característiques

Aquesta aplicació permet als usuaris explorar la seva història familiar a través d'una interfície intuïtiva.

### 1. Anàlisi de dades GEDCOM
- L'aplicació llegeix i analitza dades d'un fitxer GEDCOM (`.ged`) ubicat als assets del projecte (`assets/data/myheritage.ged`).
- Processa individus i famílies i els emmagatzema en mapes estructurats per a un accés fàcil. Els noms de les famílies es generen automàticament a partir dels cognoms dels cònjuges.

### 2. Llista de famílies principals (`Arbres familiars`)
- Per motius de rendiment amb grans conjunts de dades, la pantalla principal presenta una llista clara i eficient de totes les famílies completes (aquelles amb cònjuges registrats).
- En tocar qualsevol família d'aquesta llista, s'accedeix a la vista interactiva de Relacions familiars per a aquesta família específica.

### 3. Vista interactiva de relacions familiars
- Una visualització de gràfics dinàmica i interactiva per explorar les relacions immediates d'una família seleccionada (pares i fills).
- Construït amb el paquet `graphview`, que permet als usuaris desplaçar-se i fer zoom.
- **Navegació intuïtiva**:
    - Fent clic a una persona, es navega a la pantalla de detalls de la persona.
    - Fent clic a la icona de la família, es navega a la pantalla de detalls de la família.

### 4. Detalls de la persona
- Mostra informació detallada sobre un individu, incloent:
    - Nom, sexe i dates/llocs de naixement i mort.
    - Una llista de fotos associades, que es poden veure a pantalla completa.
    - Un botó per veure la seva posició en l'arbre genealògic.

### 5. Detalls de la família
- Mostra informació sobre la família, incloent:
    - Noms dels cònjuges i data/lloc del matrimoni.
    - Una llista de fills.

### 6. Mapa d'esdeveniments
- Visualitza en un mapa els llocs de naixement, matrimoni i defunció.
- Els marcadors del mapa mostren els esdeveniments que van tenir lloc en cada ubicació.

### 7. Escut heràldic
- Mostra un escut heràldic basat en el cognom de la família.

<table class="MsoNormalTable" style="width: 443.4pt; margin-left: 2.75pt; border-collapse: collapse;" border="0" width="591" cellspacing="0" cellpadding="0">
<tbody>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Alberti.png" /></td>
<td style="width: 145.5pt; border: solid windowtext 1.0pt; border-left: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Ballester.png" /></td>
<td style="width: 149.35pt; border: solid windowtext 1.0pt; border-left: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Bautista.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Beltran.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Bestard.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Blanco.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Bonet.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Borras.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Brunet.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Bueno.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Cabello.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Calvente.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Capella.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Capo.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Carbonell.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Cardona.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Carmona.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Castella.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Castro.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Cerda.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Colom.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Costa.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Diaz.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Espasa.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Ferra.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Ferrer.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Gabaldon.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Galiana.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Garcia.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Gomez.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Gonzalez.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Juan.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Leon.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Llagostera.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Llorca.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Llorente.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Macias.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Mari.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Marques.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Marti.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Martin.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Martinez.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Mas.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Mendez.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Mesquida.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Mir.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Molina.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Monserrat.png" /></td>
</tr>
<tr style="height: 90.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Moreno.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Morey.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 90.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Nebot.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Oliva.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Oliver.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Orfila.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Ortega.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Ortiz.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Palma.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Palmer.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Perello.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Perez.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Plaza.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Pol.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Prats.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Puerto.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Pujol.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Ramirez.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Ramos.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Riera.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Roca.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Roig.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Romero.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Rosello2.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Robi3.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Ruiz.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Sabater.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Salom.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Sanchez.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Sanchis.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Sastre.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Serra.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Suarez.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Sureda.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Tomas.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Torres.png" /></td>
</tr>
<tr style="height: 75.75pt;">
<td style="width: 148.55pt; border: solid windowtext 1.0pt; border-top: none; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="198"><img src="https://heraldicahispana.com/images/png/Tous.png" /></td>
<td style="width: 145.5pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="194"><img src="https://heraldicahispana.com/images/png/Vicens.png" /></td>
<td style="width: 149.35pt; border-top: none; border-left: none; border-bottom: solid windowtext 1.0pt; border-right: solid windowtext 1.0pt; padding: 0cm 3.5pt 0cm 3.5pt; height: 75.75pt;" width="199"><img src="https://heraldicahispana.com/images/png/Vidal.png" /> /></td>
</tr>
</tbody>
</table>

## Crèdits
- Les dades genealògiques han estat obtingudes de [MyHeritage](https://www.myheritage.es/).
- Els escuts heràldics es mostren gràcies a [HeraldicaHispana](https://heraldicahispana.com/).
