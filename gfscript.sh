#!/usr/bin/env bash

# --- Usage function ---
usage() {
  echo "Usage: $0 <input_file> [-o output_dir]"
  exit 1
}

# --- Check at least 1 arg (input file) ---
if [ $# -lt 1 ]; then
  usage
fi

# --- Parse arguments ---
input_file="$1"
shift
outdir=""

while getopts "o:" opt; do
  case $opt in
    o) outdir="$OPTARG" ;;
    *) usage ;;
  esac
done

# --- Check input file exists ---
if [ ! -f "$input_file" ]; then
  echo "[-] Error: input file '$input_file' not found!"
  exit 1
fi

# --- Set default output directory if not provided ---
if [ -z "$outdir" ]; then
  outdir="gfscript_$(date +'%d%b%y_%H%M')"
fi

mkdir -p "$outdir"
echo "[+] Output directory: $outdir"

# --- Get list of gf patterns ---
patterns=$(gf -list)

# --- Run each pattern ---
for pattern in $patterns; do
  echo "[*] Running pattern: $pattern"
  cat "$input_file" | uro | gf "$pattern" | sed "s/'\|(\|)//g" | qsreplace "FUZZ" 2>/dev/null | httpx -silent -mc 200 | anew -q "$outdir/$pattern.txt"

# If file is empty, remove it to keep output dir clean
  if [ ! -s "$outdir/$pattern.txt" ]; then
    rm "$outdir/$pattern.txt"
  fi
done

echo "[+] Done! Results saved in $outdir/"
