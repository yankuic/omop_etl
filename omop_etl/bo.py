"""Format BO generated queries."""
import sqlparse
from sqlparse.sql import Identifier, Function, Operation, Case

from omop_etl.utils import search

def bo_query(doc_name, con): 
    """Retrieve query from BO.
    
    Arguments:
        doc_name {str} -- BO document name.
        
    """
    sql_metadata = """
        SELECT DISTINCT DP_NAME, SQL_QUERY
        FROM DWS_METADATA.dbo.MD_MGMT_WEBI_DATA_PRVDRS
        WHERE DOC_ID in (
            SELECT DOC_ID
            FROM DWS_METADATA.dbo.MD_MGMT_WEBI_DOCS 
            WHERE DOC_NAME = '{}' and FOLDER_PATH like 'Public Folders%'
        )
    """.format(doc_name)

    result = con.execute(sql_metadata).fetchall()
    return dict(result)


def format_stage_query(doc_name:str, dp_name:str, start_date:str, end_date:str, con:object, loinc_list:list='', schema:str='stage', aliases:list=None):
    """Format stage query."""
    bo_q = bo_query(doc_name, con)[dp_name]
    db = con.engine.url.database
    personlist = f"select PATIENT_KEY from {db}.cohort.PersonList"

    if dp_name.lower() == 'measurement_lab':
        loinc_str = ','.join([f"''{l}''" for l in loinc_list])
    else:
        loinc_str = ''

    sql_query = format_bo_sql(bo_q, dp_name, database=db, schema=schema, aliases=aliases)\
                .replace("12345678", personlist)\
                .replace("01/01/1900 00:0:0", start_date)\
                .replace("12/31/1900 00:0:0", end_date)\
                .replace("''LOINCLIST''", loinc_str)

    return f"EXECUTE ('USE DWS_PROD;\n {sqlparse.format(sql_query, reindent_aligned=True, indent_with=1)}')" 


def format_bo_sql(sqlstring:str, dp_name:str, database:str, schema:str='cohort', aliases:list=None):
    """Refactor BO Query to insert data into a new table on the fly."""
    assert len(sqlstring) > 0, 'Empty string passed.'

    def flatten(lst):
        for el in lst:
            if isinstance(el, list):  
                # recurse
                yield from flatten(el)
            else:
                # generate
                yield el

    def get_function(item):
        if isinstance(item, (sqlparse.sql.Parenthesis, sqlparse.sql.Operation)):
            return list(filter(None, [get_function(i) for i in item]))
        elif isinstance(item, sqlparse.sql.Function):
            return item

    def replace_cast_with_try_convert(parsed):    
        for token in parsed.tokens:
            if isinstance(token, (sqlparse.sql.IdentifierList, sqlparse.sql.Where)):
                items = [item for item in token if search('cast', item.value)]

                for item in items:
                    if isinstance(item, sqlparse.sql.Function):
                        fun_list = flatten([get_function(item)])
                        # print(fun_list)

                    else:
                        fun_list = flatten(list(filter(None, [get_function(i) for i in item])))
                        # print(fun_list)

                    for fun in fun_list:
                        col, dtype = flatten([[i.value.split(' as ') for i in p if isinstance(i, sqlparse.sql.Identifier)] 
                                                for p in fun if isinstance(p, sqlparse.sql.Parenthesis)][0])
                        # print(fun)
                        item.value = item.value.replace(fun.value, f'try_convert({dtype},{col})')

                token.value = ''.join(item.value for item in token)

    parsed = sqlparse.parse(sqlstring)[0]
    # Replace cast to avoid overflow errors. try_convert will return null if conversion of data types fails. 
    replace_cast_with_try_convert(parsed)

    # Extract columns from SELECT clause and add aliases to avoid insert error due to missing col names.
    idx = [parsed.token_index(t) for t in parsed if t.is_keyword and t.value == 'FROM'][0]
    columns = parsed.token_prev(idx)[1]
    colnames = [i.value.split('.')[-1] for i in columns]
    dup_cols = set([x for x in colnames if colnames.count(x) > 1])
    new_colnames = []

    if aliases:
        col_items = [item for item in columns if isinstance(item, (Identifier, Function, Operation, Case))]
        assert len(col_items) == len(aliases), 'Number of columns in query does not match number of aliases passed.'
        new_colnames = [f'{item.value} AS {alias}' for item,alias in zip (col_items, aliases)]

    else:
        counter = 0
        for item in columns:
            if isinstance(item, Identifier):
                colname = item.value.split('.')[-1]
                tabname = item.value.split('.')[-2]
                shrt_tabname = '_'.join([word[:3] for word in tabname.split('_')])
                if colname in dup_cols:
                    item.value = f'{item.value} AS {shrt_tabname}_{colname}'
                new_colnames.append(item.value)
            
            elif isinstance(item, (Function, Operation, Case)):
                counter += 1
                fn_name = f'FN_{counter}'
                item.value = f'{item.value} AS {fn_name}'
                new_colnames.append(item.value)

    colnames_str = ', '.join(new_colnames)
    into_str = f'{colnames_str} INTO {database}.{schema}.{dp_name} '

    # Replace string with INTO clause and new column names.
    columns.value = into_str
    sqlstring = f'DROP TABLE IF EXISTS {database}.{schema}.{dp_name}; ' + ''.join([t.value for t in parsed])
    
    return sqlstring.replace("'", "''")
