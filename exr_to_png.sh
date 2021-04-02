#!/bin/bash
for file in `ls translucency_test_*.exr`
do
convert $file -evaluate Multiply 1.3 ${file%.exr}.png
done
