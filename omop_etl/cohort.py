"""Generate patient set."""

import sqlparse
import yaml
from omop_etl.datastore import DataStore

# extract queries
# format sql string: fix single quote 
# run queries 
# extract patient set from staged tables. Insert into patientList.

# ALIASES = {
#     'PROVIDR_KEY': {
#         'ALL_PROVIDERS_PT_IND': 'ATTENDING_PROVIDER',
#         'ALL_PROVIDERS_VISIT': 'VISIT_PROVIDER'
#     },
#     'MEASR_VALUE': {
#         'Flowsheet_BP_Value': 'BP',
#         'Flowsheet_BP_NIBP': 'BP_NON_INVASIVE',
#         'Flowsheet_BP_ArtLine': 'ARTERIAL_LINE',
#         'Flowsheet_BP_CVP_MEAN': 'CVP_MEAN',
#         'Flowsheet_BP_NIBP_MEAN': 'BP_NON_INVASIVE_MEAN',
#         'Flowsheet_BP_PAP_MEAN': 'PAP_MEAN',
#         'Flowsheet_HTandWT_Height': 'HEIGHT_INCH',
#         'Flowsheet_RESP_Adult_Mech': 'Adult_Mech_Resp_Rate',
#         'Flowsheet_RESP_DEVICE': 'Respiratory_Device',
#         'Flowsheet_RESP_RESPRATE': 'Respiratory_Rate',
#         'Flowsheet_RESP_MODE_ADULT': 'Adult_Vent_Model',
#         'Flowsheet_RESP_VENT_BGN_A':'AduLt_Vent_Start_Time',
#         'Flowsheet_RESP_VENT_END_A': 'AduLt_Vent_End_Time',
#         'Flowsheet_RESP_MODE_PEDS': 'Peds_Vent_Mode',
#         'Flowsheet_RESP_VENT_BGN_P': 'Peds_Vent_Start_Time',
#         'Flowsheet_RESP_VENT_END_P': 'Peds_Vent_End_Time',
#         'PATNT_ENCNTR_KEY_XREF1': 'Encounter_NumBer_CSN'
#     },
#     'FN_1': {
#         'MEASUREMENT_BP': 'SYSTOLIC',
#         'MEASUREMENT_QTCB': 'ECG_Acq_Date',
#         'MEASUREMENT_Res_ETCO2': 'ETCO2',
#         'MEASUREMENT_Res_FIO2': 'FIO2',
#         'MEASUREMENT_Res_GCS': 'Glasgow_Coma_Peds_Score',
#         'MEASUREMENT_Res_O2': 'O2_Lmin',
#         'MEASUREMENT_Res_PEEP': 'PEEP',
#         'MEASUREMENT_Res_RESP': 'Adult_Spont_Resp_Rate',
#         'MEASUREMENT_Res_SPO2': 'SPO2',
#         'MEASUREMENT_Res_Tidal':'Tidal_Volume'
#     },
#     'FN_2': {
#         'MEASUREMENT_BP': 'DIASTOLIC',
#         'MEASUREMENT_QTCB': 'ECG_Acq_Time',
#         'MEASUREMENT_Res_ETCO2': 'ETCO2_Oral_Nasal',
#         'MEASUREMENT_Res_GCS': 'Glasgow_Coma_Adult_Score',
#         'MEASUREMENT_Res_O2': 'O2_mLmin',
#         'MEASUREMENT_Res_RESP': 'Peds_Mech_Resp_Rate'
#     },
#     'FN_3': {
#         'MEASUREMENT_BP': 'CVP',
#         'MEASUREMENT_Res_RESP': 'Peds_Spont_Resp_Rate'
#     },
#     'FN_4': {
#         'MEASUREMENT_BP': 'MAP_A_LINE'
#     },
#     'FN_5': {
#         'MEASUREMENT_BP': 'MAP_CUFF'
#     }
# }
with open('col_aliases.yml') as f:
    aliases = yaml.safe_load(f) 

def format_bo_sql(sqlstring, table_name, database='DWS_OMOP', schema='cohort'):
    """Insert INTO {table_name} right before first FROM clause."""
    assert len(sqlstring) > 0, 'Empty string passed.'

    parsed = sqlparse.parse(sqlstring)[0]
    idx = [parsed.token_index(t) for t in parsed if t.is_keyword and t.value == 'FROM'][0]
    columns = parsed.token_prev(idx)[1]

    # Extract columns from SELECT clause. If duplicated columns, use alias, 
    # else append abbreviated source table name.
    colnames = [i.value.split('.')[-1] for i in columns]
    dup_cols = set([x for x in colnames if colnames.count(x) > 1])
    new_colnames = []

    counter = 0
    for item in columns:
        if isinstance(item, sqlparse.sql.Identifier):
            colname = item.value.split('.')[-1]
            tabname = item.value.split('.')[-2]
            shrt_tabname = '_'.join([word[:3] for word in tabname.split('_')])
            if colname in dup_cols:
                # search for alias in aliases.
                if colname in ALIASES.keys():
                    try: 
                        item.value = f'{item.value} AS {ALIASES[colname][tabname]}'
                    except:
                         item.value = f'{item.value} AS {shrt_tabname}_{colname}'
                else: 
                    item.value = f'{item.value} AS {shrt_tabname}_{colname}'
            new_colnames.append(item.value)
        
        elif isinstance(item, (sqlparse.sql.Function, sqlparse.sql.Operation)):
            counter += 1
            fn_name = f'FN_{counter}'
            if fn_name in ALIASES.keys():
                try: 
                    item.value = f'{item.value} AS {ALIASES[fn_name][table_name]}'
                except: 
                    item.value = f'{item.value} AS {fn_name}'
            else: 
                item.value = f'{item.value} AS {fn_name}'
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

