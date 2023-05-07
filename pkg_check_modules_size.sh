#!/bin/sh
# This script checks the size of a list of packages defined in one or more
# yaml files. Usage: pkg_check_modules_size.sh <path to modules folder>

if [ $# -eq 0 ]; then
    echo "No modules path supplied"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Path $1 does not exist"
    exit 1
fi

ymls=$(find $1 -name "*.yml")
total_size=0
stored_sizes=""
treshold_in_mb=20
skipped_packages=""

for yml in $ymls; do
    packages=$(grep "^\s*-" $yml | sed 's/^\s*-\s*//g')
    for package in $packages; do
        size=$(apt-cache show $package 2>/dev/null | grep "^Installed-Size:" | head -1 | awk '{print $2}')

        if [ "$size" != "" ]; then
            total_size=$((total_size + size))
            stored_sizes="$stored_sizes $package#$size"
        else
            skipped_packages="$skipped_packages $package"
        fi
    done
done

total_size_mb=$(echo "scale=2; $total_size / 1024" | bc)

echo "Total size of all packages in $1 is:"
echo "$total_size_mb MB"

echo "\n----------------------------------\n"

echo "Packages that are bigger than $treshold_in_mb MB:"
for package in $stored_sizes; do
    name=$(echo "$package" | awk -F "#" '{print $1}')
    size=$(echo "$package" | awk -F "#" '{print $2}')
    size_mb=$(echo "scale=2; $size / 1024" | bc)
    if [ $(echo "$size_mb > $treshold_in_mb" | bc) -ne 0 ]; then
        echo "$name $size_mb MB"
    fi
done

echo "\n----------------------------------\n"

echo "Packages that were skipped:"
for package in $skipped_packages; do
    echo "$package"
done
