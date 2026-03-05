import sys
import argparse
import pandas as pd
import textwrap

def process_table(input_file, output_file, arg_nts, arg_reads):

    # Define constants based on method.
    multiplier = 1000000000000
    normalized_nts = float(arg_nts)
    total_reads = float(arg_reads)

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
        "--nts",
        help="int/float.the number of nts of the metagenome calculated based on the abundance of each genome multiplying the size of each genome from Kraken2-Bracken"
    )
    
    parser.add_argument(
        "--reads",
        help="int/float.the number of reads"
    )
    
    # Parse arguments
    args = parser.parse_args()
    
    # Execute logic
    process_table(args.input, args.output, args.nts, args.reads)

if __name__ == "__main__":
    # Import textwrap here to avoid issues if used inside the function definition above
    import textwrap
    main()


