#!/bin/bash

set -e 

codenames="START:904 $(cat schatzsucheH4.yaml | sed -e '1,/scriptcodes:/d' | sed -e 's/  \([A-Za-z0-9-][A-Za-z0-9_-]*\): \([0-9]*\)/\1:\2/' | grep -v '  ' | sort)"
files=

for cn in $codenames
do
        i=$(echo $cn | sed -e 's/\([A-Za-z0-9_-]*\):\([0-9]*\)/\2/')
        n=$(echo $cn | sed -e 's/\([A-Za-z0-9_-]*\):\([0-9]*\)/\1/')
        echo Creating oid${i}_tile.png for ${n}
	tttool --pixel-size 3 oid-code $i
	convert oid-${i}.png -crop 1152x1152+0+0 +repage oid${i}_tile.png
	convert oid${i}_tile.png -gravity north -stroke none -pointsize 144 -annotate 0 ${n} oid${i}_tile.png
	convert oid${i}_tile.png -shave 2x2 -bordercolor black -compose Copy -border 2 oid${i}_tile.png
	files="$files oid${i}_tile.png"
	rm -f oid-${i}.png
done
echo Creating oid-table.png
montage $files -mode Concatenate -tile 7x oid-table.png
rm -f $files
convert -units PixelsPerInch oid-table.png -density 1200 oid-table1200.png
rm oid-table.png
