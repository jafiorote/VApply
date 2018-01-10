name=$1
initial=$2
nodes=$3
wall=$4
first=False
first=$5
cation=SOD
anion=CLA

./pbsgen.sh $name $initial $nodes $wall $first $cation $anion> pbsjob.pbs
/usr/bin/qsub pbsjob.pbs
