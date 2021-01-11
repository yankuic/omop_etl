"""."""

from omop_etl.datastore import DataStore

store = DataStore('omop')

store.create_schema('xref')
store.create_schema('cohort')
store.create_schema('stage')
store.create_schema('preload')
store.create_schema('archive')
