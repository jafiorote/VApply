#ions arguments : name, path, sys_num, cation, anion, first

set name [lindex $argv 0]
set pwddir [lindex $argv 1]
set i [lindex $argv 2]
set cation [lindex $argv 3]
set anion [lindex $argv 4]
set first [lindex $argv 5]

set prev [expr $i - 1]

set molid [mol new $pwddir/$name.0.psf]
mol addfile $pwddir/$name.0.pdb

#get selections
set popc_sel [atomselect $molid "resname POPC and name P"]
set zref [lindex [measure center $popc_sel] 2]
set posup_sel [atomselect $molid "((name CZ and resname ARG) or (name NZ and resname LYS) or (resname $cation)) and z > $zref"]
set posdown_sel [atomselect $molid "((name CZ and resname ARG) or (name NZ and resname LYS) or (resname $cation)) and z <= $zref"]
set negup_sel [atomselect $molid "((name CD and resname GLU) or (name CG and resname ASP) or (resname $anion)) and z > $zref"]
set negdown_sel [atomselect $molid "((name CD and resname GLU) or (name CG and resname ASP) or (resname $anion)) and z <= $zref"]

#get list of serial
set popc_serial [$popc_sel get serial]
set posup_serial [$posup_sel get serial]
set posdown_serial [$posdown_sel get serial]
set negup_serial [$negup_sel get serial]
set negdown_serial [$negdown_sel get serial]

#write in serial_file.dat
set serial_file [open "serialfile.$prev.tcl" w]
puts $serial_file "set zidref { $popc_serial }"
puts $serial_file "set prevPOSup { $posup_serial }"
puts $serial_file "set prevPOSdown { $posdown_serial }"
puts $serial_file "set prevNEGup { $negup_serial }"
puts $serial_file "set prevNEGdown { $negdown_serial }"
close $serial_file

exit
