"""."""

from omop_etl import store, execute, read_sql

store.create_schema('xref')
store.create_schema('cohort')
store.create_schema('stage')
store.create_schema('preload')
store.create_schema('archive')

if not store.object_exists('FN','udf_extract_numbers'):
    q = read_sql('sql/create_udf_extract_numbers.sql')
    execute(q, store.engine)
