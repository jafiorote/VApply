name=$1
initial=$2
nodes=$3
wall=$4
first=$5
if [ -z "$5" ]
    then
        first=False
fi
depend=$6
if [ -z "$6" ]
    then
        depend=False
fi
cation=XXX
anion=XXX

./pbsgen.sh $name $initial $nodes $wall $first $cation $anion> pbsjob.pbs

if [[ $depend == False ]]
    then
        /usr/bin/qsub pbsjob.pbs
    else
        /usr/bin/qsub pbsjob.pbs -W depend=afterany:$depend
fi
