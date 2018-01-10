#VMD args : name, path, sys_num, cation, anion, first
#set name kv1.12-eq
#set pwddir /home/lcirqueira/Simulations/ionchannel/kv1/kv1.12/jhosoume/efield/stopnamd/vapplytest/qsub/namd
#set i 4

set name [lindex $argv 0]
set pwddir [lindex $argv 1]
set i [lindex $argv 2]
set cation [lindex $argv 3]
set anion [lindex $argv 4]
set first [lindex $argv 5]


proc getcharges { {molid top} {cation} {anion} } {

    set refsel [atomselect $molid "resname POPC"]
    set zref [lindex [measure center $refsel] 2]

    set catup_sel [atomselect $molid "resname $cation and z > $zref"]
    set n_catup [$catup_sel num]

    set catdown_sel [atomselect $molid "resname $cation and z<= $zref"]
    set n_catdown [$catdown_sel num]


    set aniup_sel [atomselect $molid "resname $anion and z > $zref"]
    set n_aniup [$aniup_sel num]

    set anidown_sel [atomselect $molid "resname $anion and z<= $zref"]
    set n_anidown [$anidown_sel num]


    set posprot_up_sel [atomselect $molid "((name CZ and resname ARG) or (name NZ and resname LYS)) and z > $zref"]
    set n_posprotup [$posprot_up_sel num]

    set posprot_down_sel [atomselect $molid "((name CZ and resname ARG) or (name NZ and resname LYS)) and z <= $zref"]
    set n_posprotdown [$posprot_down_sel num]


    set negprot_up_sel [atomselect $molid "((name CD and resname GLU) or (name CG and resname ASP)) and z > $zref"]
    set n_negprotup [$negprot_up_sel num]

    set negprot_down_sel [atomselect $molid "((name CD and resname GLU) or (name CG and resname ASP)) and z <= $zref"]
    set n_negprotdown [$negprot_down_sel num]

    return "[expr $n_catdown - $n_catup] [expr $n_anidown - $n_aniup] [expr $n_posprotdown - $n_posprotup] [expr $n_negprotdown - $n_negprotup]"
}

proc charges_restart { {molid top} {cation} {anion} {iondiff 0} {protdiff 0} } {

    set charge_file [open "charges.dat" a]
    puts $charge_file "[getcharges $molid $cation $anion] $iondiff $protdiff"
    close $charge_file

}

if { $first=={First} } {
    set molid [mol new $pwddir/$name.0.psf]
    mol addfile $pwddir/$name.0.pdb
    set charge_file [open "charges.dat" w]
    puts $charge_file "#cation anion arg/lys glu/asp ion_difference protein_difference"
    puts $charge_file "[getcharges $molid $cation $anion] 0 0"
    close $charge_file
}

