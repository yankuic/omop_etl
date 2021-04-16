"""Generate patient set."""

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

   