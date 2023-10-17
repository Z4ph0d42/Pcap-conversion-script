#!/bin/bash

# Check if the hcxtools is installed
if ! command -v hcxpcaptool &> /dev/null; then
    echo "hcxtools is not installed. Please install it first."
    exit 1
fi

# Specify your keywords
keywords=("keyword1" "keyword2" "keyword3")

# Directory containing pcap files
pcap_dir="/path/to/pcap/files"

# Create the "unsorted" folder if it doesn't exist
unsorted_dir="$pcap_dir/unsorted"
mkdir -p "$unsorted_dir"

# Loop through each keyword
for keyword in "${keywords[@]}"; do
    keyword_dir="$pcap_dir/$keyword"
    mkdir -p "$keyword_dir"
    
    # Convert pcap files to hc2200 in the keyword folder
    for file in "$pcap_dir"/*.pcap; do
        if [[ -f "$file" && -r "$file" ]]; then
            if grep -q "$(echo "$keyword" | tr '[:upper:]' '[:lower:]')" <<< "$(echo "$file" | tr '[:upper:]' '[:lower:]')"; then
                hcxfile="$keyword_dir/$(basename "$file" .pcap).hc2200"
            else
                hcxfile="$unsorted_dir/$(basename "$file" .pcap).hc2200"
            fi
            
            # Convert pcap to hc2200
            hcxpcaptool -o "$hcxfile" "$file"
        fi
    done
done

# Move previously "unsorted" files to the appropriate keyword directories
for keyword in "${keywords[@]}"; do
    keyword_dir="$pcap_dir/$keyword"
    
    # Loop through files in the unsorted directory
    for file in "$unsorted_dir"/*.hc2200; do
        if [[ -f "$file" && -r "$file" ]]; then
            if grep -q "$(echo "$keyword" | tr '[:upper:]' '[:lower:]')" <<< "$(echo "$(basename "$file" .hc2200)" | tr '[:upper:]' '[:lower:]')"; then
                # Move the file to the keyword directory
                mv "$file" "$keyword_dir/$(basename "$file")"
            fi
        fi
    done
done

echo "Conversion and organization complete."
