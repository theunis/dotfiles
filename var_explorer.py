import argparse

from jupyter_client.manager import KernelManager

arg_parser = argparse.ArgumentParser()
arg_parser.add_argument(
    "--connection_file", type=str, required=True, help="Path to the connection file"
)
args = arg_parser.parse_args()
connection_file_path = args.connection_file


def connect_to_kernel(connection_file):
    km = KernelManager(connection_file=connection_file)
    km.load_connection_file()
    shell = km.client()
    return shell


def execute_code(shell, code):
    msg_id = shell.execute(code)
    while True:
        msg = shell.get_iopub_msg()
        if msg["parent_header"].get("msg_id") == msg_id:
            if msg["msg_type"] == "execute_result":
                result = msg["content"]["data"]["text/plain"]
                return result
            elif msg["msg_type"] == "error":
                raise RuntimeError(
                    "Error executing code: %s" % msg["content"]["evalue"]
                )


code = """
import json, sys
def get_var_details():
    details = []
    for name, obj in globals().items():
        if not name.startswith('_') and name != 'get_var_details' and name != 'json' and name != 'sys':
            try:
                size = str(sys.getsizeof(obj))
                # Safely get a string representation of the object
                content = repr(obj)[:50] + '...' if len(repr(obj)) > 50 else repr(obj)
            except:
                size = 'Error'
                content = 'Unrepresentable object'
            details.append({'varName': name, 'varType': type(obj).__name__, 'varSize': size, 'varContent': content})
    return json.dumps(details)

get_var_details()
"""

shell = connect_to_kernel(connection_file_path)
var_info = execute_code(shell, code)
var_info = (
    var_info.strip("'").replace("\\\\", "@@").replace("\\", "").replace("@@", "\\")
)

print(var_info)
