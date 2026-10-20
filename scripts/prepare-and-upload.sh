#!/bin/zsh
# Converts images to high-quality JPEG (Instagram's API needs JPEG) and uploads them to catbox.moe.
# Prints one public URL per file, in order, and appends them to uploaded-urls.txt.
# ⚠️ Uploaded files are PUBLIC and permanent. Only upload final, redacted images.
# Usage: ./scripts/prepare-and-upload.sh slide-1.png slide-2.png ...
set -e
[ $# -gt 0 ] || { echo "usage: $0 image [image...]"; exit 1; }
mkdir -p jpg
for f in "$@"; do
  out="jpg/$(basename "${f%.*}").jpg"
  sips -s format jpeg -s formatOptions 95 "$f" --out "$out" >/dev/null
  url=$(curl -s --max-time 180 -F "reqtype=fileupload" -F "fileToUpload=@$out" https://catbox.moe/user/api.php)
  code=$(curl -s -o /dev/null --max-time 30 -w '%{http_code}' "$url")
  echo "$f -> $url (HTTP $code)" | tee -a uploaded-urls.txt
done
