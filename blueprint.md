# Project Blueprint: Genealogical Tree Viewer

## Overview

This document outlines the development plan for a Flutter application designed to visualize and maintain genealogical trees. The primary feature is the ability to import, display, and eventually edit data from a GEDCOM (.ged) file.

The application will feature a clean, intuitive, and visually appealing user interface, making it easy for users to navigate and understand their family history. It will be built using modern design principles and will be responsive to work on both mobile and web platforms.

## Project Status: Completed

All planned features for the initial version of the application have been successfully implemented. The application is now functional and allows users to import a GEDCOM file, visualize the family tree, search for individuals, and view their details.

### 1. Initial Application Setup
- **Status:** Done
- **Details:** The basic structure of the Flutter application has been created. It includes a main screen with a title, an introductory text, and a `FloatingActionButton` to trigger the file import process.

### 2. Dependency Integration
- **Status:** Done
- **Details:** The `file_picker` package has been added to handle file selection, and the `gedcom` package has been integrated for parsing GEDCOM data. Both are included in the `pubspec.yaml` file.

### 3. Implement File Import Logic
- **Status:** Done
- **Details:** The `FloatingActionButton` now opens a file picker that filters for `.ged` files. The selected file's content is read as a string.

### 4. Basic Data Verification
- **Status:** Done
- **Details:** The raw content of the imported `.ged` file is displayed on the main screen. The `gedcom` package parses this data, and the application logs the list of individuals and families to the debug console, confirming that the data is being processed correctly.

### 5. Data Modeling
- **Status:** Done
- **Details:** Created `Person` and `Family` classes to represent the core entities of a family tree. These models provide a structured way to handle the data parsed from the GEDCOM file.

### 6. Basic Tree Visualization
- **Status:** Done
- **Details:** 
    - Integrated the `graphview` package to handle the visualization of the tree structure.
    - Created a new screen, `FamilyTreeScreen`, dedicated to displaying the genealogical tree.
    - The view is interactive, allowing for panning and zooming.

### 7. Advanced Tree Logic
- **Status:** Done
- **Details:**
    - Modified the `_buildGraph` method in `FamilyTreeScreen` to use the `_families` data.
    - Implemented logic to connect parents to their children using "family nodes", forming a proper genealogical structure.
    - Handled cases with single-parent families.

### 8. User Interface Enhancements
- **Status:** Done
- **Details:**
    - Implemented pan and zoom functionality for navigating large trees.
    - Added a search bar to find and highlight individuals within the tree.
    - Implemented automatic centering of the view on a searched person.
    - Added a feature to show more details about a person when they are tapped.

### 9. GEDCOM Parser Improvements
- **Status:** Done
- **Details:**
    - The `GedcomParser` has been significantly improved to handle a wider range of GEDCOM formats.
    - It now correctly parses names, whether they are in a single `NAME` tag or split into `GIVN` and `SURN` tags.
    - The parser now recognizes and extracts birth (`BIRT`) and death (`DEAT`) information, including dates and places.
    - The parser now correctly handles media objects (`OBJE`) and extracts image URLs.

### 10. UI/UX Enhancements
- **Status:** Done
- **Details:**
    - The `FamilyTreeScreen` now displays profile pictures for each individual in the tree, loaded from the URLs in the GEDCOM file.
    - The detail dialog for each person now displays their birth and death information.

## Possible Future Enhancements

- **Edit Mode:** Allow users to edit the information of a person or family directly from the application.
- **Add/Remove Individuals:** Implement functionality to add new individuals or remove existing ones from the tree.
- **Export to GEDCOM:** Allow users to export the modified tree back to a GEDCOM file.
- **Different Tree Layouts:** Offer different algorithms for laying out the tree (e.g., radial, layered).
- **Themes:** Allow users to customize the colors and appearance of the tree.
