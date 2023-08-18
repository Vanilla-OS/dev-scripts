#!/bin/sh

find -P "$1" -name '*.go' -not -path '*/vendor/*' -type f | while read -r line; do
    trans=$(grep -E -o '\.Trans\("[A-Za-z.]+"\)' "$line" | sed -E 's/\.Trans\("([A-Za-z.]+)"\)/\1/g')
    trans=$(echo "$trans" | sort | uniq)
    if [ "$(echo "$trans" | wc -l)" -eq 1 ]; then
        continue
    fi

    printf '%s:\n' "$line"
    for key in $trans; do
        printf '  - %s\n' "$key"
    done
    printf '\n'
done
