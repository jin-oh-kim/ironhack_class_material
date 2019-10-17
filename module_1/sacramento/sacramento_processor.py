import csv
import re
import argparse


class SacramentoProcessor():
    """
    Description
    """
    def __init__(self, in_path):
        """
        Description
        """
        self._in_path = in_path
        self.old_dataset = self._load_csv()
        self.processed_dataset = self._process_data()
        self.no_of_rows = len(self.processed_dataset)

    def _load_csv(self):
        data = []
        with open(self._in_path, "r") as csvfile:
            real_estate_data = csv.DictReader(csvfile, delimiter=",")
            for row in real_estate_data:
                data.append(dict(row))
        return data

    @staticmethod
    def _parse_year(date):
        year_pattern = r"\d{4}$"
        return re.findall(year_pattern, date)[0]

    @staticmethod
    def _parse_day(date):
        day_pattern = r"\s(\d{1,2})\s"
        return re.findall(day_pattern, date)[0]

    @staticmethod
    def _parse_month(date):
        MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        month_pattern = r"^.{3}\s(\w{3})\s"
        string_month = re.findall(month_pattern, date)[0]
        month_number = str(MONTHS.index(string_month) + 1)
        return "0" + month_number if len(month_number) == 1 else month_number

    def _parse_date(self, date):
        year = self._parse_year(date)
        month = self._parse_month(date)
        day = self._parse_day(date)
        return year+"-"+month+"-"+day

    def process_row(self, row):
        CONVERSION = {
            "city": lambda x: x.title(),
            "zip": lambda x: int(x),
            "beds": lambda x: int(x),
            "baths": lambda x: int(x),
            "sq__ft": lambda x: int(x),
            "sale_date": self._parse_date,
            "price": lambda x: int(x),
            "latitude": lambda x: float(x),
            "longitude": lambda x: float(x)}

        new_row = {}
        for key in row.keys():
            if key in CONVERSION.keys():
                new_row[key.replace("__", "_")] = CONVERSION[key](row[key])
            else:
                new_row[key.replace("__", "_")] = row[key]
                
        return new_row

    def _process_data(self):
        return [self.process_row(sample) for sample in self.old_dataset]

    def to_csv(self, out_path):
        with open(out_path, "w") as csvfile:
            fieldnames = list(self.processed_dataset[0].keys())
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

            writer.writeheader()
            for row in self.processed_dataset:
                writer.writerow(row)
    
    def to_list(self):
        return self.processed_dataset


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some csv')
    parser.add_argument('in_file', help='Give me a file')
    parser.add_argument('out_file', help='Name of output file')

    args = parser.parse_args()
    in_path = args.in_file
    out_path = args.out_file

    data = SacramentoProcessor(in_path)
    data.to_csv(out_path)
