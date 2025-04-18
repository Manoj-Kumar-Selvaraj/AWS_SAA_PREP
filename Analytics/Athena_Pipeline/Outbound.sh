#!/bin/bash

# Define paths
SOURCE_DIR="/home/manoj/Code-repo/AWS_SAA_PREP/Analytics/Athena_Pipeline/Files"
KEY_DIR="/home/manoj/Code-repo/AWS_SAA_PREP/Analytics/Athena_Pipeline/Keys"
ENCRYPTED_DIR="$SOURCE_DIR/ Encrypted_Files"
PUBLIC_KEY="$KEY_DIR/public_key.asc"
FILES=("names.csv" "regions.csv" "baby_names_db_data_dictionary.csv")

# Create encrypted directory if not exists
mkdir -p "$ENCRYPTED_DIR"

# Import public key
gpg --import "$PUBLIC_KEY" > /dev/null 2>&1

# Get recipient from public key
RECIPIENT=$(gpg --with-colons --import-options show-only --import "$PUBLIC_KEY" 2>/dev/null | grep '^uid' | cut -d ':' -f 10 | head -n 1)

# Encrypt each file
for file in "${FILES[@]}"; do
    INPUT="$SOURCE_DIR/$file"
    OUTPUT="$ENCRYPTED_DIR/$file.gpg"

    echo "Encrypting $file -> $(basename $OUTPUT)"
    gpg --yes --batch --output "$OUTPUT" --encrypt --recipient "$RECIPIENT" "$INPUT"
done

echo "✅ All files encrypted and saved to: $ENCRYPTED_DIR"
