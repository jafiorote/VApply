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
cation=
anion=

./pbsgen.sh $name $initial $nodes $wall $first $cation $anion> pbsjob.pbs

#vela
#if [[ $depend == False ]]
    #then
        #/usr/bin/qsub pbsjob.pbs
    #else
        #/usr/bin/qsub pbsjob.pbs -W depend=afterany:$depend
#fi

##cosmos CPU
if [[ $depend == False ]]
    then
        /usr/local/bin/qsub pbsjob.pbs -q unb
    else
        /usr/local/bin/qsub pbsjob.pbs -q unb -W depend=afterany:$depend
fi

##cosmos GPU
#if [[ $depend == False ]]
    #then
        #/usr/local/bin/qsub pbsjob.pbs -q gpu
    #else
        #/usr/local/bin/qsub pbsjob.pbs -q gpu -W depend=afterany:$depend
#fi
