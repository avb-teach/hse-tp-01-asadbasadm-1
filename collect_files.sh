#!/bin/bash

h() {
    echo "Run: $0 s t [--m N]"
    exit 1
}

[ $# -lt 2 ] && h

s="$1"
t="$2"
m=-1

if [ $# -eq 4 ] && [ "$3" = "--m" ]; then
    [[ "$4" =~ ^[0-9]+$ ]] || { echo "Err: m must be num"; exit 1; }
    m="$4"
fi

[ -d "$s" ] || { echo "Err: s not found"; exit 1; }
mkdir -p "$t" || { echo "Err: can't make t"; exit 1; }

rn() {
    local o="$1"
    local d="$2"
    local n=$(basename "$o")
    local b="${n%.*}"
    local e="${n##*.}"
    local p="$d/$n"
    local i=1

    [ ! -e "$p" ] && { echo "$n"; return; }

    while [ -e "$p" ]; do
        [ "$e" = "$n" ] && p="$d/${b}${i}" || p="$d/${b}${i}.${e}"
        ((i++))
    done
    echo "$(basename "$p")"
}

sc() {
    local f="$1"
    local l="$2"

    [ "$m" -ge 0 ] && [ "$l" -gt "$m" ] && return

    find "$f" -maxdepth 1 -type f | while read -r x; do
        [[ "$x" == "$t"/* ]] && continue
        nn=$(rn "$x" "$t")
        cp "$x" "$t/$nn" || echo "Wrn: copy failed $x"
    done

    find "$f" -maxdepth 1 -type d | while read -r sf; do
        [ "$sf" = "$f" ] || [[ "$sf" == "$t"/* ]] && continue
        sc "$sf" $((l + 1))
    done
}

sc "$s" 1
exit 0