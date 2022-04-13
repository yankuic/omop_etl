# OHDSI Oncology Extension

The oncology extension scripts included in UFH OMOP etl are based on the OHDSI oncology extension codebase, published by the [Oncology Working Group](https://github.com/OHDSI/OncologyWG).

The sql scripts ingest NAACCR data elements into OMOP 5.3.1 CDM.

Other links:

- [Oncology extension documentation](https://ohdsi.github.io/CommonDataModel/oncology.html#OMOP_Common_Data_Model_Oncology_Extension_Documentation)

## Instructions

Run the scripts after populating tables in dbo schema, before de-identifying and populating hipaa tables.

Steps

1. Run script *create_oncology_schema.sql* to create the etl target tables. If the tables already exists in the database skip this step.
2. Run *process_naaccr_data_poins.sql* to pull the data from the IDR tumor registry.
3. Run script *create_oncology_temp_schema.sql* to create the staging tables required for the etl.
4. Run script *oncology_etl.sql* to extract naaccr data points and ingest into OMOP CDM tables.
5. Run *load_oncology_tables.sql* to move the data from staging into the final target tables.
