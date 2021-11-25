# VApply

main.sh - defines simulation parameters , starts PBS job generator and submit PBS job to queue
  usage : ./main.sh <name> <initial> <nodes> <walltime> <first=False> <depend=False> <cation> <anion> 
  MANUAL EDIT : cations , anions , PBS qsub path
  
pbsgen.sh - PBS job generator
  pbsgen.sh parameters are defined from main.sh arguments
  MANUAL EDIT: VMD directory (vmddir) , NAMD binary (namdbin) , patches per node (ppn) , processors (procs , if necessary)
  
makexsc.tcl - VMD script which generates a .xsc file

getcharges.tcl - VMD script which is capable of monitoring charges (getcharges function) and create and update "charges.dat" , a file that contains all charges informations

selections.tcl - VMD script responsible of selecting charged atoms

confgen.sh - shell script that generates NAMD configuration files
  MANUAL EDIT: parameters path

stopNAMDja.tcl - tcl script responsible of detecting ion conduction

make_restart.tcl - VMD script which is activated after ionic current ; responsible for moving an ion across the system
