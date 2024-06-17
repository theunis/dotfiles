#!/usr/bin/env python3
import csv
import re


def main(sentences_csv_location: str, terms_location: str):
    """For a csv importable into Anki, check if there are any terms not yet
    included in the sentences. If there are terms not included, it will list
    these."""

    sentences = []
    with open(sentences_csv_location, newline="", encoding="utf-8") as csvfile:
        csvreader = csv.reader(csvfile)
        next(csvreader)  # Skip header
        for row in csvreader:
            sentences.append(
                {"sentence": remove_annotations(row[0]), "definitions": row[1]}
            )

    with open(terms_location, "r", encoding="utf-8") as file:
        terms = [line.strip() for line in file]

    remaining_terms = [
        term for term in terms if not term_in_any_sentence(term, sentences)
    ]

    if len(remaining_terms) == 0:
        print("No more terms remaining!")
    else:
        print("Still the following terms remaining:")
        for term in remaining_terms:
            print(term)


def remove_annotations(text: str) -> str:
    """
    Removes annotations in the form of [pinyin] from the provided text.

    Args:
        text (str): The input text containing annotations.

    Returns:
        str: The cleaned text with annotations removed.
    """
    # Regular expression to find and remove all [text] parts
    cleaned_text = re.sub(r"\[[^\]]+\]", "", text)
    return cleaned_text


# Function to check if a term is in any sentence in the list of sentences
def term_in_any_sentence(term, sentences):
    return any(term in sentence["sentence"] for sentence in sentences)


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 3:
        print("Usage: python script.py <sentences_csv_location> <terms_location>")
        sys.exit(1)

    sentences_csv_location = sys.argv[1]
    terms_location = sys.argv[2]
    main(sentences_csv_location, terms_location)
