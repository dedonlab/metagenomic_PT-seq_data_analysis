import pandas as pd
import argparse

def auto_detect_delimiter(input_file):
    with open(input_file, 'r') as f:
        first_line = f.readline()
    if '\t' in first_line:
        return '\t'
    elif ',' in first_line:
        return ','
    else:
        return r'\s+'  # space or tab separated


def main():
    parser = argparse.ArgumentParser(
        description="Process a 5-column table. Add col6: best match among primary/fallback/other. Add col7: start position."
    )

    parser.add_argument('--input', required=True,
                        help='Path to input file (5 columns, 5th is string)')
    parser.add_argument('--motifs', nargs='+', required=True,
                        help='List of primary strings to search (e.g., --primary ABC DEF GHI)')
    parser.add_argument('--fallback', default='TTT',
                        help='Fallback string if no primary match (default: TTT)')
    parser.add_argument('--output', default='output.txt', required=True,
                        help='Output file path (default: output.txt)')

    args = parser.parse_args()

    # --- Processing starts here ---

    delimiter = auto_detect_delimiter(args.input)

    df = pd.read_csv(args.input, sep=delimiter, header=None, engine='python')
    df.columns = ["contig", "pos", "coverage", "depth", "seq"]

    if df.shape[1] < 5:
        raise ValueError("Input must have at least 5 columns")

    def find_best_match_and_pos(s):
        if not isinstance(s, str):
            return 'other', 0

        center = len(s) / 2.0
        best_dist = float('inf')
        winner_str = None
        winner_pos = -1

        # Step 1: Check primary strings
        for substr in args.motifs:
            pos = s.find(substr)
            if pos == -1:
                continue
            dist = abs(pos - center)
            if dist < best_dist:
                best_dist = dist
                winner_str = substr
                winner_pos = pos

        if winner_str is not None:
            return winner_str, winner_pos

        # Step 2: Check fallback
        pos = s.find(args.fallback)
        if pos != -1:
            return args.fallback, pos

        # Step 3: No match
        return 'other', 0
        
    # Add new columns
    df['motif'] = ''   # matched label
    df['motif_position'] = 0    # start position

    # Apply logic
    results = df['seq'].apply(find_best_match_and_pos)
    df[['motif', 'motif_position']] = pd.DataFrame(results.tolist(), index=df.index)
    df['motif_position'] = df['motif_position'].astype(int)

    # Optional: use 1-based indexing? Uncomment next line:
    df.loc[df['motif'] != 'other', 'motif_position'] += 1

    # Save result
    df.to_csv(args.output, sep='\t', index=False, header=False)
    print(f"Processed {len(df)} rows.")
    print(f"Output saved to '{args.output}'.")

if __name__ == "__main__":
    main()

