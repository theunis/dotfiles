from IPython.core.magic import register_line_magic
import pandas as pd
import os


@register_line_magic
def to_feather(line):
    """
    Writes a pandas DataFrame to the specified folder in Feather format.

    Usage:
        %to_feather data_frame_variable [file_name] [folder_path]

    Parameters:
        data_frame_variable (str): The name of the DataFrame variable to write.
        file_name (str, optional): The name of the Feather file. If not provided, defaults to the DataFrame variable name.
        folder_path (str, optional): The path to the folder where the Feather file should be saved. Defaults to the current directory.

    Examples:
        %to_feather df
        %to_feather df my_data.feather
        %to_feather df my_data.feather /path/to/folder
    """
    args = line.split()
    if len(args) == 0:
        raise ValueError("You must provide at least a DataFrame variable name.")

    variable_name = args[0]
    file_name = (
        args[1]
        if len(args) > 1 and not args[1].startswith("/")
        else f"{variable_name}.feather"
    )
    folder_path = (
        args[-1] if len(args) > 1 and args[-1].startswith("/") else "feather_data"
    )

    df = get_ipython().user_ns.get(variable_name)
    if df is None or not isinstance(df, pd.DataFrame):
        raise ValueError(f"{variable_name} is not a valid DataFrame.")

    # Ensure the folder exists
    os.makedirs(folder_path, exist_ok=True)

    # Construct the full file path
    file_path = os.path.join(folder_path, file_name)

    # Write the DataFrame to Feather format
    df.reset_index().to_feather(file_path)
    print(
        f"DataFrame '{variable_name}' has been written to '{file_path}' in Feather format."
    )
