#VMD args : name, path, sys_num, cation, anion, first

set name [lindex $argv 0]
set pwddir [lindex $argv 1]
set i [lindex $argv 2]
set set_x [lindex $argv 3]
set set_y [lindex $argv 4]
set set_z [lindex $argv 5]


set molid [mol new $pwddir/$name.0.psf]
mol addfile $pwddir/$name.0.pdb

set watsel [atomselect $molid "water"]
set minmax [measure minmax $watsel]
set selcenter [measure center $watsel] 

if {$set_x} {
    set xdim $set_x
} else {
    set xdim [expr [lindex [lindex $minmax 1] 0] - [lindex [lindex $minmax 0] 0]]
}

if {$set_y} {
    set ydim $set_y
} else {
    set ydim [expr [lindex [lindex $minmax 1] 1] - [lindex [lindex $minmax 0] 1]]
}

if {$set_z} {
    set zdim $set_z
} else {
    set zdim [expr [lindex [lindex $minmax 1] 2] - [lindex [lindex $minmax 0] 2]]
}

set xscfile [open $pwddir/$name.[expr $i - 1]r.xsc w]
puts $xscfile "# NAMD extended system configuration restart file"
puts $xscfile "#\$LABELS step a_x a_y a_z b_x b_y b_z c_x c_y c_z o_x o_y o_z"
puts $xscfile "0 $xdim 0 0 0 $ydim 0 0 0 $zdim $selcenter"
close $xscfile

exit
