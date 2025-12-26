#!/usr/bin/env python3
"""
Generate app icon for Simplistic Calculator
Creates a 1024x1024px icon with mathematical operators aligned to the right
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Constants
SIZE = 1024
BG_COLOR = "#F5F5F5"  # Light gray
OPERATOR_COLOR = "#6B4423"  # Brown
PADDING_RIGHT = 180  # Padding from right edge
PADDING_VERTICAL = 220  # Padding from top and bottom
FONT_SIZE = 240  # Operator size for good visibility

# Operators with proper Unicode characters
OPERATORS = [
    '+',      # Plus sign
    '\u2212', # Minus sign (U+2212)
    '\u00D7', # Multiplication sign (U+00D7)
    '\u00F7'  # Division sign (U+00F7)
]

def create_icon():
    """Create the app icon with operators"""
    # Create image with light gray background
    img = Image.new('RGB', (SIZE, SIZE), BG_COLOR)
    draw = ImageDraw.Draw(img)

    # Try to load Arial Bold, fall back to default if not available
    font = None
    font_paths = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/Library/Fonts/Arial Bold.ttf",
        "/System/Library/Fonts/Arial.ttf"
    ]

    for font_path in font_paths:
        try:
            font = ImageFont.truetype(font_path, FONT_SIZE)
            print(f"Using font: {font_path}")
            break
        except:
            continue

    if font is None:
        print("Warning: Could not load Arial Bold, using default font")
        font = ImageFont.load_default()

    # Calculate vertical positions for operators
    # Total vertical space for operators
    vertical_space = SIZE - (2 * PADDING_VERTICAL)

    # Space between operator centers
    spacing = vertical_space / (len(OPERATORS) - 1)

    # Draw each operator
    for i, operator in enumerate(OPERATORS):
        # Calculate vertical position (centered in each section)
        y_center = PADDING_VERTICAL + (i * spacing)

        # Get text bounding box to calculate dimensions
        bbox = draw.textbbox((0, 0), operator, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]

        # Calculate x position (right-aligned with padding)
        x_position = SIZE - PADDING_RIGHT - text_width

        # Calculate y position (vertically centered)
        y_position = y_center - (text_height / 2)

        # Draw the operator
        draw.text((x_position, y_position), operator, fill=OPERATOR_COLOR, font=font)

        print(f"Drew '{operator}' at position ({x_position:.0f}, {y_position:.0f})")

    # Save the icon
    output_path = os.path.join(
        os.path.dirname(os.path.dirname(__file__)),
        'assets',
        'icon.png'
    )

    img.save(output_path, 'PNG')
    print(f"\nIcon saved successfully to: {output_path}")
    print(f"Size: {SIZE}x{SIZE}px")
    print(f"Background: {BG_COLOR}")
    print(f"Operators: {OPERATOR_COLOR}")

    return output_path

if __name__ == "__main__":
    create_icon()
