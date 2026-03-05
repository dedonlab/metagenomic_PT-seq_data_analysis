import sys
import argparse
import pandas as pd
import textwrap

def process_table(input_file, output_file, pipeline, method):
    # Validate Pipeline/Method constraints
    if pipeline not in ["1", "2"]:
        print("Error: Pipeline must be 1 or 2.")
        sys.exit(1)
    
    if method not in ["1", "2", "3", "4"]:
        print("Error: Method must be 1, 2, 3, or 4.")
        sys.exit(1)

    # Define constants based on method.
    multiplier = 1000000000000
    
    if pipeline =="1" and method == "1":
        normalized_nts = 6587876.446
        total_reads = 5131334
    elif pipeline =="1" and method == "2":
        normalized_nts = 6587876.446
        total_reads = 6784507
    elif pipeline =="1" and method == "3":
        normalized_nts = 6587876.446
        total_reads = 4625575
    elif pipeline =="1" and method == "4":
        normalized_nts = 6587876.446
        total_reads = 4700797
    elif pipeline =="2" and method == "1":
        normalized_nts = 6814152.646
        total_reads = 5131334
    elif pipeline =="2" and method == "2":
        normalized_nts = 6628200.063
        total_reads = 6784507
    elif pipeline =="2" and method == "3":
        normalized_nts = 6889369.502
        total_reads = 4625575
    elif pipeline =="2" and method == "4":
        normalized_nts = 6968763.094
        total_reads = 4700797

    try:
        # 1. read input.
        # dtype={0: str} ensures the first column (index 0) is read as string (Row Names)
        df = pd.read_csv(input_file, sep='\t', header=None, dtype={0: str})
            
        if df.empty:
            print("Error: Input file is empty.")
            sys.exit(1)

        num_cols = df.shape[1]

        # 2. Generate New Column Names
        # Col 0 -> "RowName", Col 1..N -> "Col_1", "Col_2"...
        new_columns = ["Genome"] + [f"depth_{i}" for i in range(1, num_cols)]
        df.columns = new_columns

        # 3. Perform Mathematical Operations
        # Select all numeric columns (everything except 'RowName')
        numeric_cols = df.columns[1:]
        
        # Convert to numeric to ensure calculation works (coerce errors to NaN)
        df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors='coerce')
        
        # Apply formula: (value / nts) * multiplier
        df[numeric_cols] = ((df[numeric_cols] / normalized_nts) / total_reads ) * multiplier

        # 4. Handle Method 1 Summation
        # Calculate sum for each numeric column, ignoring NaNs
        sums = df[numeric_cols].sum()
            
        # Create a new row for the sums
        sum_row = pd.Series(["SUM"] + sums.tolist(), index=df.columns)
            
        # Append the sum row to the dataframe
        # ignore_index=True resets the index so the new row gets the next integer index
        df = pd.concat([df, pd.DataFrame([sum_row])], ignore_index=True)

        # 5. Write Output
        # index=False prevents writing the pandas row index (0, 1, 2...) to the file
        # float_format='%.6g' keeps numbers clean but precise (optional, can be removed)
        df.to_csv(output_file, sep='\t', index=False, float_format='%.8g')

        print(f"Input rows: {len(df) - 1}")
        print(f"Output saved to '{output_file}'")

    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)


def main():
    # Initialize ArgumentParser
    parser = argparse.ArgumentParser(
        description="Process a tab-delimited table of depth 1-50 with row names based on pipeline and method settings.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    # Define arguments
    parser.add_argument(
        "--input",
        help="Path to the input tab-delimited file"
    )
    
    parser.add_argument(
        "--output",
        help="Path to save the output tab-delimited file"
    )
    
    parser.add_argument(
        "--pipeline",
        choices=["1", "2"],
        help="Pipeline '1' '2' is supported)"
    )
    
    parser.add_argument(
        "--method",
        choices=["1", "2", "3", "4"],
        help=textwrap.dedent("""\
            Method must be in '1', '2', '3', and '4'.
        """)
    )
    
    # Parse arguments
    args = parser.parse_args()
    
    # Execute logic
    process_table(args.input, args.output, args.pipeline, args.method)

if __name__ == "__main__":
    # Import textwrap here to avoid issues if used inside the function definition above
    import textwrap
    main()


