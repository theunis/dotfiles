#!/usr/bin/env python3
import tkinter as tk
from tkinter import Label, Frame
import subprocess
import yaml
from pathlib import Path

# from loguru import logger
# import logging

# Define the path for the configuration file
config_path = Path.home() / "dotfiles/keycompanion.yaml"


# def setup_logger():
#     # Configure the logging level and format
#     logging.basicConfig(
#         level=logging.DEBUG,
#         format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
#         handlers=[logging.FileHandler("keycompanion.log"), logging.StreamHandler()],
#     )


# Load the configuration
def load_config():
    try:
        with open(config_path, "r") as file:
            return yaml.safe_load(file)
    except FileNotFoundError:
        # logging.error(
        #     f"Configuration file not found at {config_path}. Creating a default config."
        # )
        # Optionally, create a default configuration file here
        return {}
    except yaml.YAMLError as exc:
        # logging.error(f"Error parsing the YAML configuration: {exc}")
        return {}


config = load_config()

# Define colors
colors = {
    "background": "#2E2E39",
    "foreground": "#FFFFFF",
    "menu": "#FFB86C",
    "command": "#8BE9FD",
    "special_key": "#50FA7B",
}


# Main application window
class KeyCompanionApp(tk.Tk):
    def __init__(self, config):
        super().__init__()
        self.config = config.get("menu", {})
        self.path = []
        self.configure(bg=colors["background"])
        self.title("KeyCompanion")
        self.geometry("400x300")
        self.resizable(False, False)
        self.initialize_ui()
        self.bind("<KeyPress>", self.on_key_press)

    def initialize_ui(self):
        # Content frame
        self.content_frame = Frame(self, bg=colors["background"])
        self.content_frame.pack(padx=20, pady=20, expand=True, fill="both")

        # Instructions at the bottom
        instructions = "Back: BackSpace | Exit: Escape"
        self.instructions_label = Label(
            self,
            text=instructions,
            bg=colors["background"],
            fg=colors["special_key"],
            font=("Helvetica", 16),
        )
        self.instructions_label.pack(side="bottom", pady=(0, 10))

        self.update_content()

    def update_content(self):
        """Update the window content based on the current menu."""
        for widget in self.content_frame.winfo_children():
            widget.destroy()

        current_menu = self.config
        for p in self.path:
            current_menu = current_menu[p]["keys"]

        row = 0
        for key, value in current_menu.items():
            color = colors["menu"] if "keys" in value else colors["command"]
            Label(
                self.content_frame,
                text=f"{key}: {value['name']}",
                bg=colors["background"],
                fg=color,
                font=("Helvetica", 18),
            ).grid(row=row, sticky="w")
            row += 1

    def on_key_press(self, event):
        """Handle key press events."""
        char = event.char.lower()
        if event.keysym == "Escape":
            self.destroy()
        elif event.keysym == "BackSpace":
            if self.path:
                self.path.pop()
                self.update_content()
        else:
            current_menu = self.config
            for p in self.path:
                current_menu = current_menu[p]["keys"]
            if char in current_menu:
                if "command" in current_menu[char]:
                    subprocess.run(current_menu[char]["command"], shell=True)
                    self.destroy()
                else:
                    self.path.append(char)
                    self.update_content()


def main():
    # setup_logger()
    app_config = load_config()
    app = KeyCompanionApp(app_config)
    app.mainloop()


if __name__ == "__main__":
    main()
