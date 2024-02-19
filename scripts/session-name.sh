val=$(echo "$1" | sed 's/\(.*\)-[0-9]\+/\1/')
echo $val
