#!/usr/bin/env python3
import argparse
import csv
import datetime as dt

import requests


def add_cards_to_deck(csv_file, deck_name):
    # URL for AnkiConnect
    anki_connect_url = "http://localhost:8765"

    today_date_str = dt.datetime.now().strftime("%Y%m%d")
    # Read the CSV file and create notes (cards)
    notes = []
    with open(csv_file, "r") as file:
        reader = csv.reader(file)
        for row in reader:
            note = {
                "deckName": deck_name,
                "modelName": "Migaku Chinese Simplified (my version)",
                "fields": {"Sentence": row[0], "Translation": row[1]},
                "options": {"allowDuplicate": False},
                "tags": [f"cli_{today_date_str}"],
            }
            notes.append(note)

    # Prepare the request payload
    payload = {"action": "addNotes", "version": 6, "params": {"notes": notes}}

    # Send the request to AnkiConnect
    response = requests.post(anki_connect_url, json=payload)
    if response.status_code == 200:
        print("Cards added successfully!")
    else:
        print(f"Error adding cards: {response.text}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Import CSV into an existing Anki deck."
    )
    parser.add_argument("csv_file", type=str, help="Path to the CSV file to import")
    parser.add_argument("deck_name", type=str, help="Name of the existing Anki deck")

    args = parser.parse_args()
    add_cards_to_deck(args.csv_file, args.deck_name)
