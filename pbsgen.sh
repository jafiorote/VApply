name=$1
initial=$2
nodes=$3
wall=$4
first=$5
cation=$6
anion=$7
pwddir=`pwd`
vmddir="PYTHONHOME=/cluster/packages/python/python-3.5.2 LD_LIBRARY_PATH=\$PYTHONHOME/lib /cluster/packages/vmd-1.9.2-minimal-python-3/bin"
namddir="/cluster/intel/impi/5.0.3.048/intel64/bin/mpirun /cluster/packages/namd_2.10_cpu_mpi"
#vmddir="/home/lcirqueira/install/tclvmd/bin"
#namddir="/home/lcirqueira/install/namd2/namd2 +idlepoll +p4"

echo "#"PBS -N $name.$initial
#echo "#"PBS -l nodes=$nodes:ppn=4
#CHECK YOUR MACHINE!
echo "#"PBS -l nodes=$nodes:ppn=40
echo "#"PBS -l pmem=300mb
echo "#"PBS -l walltime=$wall
echo "#"PBS -j eo
echo " "
echo i=$initial
echo cd $pwddir
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
echo    "${namddir}/namd2 $name.\$i.conf &> $name.\$i.out"
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
