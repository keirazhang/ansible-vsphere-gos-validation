#!/usr/bin/env python3
import os
import sys
import pytesseract
from PIL import Image

def is_valid_image_path(image_path):
    # Check if the file exists and has a valid image extension
    return (os.path.isfile(image_path) and 
            image_path.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp')))

def extract_text(image_path):
    try:
        # Open the image file
        img = Image.open(image_path)

        # Use pytesseract to do OCR on the image
        text = pytesseract.image_to_string(img)

        return text
    except Exception as e:
        sys.stderr.write(f"Error: {str(e)}\n")
        return None

def remove_empty_lines(text):
    return '\n'.join(line for line in text.split('\n') if line.strip())

if __name__ == "__main__":
    # Check if an image path is provided as a command-line argument
    if len(sys.argv) != 2:
        sys.stderr.write(f"Usage: {sys.argv[0]} <image_path>")
        sys.exit(1)

    # Get the image path from the command-line argument
    image_path = sys.argv[1]
    if not is_valid_image_path(image_path):
        sys.stderr.write(f"Error: {image_path} is not a valid image path")
        sys.exit(1)

    # Extract text from the image
    extracted_text = extract_text(image_path)
    image_text = remove_empty_lines(extracted_text)

    if image_text:
        sys.stdout.write(image_text)
