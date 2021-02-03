"""Generate patient set."""

import sqlparse
from omop_etl.datastore import DataStore

# extract queries
# format sql string: fix single quote 
# run queries 
# extract patient set from staged tables. Insert into patientList.

def format_cohort_sql(sqlstring, table_name, database='DWS_OMOP', schema='cohort'):
    """Insert INTO {table_name} right before first FROM clause."""
    assert len(sqlstring) > 0, 'Empty string passed.'

    parsed = sqlparse.parse(sqlstring)[0]
    idx = [parsed.token_index(t) for t in parsed if t.is_keyword and t.value == 'FROM'][0]
    columns = parsed.token_prev(idx)[1]

    # Extract columns from SELECT clause. Append INTO clause.
    # If duplicated columns, append abbreviated source table name.
    colnames = [i.value.split('.')[-1] for i in columns]
    dup_cols = set([x for x in colnames if colnames.count(x) > 1])
    new_colnames = []

    for item in columns:
        if isinstance(item, sqlparse.sql.Identifier):
            colname = item.value.split('.')[-1]
            tabname = item.value.split('.')[-2]
            tabname = '_'.join([word[:3] for word in tabname.split('_')])
            if colname in dup_cols:
                item.value = f'{item.value} AS {tabname}_{colname}'
            new_colnames.append(item.value)

    colnames_str = ', '.join(new_colnames)
    into_str = f'{colnames_str} INTO {database}.{schema}.{table_name} '

    # Replace string with INTO clause and new column names.
    columns.value = into_str
    sqlstring = f'DROP TABLE IF EXISTS {database}.{schema}.{table_name}; ' + ''.join([t.value for t in parsed])
    
    return sqlstring.replace("'", "''")

def format_insert_sql(table_list):
    """[summary]."""
    union_str = 'union '.join([f'select patnt_key from cohort.{t} ' for t in table_list])

    q = """
        INSERT INTO cohort.PersonList WITH (TABLOCK)
        SELECT DISTINCT *
        FROM (
            {}
        ) x
    """.format(union_str)

    return q

