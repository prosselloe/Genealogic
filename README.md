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

## Crèdits
- Les dades genealògiques han estat obtingudes de [MyHeritage](https://www.myheritage.es/).
- Els escuts heràldics es mostren gràcies a [HeraldicaHispana](https://heraldicahispana.com/).
