#!/bin/bash

project_path=""
ignore_pattern='*/vendor/*'
ref_file="locales/en.yml"
mode="all"

show_help() {
    cat << EOF
Usage:
    extract_project_translations.sh [OPTION] [project_path]

    Modes:
    --all       -a      Show all strings in project (default)
    --diff      -d      List only strings that have been added/removed

    Options:
    --ref       -r      Reference file for diff argument (default: locale/en.yml)
    --ignore            Ignore path pattern when searching for strings (default: '*/vendor/*')
EOF
}

while :; do
    case $1 in
        -h | --help)
            show_help
            exit 0
            ;;
        -a | --all)
            shift
            mode="all"
            ;;
        -d | --diff)
            shift
            mode="diff"
            ;;
        -r | --ref)
            shift
            if [ -n "$2" ]; then
                ref_file="$2"
                shift
                shift
            fi
            ;;
        --ignore)
            shift
            if [ -n "$2" ]; then
                ignore_pattern="$2"
                shift
                shift
            fi
            ;;
        *)
            if [ -n "$1" ]; then
                project_path="$1"
                shift
            else
                break
            fi
            ;;
    esac
done

find -P "$project_path" -name '*.go' -not -path "$ignore_pattern" -type f | while read -r line; do
    trans=$(grep -E -o '\.Trans\("[A-Za-z\-_.]+"\)' "$line" | sed -E 's/\.Trans\("([A-Za-z\-_.]+)"\)/\1/g')
    trans=$(printf '%s' "$trans" | sort -u)

    if [ -z "$trans" ]; then
        if [ "$(printf '%s' "$trans" | wc -l)" -eq 0 ]; then
            continue
        fi
    fi

    print_items=""
    n_items=0
    for key in $trans; do
        if [ "$mode" = "diff" ]; then
            pref=${key%.*}
            suff=${key#*.}
            grep -Pzq "${pref}:\n(?:(\s+)\w*:\s*(?:\"[^\"]*\"\n|\|\n(?:(?!\1\S).*\n)+))*\s+${suff}:[^\n]" "${project_path}/${ref_file}"
            if [ $? -ne 0 ]; then
                printf -v print_items '%s  - %s\n' "$print_items" "$key"
                n_items=$((n_items+1))
            fi
        else
            printf -v print_items '%s  - %s\n' "$print_items" "$key"
            n_items=$((n_items+1))
        fi
    done

    if [ $n_items -gt 0 ]; then
        printf '%s:\n' "$line"
        printf "$print_items"
        printf '\n'
    fi
done
