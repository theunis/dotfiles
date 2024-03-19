from IPython.core.magic import register_line_magic
import duckdb
import pandas as pd


@register_line_magic
def to_duckdb(line):
    """
    Writes a pandas DataFrame to a DuckDB database table.

    This line magic command allows you to persist a DataFrame in a DuckDB database
    for later use, either in the same session or in a different context.

    Usage:
        %to_duckdb data_frame_variable [table_name] [database_file_name]

    Parameters:
        data_frame_variable (str): The name of the DataFrame variable to write.
        table_name (str, optional): The name of the table to create or overwrite.
                                    Defaults to 'default_table'.
        database_file_name (str, optional): The DuckDB database file name.
                                             Defaults to 'default.duckdb'.

    Examples:
        %to_duckdb df
        %to_duckdb df my_table
        %to_duckdb df my_table my_database.duckdb

    Note:
        If the table already exists, it will be overwritten with the new data.
    """
    args = line.split()
    if len(args) == 0:
        raise ValueError(
            "You must provide at least a variable name pointing to a DataFrame."
        )

    # Extracting arguments
    variable_name = args[0]
    table_name = args[1] if len(args) > 1 else "default_table"
    db_file_name = args[2] if len(args) > 2 else "default.duckdb"

    # Fetching the DataFrame from the user's namespace
    df = get_ipython().user_ns.get(variable_name)
    if df is None or not isinstance(df, pd.DataFrame):
        raise ValueError(f"{variable_name} is not a valid DataFrame.")

    # Writing the DataFrame to the DuckDB database
    con = duckdb.connect(db_file_name)
    con.register("df", df)
    con.execute(f"CREATE OR REPLACE TABLE {table_name} AS SELECT * FROM df")
    con.unregister("df")
    con.close()
    print(
        f"DataFrame '{variable_name}' has been written to table '{table_name}'"
        f"in '{db_file_name}'."
    )


# To test or use, ensure you have a DataFrame 'df' in scope and execute:
# %to_duckdb df
