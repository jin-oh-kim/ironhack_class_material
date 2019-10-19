import csv
import re
import argparse

parser = argparse.ArgumentParser(description='Process some csv')
parser.add_argument('in_file', help='Give me a file')
parser.add_argument('out_file', help='Name of output file')

args = parser.parse_args()
in_path = args.in_file
out_path = args.out_file

re.findall()

data = []
with open(in_path, "r") as csvfile:
    real_estate_data = csv.DictReader(csvfile, delimiter=",")
    for row in real_estate_data:
        data.append(dict(row))

def parse_year(date):
    year_pattern = r"\d{4}$"
    return re.findall(year_pattern, date)[0]

def parse_day(date):
    day_pattern = r"\s(\d{1,2})\s"
    return re.findall(day_pattern, date)[0]

def parse_month(date):
    MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    month_pattern = r"^.{3}\s(\w{3})\s"
    string_month = re.findall(month_pattern, date)[0]
    month_number = str(MONTHS.index(string_month) + 1)
    return "0" + month_number if len(month_number) == 1 else month_number

def parse_date(date):
    year = parse_year(date)
    month = parse_month(date)
    day = parse_day(date)
    return year+"-"+month+"-"+day

CONVERSION = {
    "city": lambda x: x.title(),
    "zip": lambda x: int(x),
    "beds": lambda x: int(x),
    "baths": lambda x: int(x),
    "sq__ft": lambda x: int(x),
    "sale_date": parse_date,
    "price": lambda x: int(x),
    "latitude": lambda x: float(x),
    "longitude": lambda x: float(x)}

def process_row(row):
    new_row = {}
    for key in row.keys():
        if key in CONVERSION.keys():
            new_row[key.replace("__", "_")] = CONVERSION[key](row[key])
        else:
            new_row[key.replace("__", "_")] = row[key]
            
    return new_row

clean_data = [process_row(sample) for sample in data]

with open(out_path, "w") as csvfile:
    fieldnames = list(clean_data[0].keys())
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for row in clean_data:
        writer.writerow(row)
