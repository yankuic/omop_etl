# CHANGELOG
All notable changes to this project will be documented in this file.

## [1.3.0] - 2022-07-29
### Added
* visit_detail table to handle non-primary encounters within a hospital account

### Changed
* visit_occurrence table contains only primary encounter for each hospital account. There are still issues with a small number of hospital accounts that do not have a primary encounter.

### Removed
* None

## [1.2.0] - 2022-07-05
### Added
* bmi
* lvef
* several LOINC codes for COVID and COVID/FLU labs

### Changed
* load 5-digits zipcode instead of 3-digits
* edit BO query for meds to exclude cancelled orders
* improve algorithm for the encounter type
* update several concept_id values
* remove mapping to deidentified number for providers with provider key < 0, i.e., unknown provider
* replace dates in distant future in drug_exposure file with 2022-01-01
* fix missing values in observation table, which were the result of moving data from other tables to observation table
* replace NULL with 0 in all concept_id columns

### Removed
* None

## [1.1.0] - 2022-05-05

### Added
* ontology extension
* export data to .txt files

### Changes
* fixed bugs

### Removed
None

## [1.0.0] - 2020-01-03
This is the initial release.

### Added
None

### Changed
None

### Removed
None
