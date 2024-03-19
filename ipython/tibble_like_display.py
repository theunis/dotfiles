import pandas as pd
import shutil


def truncate_col_name(col_name, max_length):
    """
    Truncate the column name to fit within the maximum length, appending an
    ellipsis if truncated.

    Args:
        col_name (str): The original column name.
        max_length (int): The maximum allowed length of the column name.

    Returns:
        str: The truncated column name with ellipsis if necessary.
    """
    if len(col_name) > max_length:
        return col_name[: max_length - 3] + "..."
    return col_name


def get_short_dtype(dtype):
    """
    Map a Pandas data type to a shorter abbreviation and enclose it in angle
    brackets.

    Args:
        dtype (dtype): The data type to abbreviate.

    Returns:
        str: A concise abbreviation, enclosed in angle brackets.
    """
    type_mapping = {
        "int64": "int",
        "float64": "float",
        "object": "str",
        "bool": "bool",
        "datetime64[ns]": "datetime",
        "timedelta[ns]": "timedelta",
        "category": "category",
    }
    return f"<{type_mapping.get(str(dtype), str(dtype))}>"


def format_column(value, width, dtype, precision=None):
    """
    Format a column value based on its data type, desired width, and precision
    for floats.

    Args:
        value: The value to format.
        width: The desired width.
        dtype: The column's data type.
        precision: The precision for float formatting, if applicable.

    Returns:
        str: The formatted value, aligned appropriately.
    """
    if pd.api.types.is_float_dtype(dtype):
        formatted_value = f"{value:>{width}.{precision}f}"
    elif pd.api.types.is_integer_dtype(dtype):
        formatted_value = f"{value:>{width}d}"
    elif pd.api.types.is_bool_dtype(dtype):
        formatted_value = f"{value}"
    else:
        formatted_value = f"{value}"

    return (
        formatted_value.rjust(width)
        if pd.api.types.is_numeric_dtype(dtype)
        else formatted_value.ljust(width)
    )


def print_tibble_like(df, max_rows=10, max_width=80, min_col_width=10):
    """
    Print a DataFrame in a tibble-like format, truncating column names and
    prioritizing value display.

    Args:
        df (pd.DataFrame): The DataFrame to print.
        max_rows (int): Maximum rows to display.
        max_width (int): Maximum output width.
        min_col_width (int): Minimum width for any column.

    Returns:
        None: This function prints the DataFrame.
    """
    print(f"# A DataFrame: {df.shape[0]} x {df.shape[1]}")

    col_widths = {}
    displayed_cols = []
    truncated_cols = []
    cumulative_width = 0
    float_precision = 2

    # Adjusting and assigning column widths
    for col in df.columns:
        dtype_str = get_short_dtype(df[col].dtype)
        max_value_len = max(
            df[col]
            .apply(
                lambda x: len(
                    f"{x:.{float_precision}f}" if isinstance(x, float) else str(x)
                )
            )
            .max(),
            min_col_width,
        )
        col_width = (
            max(len(col), len(dtype_str) + max_value_len) + 3
        )  # Space for type and padding

        if (
            cumulative_width + min(max_value_len, min_col_width) + len(displayed_cols)
            <= max_width - 3
        ):
            col_widths[col] = (
                min_col_width if min_col_width > max_value_len else max_value_len
            )
            cumulative_width += col_widths[col] + len(displayed_cols)
            displayed_cols.append(col)
        else:
            truncated_cols.append(
                f"{truncate_col_name(col, min_col_width)} <{dtype_str}>"
            )

    # Constructing headers and separators with truncated column names
    header, types_line, separator = "", "", ""
    for col in displayed_cols:
        truncated_name = truncate_col_name(col, col_widths[col])
        header += f"{truncated_name.ljust(col_widths[col])} "
        types_line += f"{get_short_dtype(df[col].dtype).ljust(col_widths[col])} "
        separator += "-" * col_widths[col]

    print(header.rstrip())
    print(types_line.rstrip())
    print(separator.rstrip())

    # Printing row data
    for _, row in df.head(max_rows).iterrows():
        row_str = ""
        for col in displayed_cols:
            formatted = format_column(
                row[col], col_widths[col], df[col].dtype, float_precision
            )
            row_str += f"{formatted} "
        print(row_str.rstrip())

    # Displaying additional rows and columns information
    if len(df) > max_rows:
        print(f"# ... with {len(df) - max_rows} more rows")
    if truncated_cols:
        print("# ... with more variables:", ", ".join(truncated_cols))


def adjust_print(df, max_rows=10, min_col_width=10):
    terminal_width = shutil.get_terminal_size((80, 20)).columns
    print("\n")
    print_tibble_like(
        df, max_rows=max_rows, max_width=terminal_width, min_col_width=min_col_width
    )


# pd.DataFrame._repr_fallback_ = adjust_print

# Test the updated function
# df_test = pd.DataFrame(data_long_names)
# print_tibble_like(df_test, max_width=80, min_col_width=10)
