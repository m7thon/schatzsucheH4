#!/bin/bash

PIXELSIZE=3
OUTFILE=

while [[ $# -gt 1 ]]
do
key="$1"
case $key in
    --pixel-size)
    PIXELSIZE="$2"
    shift
    ;;
    -o)
    OUTFILE="$2"
    shift
    ;;
    *)
esac
shift
done

yaml=$1
if [ -z $OUTFILE ]; then OUTFILE=${yaml}.oid-table; fi

set -e

pid=$(grep product-id $yaml.yaml | sed -e 's/.*: //')
codes=$(sed -e 's/- .*$//; s/#.*$//; s/ _.*$//; /^ *$/d; 1,/^scriptcodes:.*$/d; /^scriptcodes:.*$/d; /^[^ ]./,$d' $yaml.yaml | sort)
if [ -f $yaml.codes.yaml ]; then
   codes="$codes $(sed -e's/- .*$//; s/#.*$//; s/ _.*$//; /^ *$/d; 1,/^scriptcodes:.*$/d; /^scriptcodes:.*$/d; /^[^ ]./,$d' $yaml.codes.yaml | sort)"
fi
codenames="START:$pid $(echo $codes | sed -e 's/: */:/g' | sort)"

echo Writing oid-table for $yaml.yaml with pixel-size $PIXELSIZE to $OUTFILE.png

files=
for cn in $codenames
do
        i=$(echo $cn | sed -e 's/\(.*\):\([0-9]*\)/\2/')
        n=$(echo $cn | sed -e 's/\(.*\):\([0-9]*\)/\1/')
	tttool --pixel-size ${PIXELSIZE} oid-code $i
	convert oid-${i}.png -crop 1152x1152+0+0 +repage oid${i}_tile.png
	convert oid${i}_tile.png -gravity north -stroke none -pointsize 144 -annotate 0 ${n} oid${i}_tile.png
	convert oid${i}_tile.png -shave 2x2 -bordercolor black -compose Copy -border 2 oid${i}_tile.png
	files="$files oid${i}_tile.png"
	rm -f oid-${i}.png
done

echo Creating ${OUTFILE}.png
montage $files -mode Concatenate -tile 7x ${OUTFILE}_temp.png
rm -f $files
convert -units PixelsPerInch ${OUTFILE}_temp.png -density 1200 ${OUTFILE}.png
rm ${OUTFILE}_temp.png
