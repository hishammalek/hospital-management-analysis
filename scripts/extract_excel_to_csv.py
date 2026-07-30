import pandas as pd
from pathlib import Path


# ==========================================
# Extract Excel sheets into CSV files
# ==========================================

# Project root directory
BASE_DIR = Path(__file__).resolve().parent.parent


# Input Excel file
input_file = (
    BASE_DIR
    / "data"
    / "raw"
    / "Hospital_Patient_Treatment_Management_System (1).xlsx"
)


# Output folder
output_dir = (
    BASE_DIR
    / "data"
    / "processed"
    / "csv"
)


# Create output folder if not exists
output_dir.mkdir(parents=True, exist_ok=True)


# Load Excel workbook
excel_file = pd.ExcelFile(input_file)


print("Sheets found:")
print(excel_file.sheet_names)


# Export each sheet as CSV
for sheet in excel_file.sheet_names:

    df = pd.read_excel(
        input_file,
        sheet_name=sheet
    )

    # Fix spelling issue from dataset
    if sheet.lower() == "calender":
        file_name = "calendar.csv"
    else:
        file_name = f"{sheet.lower()}.csv"

    output_file = output_dir / file_name

    df.to_csv(
        output_file,
        index=False
    )

    print(f"Exported: {file_name}")


print("\nExcel extraction completed successfully!")