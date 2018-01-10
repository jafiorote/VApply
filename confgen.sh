#!/bin/bash
name=$1
srun=$2
prev=$3
pwddcd=$4
crash=$5
echo "#"NAMD CONFIGURATION FILE
echo " "
echo "#"initial config  
echo set n_run $srun
echo set prev $prev
echo structure            	$pwddcd/$name.0.psf
if  [[ $crash == True ]]  
    then
        echo coordinates            $pwddcd/$name.$prev.pdb
    elif [[ $crash == First ]]
    then
        echo coordinates            $pwddcd/$name.0.pdb
    else
        echo coordinates       		$pwddcd/$name.0.pdb 
        echo bincoordinates       		$pwddcd/$name.$prev"r".coor 
        echo binvelocities       		$pwddcd/$name.$prev"r".vel 
fi
echo extendedsystem			$pwddcd/$name.$prev"r".xsc
echo " "
echo langevin on
echo langevintemp 300
echo langevindamping 0.1
if  [[ $crash != False ]]
    then
        echo temperature  300
        echo reassignfreq 100			;# Only for initial
        echo reassigntemp 273			;# Only for initial
        echo reassignincr 0.271 		;# Only for initial
        echo reassignhold 300  			;# Only for initial
fi

echo " "
echo "#" Pressure control
echo usegrouppressure yes
echo useflexiblecell no
echo langevinpiston off
echo langevinpistontarget 1
echo langevinpistonperiod 200
echo langevinpistondecay 100
echo langevinpistontemp 300
echo surfacetensiontarget 0.0
echo strainrate 0. 0. 0.

echo "#" brnch_root_list_opt
echo splitpatch hydrogen
echo hgroupcutoff 2.8

echo " "
echo "#"output params 
echo binaryoutput         	no 
echo outputname           	$name.$srun 
if [[ $crash != False ]]
    then
        echo outputenergies 10000
        echo outputtiming 10000
        echo outputpressure 10000
        echo binaryrestart yes
        echo dcdfile $name.$srun.dcd
        echo dcdfreq 5000
        echo XSTFreq 5000
        echo restartname $name.$srun"r"
        echo restartfreq 5000
    else 
        echo outputenergies 10000
        echo outputtiming 10000
        echo outputpressure 10000
        echo binaryrestart yes
        echo dcdfile $name.$srun.dcd
        echo dcdfreq 5000
        echo XSTFreq 5000
        echo restartname $name.$srun"r" 
        echo restartfreq 5000
fi

echo ""#"reading serials
source serialfile.$prev.tcl"

echo " "
echo "#"net charge
echo set q0 48.0
echo set timefreq 0
echo set dtimefreq 5000
echo set time 0
echo set forward 0
echo " "

echo "#" PME parameters
echo PME on
echo PMETolerance 10e-6
echo PMEInterpOrder 4
echo PMEGridSpacing 1.2
echo " "

echo "#"integrator params 
echo timestep             	2.0
echo fullElectFrequency 2
echo nonbondedfreq 1
echo " "

echo "#"force field params 
echo paratypecharmm       	on
echo parameters           	/home/lcirqueira/Simulations/namd/charmm/toppar_c36/par_all36_prot.prm
echo parameters           	/home/lcirqueira/Simulations/namd/charmm/toppar_c36/toppar_water_ions.str
echo parameters           	/home/lcirqueira/Simulations/namd/charmm/toppar_c36/par_all36_lipid.prm
echo exclude              	scaled1-4
echo 1-4scaling           	1.0
echo rigidbonds           	all          # SHAKE
echo rigidtolerance       	0.00001      # SHAKE
echo rigiditerations      	400          # SHAKE
echo cutoff               	11.0
echo pairlistdist         	13.0
echo stepspercycle        	16
echo switching            	on
echo switchdist           	8.0
echo " "

echo "#" stopNAMD after conduction through the SF
if [[ $crash != False ]]
    then
        echo set mini_steps  80
        echo set run_steps 9920
    else
        echo set mini_steps 0
        echo set run_steps 150000
fi
echo " "
echo TclForces            on
echo TclForcesScript      stopNAMDja.tcl
echo set tolerance 2.0
echo " "
if [[ $crash != False ]]
    then
	echo minimize \$mini_steps
    else
	echo "#"minimize \$mini_steps
fi
echo run \$run_steps

