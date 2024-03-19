from IPython.core.magic import register_line_magic
from IPython import get_ipython
import pandas as pd
import visidata

from tibble_like_display import adjust_print

# Assuming adjust_print is correctly defined.

# Retrieve the current plain text formatter for pandas DataFrame.
plain = get_ipython().display_formatter.formatters["text/plain"]

# Storing the original formatter for later use
if not hasattr(pd.DataFrame, "_original_formatter"):
    pd.DataFrame._original_formatter = plain.for_type(pd.DataFrame)


@register_line_magic
def set_df_display(line):
    """
    A line magic command to change the DataFrame display mode in IPython.

    Usage:
        %set_df_display visidata - Displays DataFrames using VisiData.
        %set_df_display tibble   - Displays DataFrames in a tibble-like format.
        %set_df_display default  - Resets to the default pandas DataFrame display.

    Args:
        line (str): The display mode ('visidata', 'tibble', or 'default').
    """
    if line == "visidata":
        # Define a function for VisiData display that accepts the correct number of arguments
        def visidata_display(df, include=None, exclude=None):
            visidata.vd.view_pandas(df)

        plain.for_type(pd.DataFrame, visidata_display)
    elif line == "tibble":
        # Define a function for the tibble-like display that accepts the correct number of arguments
        def tibble_display(df, include=None, exclude=None):
            adjust_print(df)

        plain.for_type(pd.DataFrame, tibble_display)
    elif line == "default":
        plain.for_type(
            pd.DataFrame, lambda df, _, __: print(f"\n{df.to_string()}")
        )  # Restore the original formatter


del set_df_display
