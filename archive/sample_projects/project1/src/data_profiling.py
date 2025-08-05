from ydata_profiling import ProfileReport
import pandas as pd
from pathlib import Path



def gen_profile_report(data_path:str, report_path:str):
    """
    This function generate a data profile report
    """
    df = pd.read_csv(data_path,header=0)
    print(df.head())
    profile = ProfileReport(df, title="Profilling Report")
    profile.to_file(report_path)


def main():
    current_dir = Path.cwd()
    print(f"current work dir: {current_dir}")
    file_path = current_dir / "data/test.csv"
    report_path = current_dir / "tmp/my_report.html"
    gen_profile_report(file_path,report_path)

if __name__=="__main__":
    main()