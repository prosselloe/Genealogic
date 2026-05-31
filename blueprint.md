# Visió General

Aquesta aplicació de genealogia, desenvolupada amb Flutter i desplegada a través de Firebase, permet als usuaris carregar, visualitzar i gestionar els seus arbres genealògics. El seu nucli funcional es basa en la interpretació de fitxers estàndard GEDCOM (com els de MyHeritage), un sistema sofisticat per a la gestió d'imatges (incloent-hi el retall dinàmic), i una eina auxiliar per convertir formats de text personalitzats a GEDCOM.

# Arquitectura i Disseny

L'aplicació utilitza una arquitectura de components a Flutter, amb un disseny basat en Material Design, tipografies de Google Fonts i un enfocament en la responsivitat per adaptar-se a múltiples plataformes.

# Mòduls i Característiques Clau

## 1. Interpretació de Dades GEDCOM (`gedcom_parser.dart`)

Aquest és el mòdul fonamental de l'aplicació. La seva responsabilitat és llegir, interpretar i modelar les dades contingudes en un fitxer d'arbre genealògic en format estàndard GEDCOM 5.5.1. Tota la informació que es mostra a les pantalles (individus, famílies, esdeveniments, fotos) prové de les estructures de dades que aquest intèrpret genera.

*   **Procés de Lectura:** El parser llegeix el fitxer GEDCOM línia per línia, identificant nivells, etiquetes (tags) i valors.
*   **Modelat de Dades:** Transforma les dades del fitxer en una col·lecció d'objectes Dart fortament tipats, principalment:
    *   `Individual`: Representa una persona, amb els seus atributs (nom, sexe), esdeveniments (naixement, defunció) i enllaços a famílies.
    *   `Family`: Representa un nucli familiar, vinculant marit, muller i fills.
    *   `Photo`: Representa una imatge, amb la seva URL, títol i altres metadades.
    *   Altres objectes per a notes, fonts, etc.
*   **Vinculació de Dades:** Un cop llegides totes les entitats, el parser resol les referències creuades (p. ex., vincula un fill a la seva família, una família als seus cònjuges) per construir l'arbre relacional complet.

## 2. Gestió Avançada d'Imatges

El sistema de gestió d'imatges és una altra característica complexa, el desenvolupament de la qual està àmpliament documentat a `assets/data/myheritage.txt`.

*   **Càrrega Dual:** Per a cada imatge, el sistema primer intenta carregar-la des de la URL proporcionada al fitxer GEDCOM. Si falla, recorre a una còpia de seguretat local a `assets/images`, el nom de la qual es construeix a partir del títol (`TITL`) i format (`FORM`) del GEDCOM.
*   **Imatges Personals Retallades:** Aquesta funcionalitat, específica per a dades de MyHeritage, permet generar fotos de perfil dinàmicament.
    *   **Identificació i Vinculació:** Una foto personal (`_PERSONALPHOTO Y`) es vincula a una foto principal mitjançant les etiquetes `_PARENTRIN` i `_PHOTO_RIN`.
    *   **Retall:** Les coordenades de retall s'extreuen de l'etiqueta `_POSITION` de la foto principal i s'apliquen per generar la imatge de perfil.

## 3. Eina Auxiliar: Transformador de Text a GEDCOM (`gedcom_transformer.dart`)

Aquest mòdul actua com una eina de conversió per a un format de text no estàndard, basat en notes de reconstrucció de famílies. La seva lògica es deriva de les especificacions documentades a `assets/data/felanitx.txt`.

*   **Objectiu:** Convertir aquest format de text específic al format GEDCOM estàndard, perquè pugui ser processat posteriorment pel `gedcom_parser.dart` principal.
*   **Funcionalitat:** Interpreta la sintaxi de llinatges, patriarques, matrimonis (`*`), fills (`-`) i abreviatures (`T.`, `+`, `vdo.`) per generar un fitxer `.ged` vàlid.

# Historial de Desenvolupament i Reptes Superats

El desenvolupament ha estat un procés iteratiu guiat per la filosofia de treballar com un "enginyer", basant-se en l'anàlisi de dades concretes.

*   **Depuració del Retall d'Imatges:** Aconseguir el funcionament correcte del retall dinàmic d'imatges va ser el repte més llarg i complex, documentat a `myheritage.txt`.
*   **Desenvolupament del Transformador:** La creació del `gedcom_transformer.dart` va requerir desenes d'iteracions per gestionar les particularitats del format de text personalitzat, com es recull a `felanitx.txt`.
*   **Optimització i Consistència:** Es van dedicar esforços significatius a optimitzar el rendiment de la càrrega d'imatges i a garantir una lògica de presentació coherent a tota l'aplicació.
