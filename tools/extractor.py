#!/usr/bin/env python3
import os
import sys
import re
import pytesseract
from PIL import Image
from argparse import ArgumentParser, RawTextHelpFormatter

def parse_arguments():
    parser = ArgumentParser(description="A tool to extract text from image file or call trace from log file",
                            usage='%(prog)s [OPTIONS]',
                            formatter_class=RawTextHelpFormatter)
    parser.add_argument("-t", dest="type", choices=["text", "calltrace"], required=True,
                        help="the type to be extracted from file.\n" +
                             "text - Extracting text from image file\n" +
                             "calltrace - Extracting call trace from log file")
    parser.add_argument("-f", dest="file", required=True,
                        help='the image or log file path for extracting information')

    args = parser.parse_args()
    return args

def is_valid_file(file_path):
    # Check if the file exists
    return os.path.isfile(file_path)

def is_valid_image(image_path):
    # Check if the file has a valid image extension
    return image_path.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp'))

def remove_empty_lines(text):
    return '\n'.join(line for line in text.split('\n') if line.strip())

def extract_text_from_image(image_path):
    # Open the image file
    img = Image.open(image_path)

    # Use pytesseract to do OCR on the image
    text = pytesseract.image_to_string(img)
    text = remove_empty_lines(text)
    print(text)

def extract_calltrace_from_log(log_path):
    calltrace_stack = []

    with open(log_path, 'r') as log_file:
        log_text = log_file.read()
        # Find 'Call Trace:' lines to get the start and end position of call traces
        ct_matches = re.finditer('Call Trace:', log_text)
        if ct_matches is None:
            return None

        ct_matches = list(ct_matches)
        ct_count = len(ct_matches)
        for ct_index, ct_match in enumerate(ct_matches):
            calltrace_stack.append(ct_match.group(0))
            ct_start = ct_match.end(0)
            if ct_index + 1 < ct_count:
                ct_end = ct_matches[ct_index + 1].start(0)
            else:
                ct_end = len(log_text) 

            stack_matches = re.finditer(r'(?<=] ) ([^\s].*\/.*|<\/?.*>)',
                                        log_text[ct_start:ct_end])
            if stack_matches is None:
                continue
            for stack_match in stack_matches:
                calltrace_stack.append(stack_match.group(0))
    print('\n'.join(calltrace_stack))

if __name__ == "__main__":
    args = parse_arguments()

    try:
        if not is_valid_file(args.file):
            raise FileNotFoundError(f"{args.file} doesn't exist or is not a file.")

        if args.type == 'text':
            if not is_valid_image(args.file):
                raise ValueError(f"{args.file} is not a valid image file")

            # Extract text from the image
            extract_text_from_image(args.file)
        elif args.type == 'calltrace':
            extract_calltrace_from_log(args.file)
    except Exception as e:
        sys.stderr.write(str(e))
        sys.exit(1)
