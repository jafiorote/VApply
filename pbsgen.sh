name=$1
initial=$2
nodes=$3
wall=$4
first=$5
cation=$6
anion=$7
pwddir=`pwd`
machine='cosmosgpu'

if [ $machine == 'cosmos' ]
    then
        vmddir="PYTHONHOME=/cluster/packages/python/python-3.5.2 LD_LIBRARY_PATH=\$PYTHONHOME/lib /cluster/packages/vmd-1.9.2-minimal-python-3/bin"
        namdbin="/cluster/intel/impi/5.0.3.048/intel64/bin/mpirun /cluster/packages/namd_2.10_cpu_mpi/namd2"
        ppn=40
elif [ $machine == 'vela' ]
    then
        vmddir="/home/lcirqueira/install/tclvmd/bin"
        namdbin="/home/lcirqueira/install/namd2/namd2 +idlepoll +p4"
        ppn=4
elif [ $machine == 'cosmosgpu' ]
    then
        ppn=40
        procs=$(( ppn * nodes ))
        vmddir="PYTHONHOME=/cluster/packages/python/python-3.5.2 LD_LIBRARY_PATH=\$PYTHONHOME/lib /cluster/packages/vmd-1.9.2-minimal-python-3/bin"
        namdbin="/cluster/packages/namd_2.12_cuda_charmrun/charmrun ++nodelist \$NODEFILE /cluster/packages/namd_2.12_cuda_charmrun/namd2 +p $procs ++ppn $ppn"
fi
        

echo "#"PBS -N $name.$initial
echo "#"PBS -l nodes=$nodes:ppn=$ppn
echo "#"PBS -l pmem=300mb
echo "#"PBS -l walltime=$wall
echo "#"PBS -j eo

if [ $machine == 'cosmosgpu' ]
    then
        echo "#"PBS -p 1020
        echo "#"PBS -d $pwddir
        echo "#"PBS -k n
fi

echo " "
echo i=$initial
echo cd $pwddir
if [ $machine == 'cosmosgpu' ]
    then
        echo NODEFILE=\"nodelist_\$PBS_JOBID\"
        echo "#" Building nodelist
        echo "echo \"group main\" > \$NODEFILE"
        echo for node in \`uniq \$PBS_NODEFILE\`
        echo do
        echo    "echo \"host \$node ++cpus 20\" >> \$NODEFILE"
        echo done
fi


echo " "
echo if [ $first == First ]
echo     then
echo         "${vmddir}/vmd -dispdev text -e makexsc.tcl    -args $name $pwddir \$i  0    0  300  &> makexsc.out"
echo         "${vmddir}/vmd -dispdev text -e getcharges.tcl -args $name $pwddir \$i $cation $anion First &> getcharges.out"
echo         "${vmddir}/vmd -dispdev text -e selections.tcl -args $name $pwddir \$i $cation $anion First &> selections.out"
echo         "./confgen.sh $name \$i \$((i-1)) $pwddir First &> $name.\$i.conf" 
echo         "echo '"#" SIMULATION_NUMBER ACCUMULATED_TIME SIMULATION_TIME CRASH/FIRST' &> restart.dat"
echo         "echo "\$i 0 0 FIRST" &>> restart.dat"
echo     else
echo        "i=\`tail -1 restart.dat | awk '{print \$1}'\`"
echo        "((i++))"
echo fi
echo " "
echo while [ True ]
echo     do
echo " "
echo    "${namdbin} $name.\$i.conf &> $name.\$i.out"
echo " "
echo     "if [[ \`grep -c 'FATAL ERROR' $name.\$i.out\` != 0 ]]"
echo         then
echo            "if [[ \`grep -c 'PleaseCrash' $name.\$i.out\` != 0 ]]"
echo                then
echo                    "${vmddir}/vmd -dispdev text -e make_restart.tcl -args $name $pwddir \$i $cation $anion &> make_restart.\$i.out" 
echo                    "./confgen.sh $name \$((i+1)) \$i $pwddir True &> $name.\$((i+1)).conf"
echo                else
echo                    "echo FATAL ERROR"
echo                    break
echo            fi
echo        else
echo             "./confgen.sh $name \$((i+1)) \$i $pwddir False &> $name.\$((i+1)).conf"
echo             "echo \"\`tail -1 charges.dat | awk '{print \$1, \$2, \$3, \$4}'\` 0 0\" &>> charges.dat"
echo     fi
echo " "
echo         "((i++))"
echo " "
echo     done

if [ $machine == 'cosmosgpu' ]
    then
    echo rm \$NODEFILE
fi
