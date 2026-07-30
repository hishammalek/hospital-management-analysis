import pandas as pd
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent

csv_folder = BASE_DIR / "data" / "clean" / "csv"


files = [
    "patients_clean.csv",
    "doctors_clean.csv",
    "departments_clean.csv",
    "admissions_clean.csv",
    "treatment_clean.csv",
    "billing_clean.csv",
    "calendar_clean.csv"
]


for file in files:
    path = csv_folder / file

    df = pd.read_csv(path)

    print("\n==============================")
    print(file)
    print("==============================")
    
    print("Rows:", len(df))
    print("Columns:", list(df.columns))
    print("Missing values:")
    print(df.isnull().sum())