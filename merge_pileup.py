import sys
from collections import defaultdict

#Usage:
#The input file is a tab delimited txt file with 8 columns. The 2nd, 3rd, 4th, 7th and 8th columns are numbers, the 5th and 6th columns are strings.
#This script that merges rows of the input file and save the output to a new tsv file.
#Between all rows have the same first column (strings), merge when the absolute abstract of the two numbers in the 8th columns are less than 3, and keep the row whose value in the 7th column is more close to 10 and replace the 4th columns with the sum of the 4th columns of the two rows and the 6th column.
#When the difference of the value in the 7th column of the two rows is tie, print the row of which the 4th column is larger.
#If the values in the 4th columns are still the same, print the first occurring row and replace the 4th columns with the sum of the 4th columns of the two rows. It merges all possible rows, instead of just pairing them up.


def merge_rows_advanced(input_file, output_file):
    rows = []

    # 1. Read and Parse Input
    try:
        with open(input_file, 'r') as f:
            for line_idx, line in enumerate(f):
                line = line.strip()
                if not line:
                    continue

                parts = line.split('\t')
                if len(parts) != 8:
                    print(f"Warning: Skipping line {line_idx + 1} (Expected 8 columns, found {len(parts)})")
                    continue

                try:
                    # Map columns to a dictionary
                    # Col 1: String (Group Key A)
                    # Col 2, 3, 4, 7, 8: Numbers
                    # Col 5, 6: Strings (Col 6 is Group Key B)
                    row_data = {
                        'original_index': line_idx,
                        'col1': parts[0],
                        'col2': float(parts[1]),
                        'col3': float(parts[2]),
                        'col4': float(parts[3]), # To be summed
                        'col5': parts[4],        # String (kept from representative)
                        'col6': parts[5],        # String (Group Key B)
                        'col7': float(parts[6]), # Criteria: Closest to 10
                        'col8': float(parts[7])  # Criteria: Distance < 5
                    }
                    rows.append(row_data)
                except ValueError:
                    print(f"Warning: Skipping line {line_idx + 1} (Non-numeric value in numeric column)")
                    continue
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")
        sys.exit(1)

    # 2. Group rows by Column 1 AND Column 6
    # Only rows matching BOTH keys will be considered for merging together
    groups = defaultdict(list)
    for row in rows:
        #group_key = (row['col1'], row['col6']) #Group rows by Column 1 AND Column 6
        group_key = (row['col1']) #Group rows by Column 1
        groups[group_key].append(row)

    final_merged_rows = []

    # 3. Process each group
    for key, group_list in groups.items():
        if not group_list:
            continue

        # Sort by Col 8 to optimize the clustering search
        group_list.sort(key=lambda x: x['col8'])
        n = len(group_list)
        visited = [False] * n

        for i in range(n):
            if visited[i]:
                continue

            # Start a new cluster with the current row
            cluster_indices = [i]
            visited[i] = True

            # Expand cluster: Single-Linkage Clustering
            # Merge if abs(col8_i - col8_j) < 5
            changed = True
            while changed:
                changed = False
                current_cluster_rows = [group_list[idx] for idx in cluster_indices]

                # Optimization: Calculate current min/max col8 in the cluster
                min_c8 = min(r['col8'] for r in current_cluster_rows)
                max_c8 = max(r['col8'] for r in current_cluster_rows)

                for j in range(n):
                    if visited[j]:
                        continue

                    candidate = group_list[j]
                    val_c8 = candidate['col8']

                    # Quick rejection: If candidate is too far from the entire cluster range
                    # Threshold is 3, so if it's outside [min-3, max+3], it can't connect
                    if val_c8 < (min_c8 - 3) or val_c8 > (max_c8 + 3):
                        continue

                    # Check if candidate is within 3 of ANY member in the current cluster
                    is_connected = False
                    for member in current_cluster_rows:
                        if abs(member['col8'] - val_c8) < 3:
                            is_connected = True
                            break

                    if is_connected:
                        visited[j] = True
                        cluster_indices.append(j)
                        changed = True

            # --- Cluster Formed ---
            cluster_rows = [group_list[idx] for idx in cluster_indices]

            # A. Calculate Sum of Column 4 for all rows in this cluster
            sum_col4 = sum(r['col4'] for r in cluster_rows)

            # B. coverage is the max.
            max_col3 = max(r['col3'] for r in cluster_rows)

            # C. Select the Representative Row based on rules:
            # 1. Col 7 closest to 10 (min abs(col7 - 10))
            # 2. Tie-breaker: Larger Col 4 (original value)
            # 3. Tie-breaker: First occurring (lowest original_index)

            best_row = None
            best_diff_7 = float('inf')
            best_val_4 = -float('inf')
            best_col_6 = str()
            best_orig_idx = float('inf')

            for r in cluster_rows:
                diff_7 = abs(r['col7'] - 10)
                val_4 = r['col4']
                col_6 = r['col6']
                orig_idx = r['original_index']

                is_better = False

                if diff_7 < best_diff_7:
                    is_better = True
                elif diff_7 == best_diff_7:
                    if val_4 > best_val_4:
                        is_better = True
                    elif val_4 == best_val_4:
                        if orig_idx < best_orig_idx:
                            is_better = True

                if is_better:
                    best_row = r
                    best_diff_7 = diff_7
                    best_val_4 = val_4
                    best_col_6 = col_6
                    best_orig_idx = orig_idx

            # C. Create the final merged row
            # Copy the best representative row
            final_row = best_row.copy()
            # Replace Col 3 with the max coverage
            final_row['col3'] = max_col3
            # Replace Col 4 with the calculated sum
            final_row['col4'] = sum_col4

            final_merged_rows.append(final_row)

    # 4. Sort output by original index to preserve general file order
    final_merged_rows.sort(key=lambda x: x['original_index'])

    # 5. Write to Output TSV
    with open(output_file, 'w') as f:
        for row in final_merged_rows:
            # Construct the line ensuring tab separation
            out_line = [
                str(row['col1']),
                str(row['col2']),
                str(row['col3']),
                str(row['col4']),
                str(row['col5']),
                str(row['col6']),
                str(row['col7']),
                str(row['col8'])
            ]
            f.write('\t'.join(out_line) + '\n')

    print(f"Success! Merged {len(rows)} input rows into {len(final_merged_rows)} output rows.")
    print(f"Output saved to: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python merge_rows_v2.py <input.tsv> <output.tsv>")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    merge_rows_advanced(input_path, output_path)

