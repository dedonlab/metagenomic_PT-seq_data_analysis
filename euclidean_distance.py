import math
import csv
import sys

def normalize(vector):
    """Converts a list of numbers into a ratio that sums to 1."""
    total = sum(vector)
    if total == 0:
        return None # Indicates invalid normalization
    return [x / total for x in vector]

def euclidean_distance(v1, v2):
    """Calculates Euclidean distance between two vectors."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(v1, v2)))

def main():
    # Define the Hypothesis Ratio (8, 22, 12)
    hypothesis_raw = [8, 22, 12]

    # Normalize hypothesis once
    h_norm = normalize(hypothesis_raw)
    if h_norm is None:
        print("Error: Hypothesis sum is 0.")
        return

    input_file = sys.argv[1] # Change this to your actual filename

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            reader = csv.reader(f, delimiter='\t')

            for row in reader:
                # Skip empty lines or malformed rows
                if not row or len(row) < 3:
                    continue

                try:
                    # Parse values
                    a = float(row[0].strip())
                    b = float(row[1].strip())
                    c = float(row[2].strip())

                    current_sum = a + b + c

                    # Check for (0,0,0) or any combination summing to 0
                    if current_sum == 0:
                        print("n.a.")
                        continue

                    # Normalize current row
                    obs_norm = normalize([a, b, c])

                    # Calculate distance
                    dist = euclidean_distance(obs_norm, h_norm)

                    # Print ONLY the distance
                    print(f"{dist:.6f}")

                except ValueError:
                    # If a row contains non-numbers, treat as invalid (optional: could print n.a. or skip)
                    # Based on request, we assume valid number inputs except for the 0,0,0 case.
                    continue

    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.")

if __name__ == "__main__":
    main()

