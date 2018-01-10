#VMD args : name, path, sys_num, up_charge_file, cation, anion

set name [lindex $argv 0]
set pwddir [lindex $argv 1]
set i [lindex $argv 2]
set cation [lindex $argv 3]
set anion [lindex $argv 4]
set first False

set chargefile [open charges.dat r]

package require pbctools
play getcharges.tcl

set molid [mol new $pwddir/$name.0.psf]
mol addfile $pwddir/$name.${i}r.coor
pbc readxst $pwddir/$name.${i}r.xsc
pbc wrap -centersel protein -center com -compound fragment


set refsel [atomselect 0 "resname POPC"]
set watsel [atomselect 0 "water"]
set zref [lindex [measure center $refsel] 2]
set minmax [measure minmax $watsel]

while {[gets $chargefile line] != -1} {
    set reflist $line
}

set charges_list [getcharges $molid $cation $anion]

set iondiff [expr ([lindex $charges_list 0] - [lindex $charges_list 1]) - ([lindex $reflist 0] - [lindex $reflist 1])]
set protdiff [expr ([lindex $charges_list 2] - [lindex $charges_list 3]) - ([lindex $reflist 2] - [lindex $reflist 3])]

for {set j 0} {$j <= [llength $charges_list]} {incr j} {
    if {[lindex $reflist $j] != [lindex $charges_list $j]} { 
        set diff [expr [lindex $charges_list $j] - [lindex $reflist $j]]
        break 
    }
}

if {$j == [llength $charges_list]} {
    puts "CHARGE DIFFERENCE NOT DETECTED. KEEPING SAME VOLTAGE"
    puts "ATOM MOVED : none"
} else {
    set listion [list $cation $anion $cation $anion]
    set namelist [list $cation $anion "arg/lys" "glu/asp"]
    if {$diff > 0} {
        set slabsel [atomselect $molid "resname [lindex $listion $j] and z < [expr $zref - 40]"]
    } else { 
        set slabsel [atomselect $molid "resname [lindex $listion $j] and z > [expr $zref + 40]"]
    }
    set ionsel [atomselect $molid "serial [lindex [$slabsel get serial] 0]"]
    puts "CHARGE DIFFERENCE DONE BY [lindex $namelist $j]: [lindex $charges_list $j]  ; reference [lindex $reflist $j] "
    puts "ATOM MOVED : resname [lindex $listion $j] and serial [lindex [$slabsel get serial] 0]" 
    set zion [lindex [measure center $ionsel] 2]
    set vect "0 0 [expr -2 * ($zion - $zref)]"
    $ionsel moveby $vect
}

[atomselect $molid all] writepdb $name.$i.pdb 

charges_restart $molid $cation $anion $iondiff $protdiff

exit
