import atexit
import json
import os
import subprocess
import sys
from io import StringIO

from IPython import get_ipython


def save_connection_info():
    # Capture the connection info using %connect_info magic and redirect stdout
    ipython = get_ipython()
    old_stdout = sys.stdout
    sys.stdout = mystdout = StringIO()
    ipython.run_line_magic("connect_info", "")
    sys.stdout = old_stdout

    # Parse the connection info JSON from the captured output
    connection_info = mystdout.getvalue()
    connection_info_lines = connection_info.split("\n")[0:12]
    connection_info_json = "\n".join(connection_info_lines)
    connection_info_dict = json.loads(connection_info_json)

    # Extract the key from the connection info
    connection_key = connection_info_dict.get("key")

    # Get the Jupyter runtime directory
    try:
        runtime_dir = (
            subprocess.check_output(["jupyter", "--runtime-dir"]).strip().decode()
        )
    except subprocess.CalledProcessError:
        print("Failed to get Jupyter runtime directory.")
        return

    # Find the connection file that matches the key
    connection_file = None
    for filename in os.listdir(runtime_dir):
        if filename.startswith("kernel-") and filename.endswith(".json"):
            file_path = os.path.join(runtime_dir, filename)
            with open(file_path, "r") as f:
                file_content = json.load(f)
                if file_content.get("key") == connection_key:
                    connection_file = file_path
                    break

    # If no matching file was found, return
    if connection_file is None:
        print("No matching connection file found.")
        return

    # Get the tmux pane ID if available
    try:
        pane_id = (
            subprocess.check_output(["tmux", "display-message", "-p", "#{pane_id}"])
            .strip()
            .decode()
        )
        temp_file = f"/tmp/jupyter_connection_{pane_id}"
    except Exception:
        temp_file = "/tmp/jupyter_connection"

    # Write the connection file path to the temporary file
    with open(temp_file, "w") as f:
        f.write(connection_file)

    # Register a cleanup function to delete the temporary file at exit
    def cleanup():
        try:
            os.remove(temp_file)
            print(f"Temporary connection file {temp_file} deleted.")
        except OSError:
            pass

    atexit.register(cleanup)

    # Print the connection info to the console
    print(f"Connection info: {json.dumps(connection_info_dict, indent=2)}")
    print(f"Connection file written to: {temp_file}")


save_connection_info()
