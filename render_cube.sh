#!/bin/bash

TYPE=$1
SCALE=$2
G=$3


if [ $TYPE == "cube" ]
then
    sed -e "s/\\\$scale\\\$/$SCALE/" cube.pbrt | sed -e "s/\\\$g\\\$/$G/" | pbrt
elif [ $TYPE == "slice" ]
then
SLICES=$4
    SLICE_FN=pounamu_pbrt/slice$SLURM_JOB_ID.pbrt
    echo "Include \"pounamu_pbrt/optical_properties_"$SCALE"_"$G".pbrt\"" > $SLICE_FN
    
    seq 0 $(expr $SLICES - 1) | xargs -n1 -I{} printf "Include \"pounamu_pbrt/row_%03d/row_%03d.pbrt\"\n" {} {} >> $SLICE_FN
    sed -e "s/\\\$scale\\\$/$SCALE/" scenes/translucency_test.pbrt | sed -e "s/\\\$g\\\$/$G/" | sed -e "s/\\\$slices\\\$/$SLICES/" | sed -e "s/\\\$job_id\\\$/$SLURM_JOB_ID/" | pbrt
    
    rm $SLICE_FN
elif [ $TYPE == "subcube" ]
then
    SLICES=$4
    SLICE_FN=pounamu_pbrt/slice$SLURM_JOB_ID.pbrt
    echo "Include \"pounamu_pbrt/optical_properties_"$SCALE"_"$G".pbrt\"" > $SLICE_FN

    EDGE=$(( ($SLICES - 1) / 2 ))
    
    HEAD_CUT=$(( ( 32 + $EDGE ) * 8 ))   
    TAIL_CUT=$(( $SLICES * 8 ))

    for i_offset in $(seq -$EDGE $EDGE)
    do
        i=$(( 32 + $i_offset ))
        for j_offset in $(seq -$EDGE $EDGE)
        do
            j=$(( 32 + $j_offset ))
            COL_FILENAME=$(printf "pounamu_pbrt/row_%03d/col_%03d.pbrt" $i $j)
            head -n$HEAD_CUT $COL_FILENAME | tail -n$TAIL_CUT >> $SLICE_FN
        done
    done
    
    sed -e "s/\\\$scale\\\$/$SCALE/" scenes/translucency_test.pbrt | sed -e "s/\\\$g\\\$/$G/" | sed -e "s/\\\$slices\\\$/subcube_$SLICES/" | sed -e "s/\\\$job_id\\\$/$SLURM_JOB_ID/" | pbrt
    rm $SLICE_FN
else
    echo "Unrecognised type $TYPE"
fi