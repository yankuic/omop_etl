"""Refresh patient cohort list.

This template script to generate the project cohort list. Some customizations may be needed to make it work for each project. 

Usage:
 
Add instructions here. 
"""

from omop_etl.utils import timeitc
from omop_etl.datastore import DataStore 
from omop_etl.bo import bo_query, format_bo_sql

store = DataStore('config.yml')
BO_DOCNAME = store.config.bo_docname_cohort
END_DATE = store.config.end_date
DATABASE = store.config.project_database
SCHEMA = 'cohort'
COHORT_TABLE = 'PersonList'

# Use this list to add things to replace (placeholders) in the original BO query.
# Add pairs as (old_value, new_value)
replace_placeholders = [
    ('12/31/1900 00:0:0', END_DATE)
]

def load_cohort_query(dp_names, cohort_table, schema):
    """Return query string to load cohort into schema.cohort_table."""
    if hasattr(dp_names, '__iter__'):
        union_str = 'union '.join([f'select patnt_key from {SCHEMA}.{t} ' for t in dp_names])
    elif isinstance(dp_names, str):
        union_str = f'select patnt_key from {SCHEMA}.{dp_names}'
    else:
        raise TypeError

    return f"""
        INSERT INTO {schema}.{cohort_table} WITH (TABLOCK)
        SELECT DISTINCT *
        FROM (
            {union_str}
        ) x
    """

def refresh_cohort(stage=True, replace_placeholders=None):
    """[summary]

    Returns:
        [type]: [description]
    """
    store.truncate(SCHEMA, COHORT_TABLE)

    with store.engine.connect() as con:
        bo_q = bo_query(BO_DOCNAME, con)
    
    # Stage all cohort tables
    if stage:
        for t in bo_q.keys():
            q = bo_q[t]
            sqlstring = format_bo_sql(q, t, DATABASE)

            # Replace placeholders
            if replace_placeholders: 
                for item in replace_placeholders:
                    old, new = item
                    sqlstring = sqlstring.replace(old, new)

            print(f'Staging {t} ...')
            print(store.execute(f"EXECUTE ('USE DWS_PROD;\n {sqlstring}')"))

    print(f'Loading cohort into {COHORT_TABLE} ...')
    cohort_q = load_cohort_query(bo_q.keys(), COHORT_TABLE, SCHEMA)
    
    return store.execute(cohort_q)

if __name__ == '__main__':
    with timeitc('Refreshing cohort table '):
        refresh_cohort(replace_placeholders=replace_placeholders)
