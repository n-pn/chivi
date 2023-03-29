set -e
for i in "$@"; do
  temp="$(mktemp -d -- "${i%/*}/hardlnk-XXXXXXXX")"
  [ -e "$temp" ] && cp -ip "$i" "$temp/tempcopy" && mv "$temp/tempcopy" "$i" && rmdir "$temp"
done

# find -not -type d -links +1 -print0 | xargs -0 unhardlink.sh
