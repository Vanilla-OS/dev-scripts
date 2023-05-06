#!/bin/sh
# This script checks the size of a list of packages.

# Check arguments
if [ $# -eq 0 ]; then
  echo "Usage: $0 package1 [package2 ...]"
  exit 1
fi

total_size=0

for package in "$@"; do
  # Get package size with dpkg-query if installed, otherwise with apt-cache show
  if dpkg -s "$package" >/dev/null 2>&1; then
    package_size=$(dpkg-query -s "$package" | grep "Installed-Size:" | cut -d' ' -f2)
  else
    package_size=$(apt-cache show "$package" | grep -m 1 "Installed-Size:" | cut -d' ' -f2)
   fi

  if [ -n "$package_size" ]; then
    echo "$package: $package_size kB"
    total_size=$((total_size + package_size))
  else
    echo "Warning: Package '$package' not found or size not available."
  fi
done

total_size_mb=$(echo "scale=2; $total_size/1024" | bc)
echo "Total size: $total_size_mb MB"
