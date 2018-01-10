###########################################################
# Plugin for TM-conduction calculation
###########################################################

# Adding and grouping atoms
foreach a $prevPOSup { addatom $a }
foreach a $prevPOSdown { addatom $a }
foreach a $prevNEGup { addatom $a }
foreach a $prevNEGdown { addatom $a }
foreach a $zidref { addatom $a } 
set gzidref [ addgroup $zidref ]

set POSup [list] 
set POSdown [list]
set NEGup [list] 
set NEGdown [list]

set timefile [open restart.dat r]
while {[gets $timefile line] != -1} {
    set total_time [lindex $line 1]
}
close $timefile

proc write_time_file { {n_run} {total_time} {time} } {
    set timefile [open restart.dat a]
    puts $timefile "$n_run [expr $total_time + $time] $time CRASH"
    close $timefile
}

proc write_serial_file { {n_run} {zidref} {POSup} {POSdown} {NEGup} {NEGdown} } {
    set serial_file [open "serialfile.$n_run.tcl" w]
    puts $serial_file "set zidref { $zidref }"
    puts $serial_file "set prevPOSup { $POSup }"
    puts $serial_file "set prevPOSdown { $POSdown }"
    puts $serial_file "set prevNEGup { $NEGup }"
    puts $serial_file "set prevNEGdown { $NEGdown }"
    close $serial_file
}

proc calcforces {} {

    global n_run prev run_steps mini_steps total_time prevPOSup prevPOSdown prevNEGup prevNEGdown zidref gzidref time timefreq dtimefreq tolerance POSup POSdown NEGup NEGdown
        
    # create list of serials at first timestep
    
    if { $time==1 } {
            
        loadcoords coor

        foreach a $prevPOSup { 
            if { [lindex $coor($a) 2] <= [expr [lindex $coor($gzidref) 2] - $tolerance] } {
                lappend POSdown $a 
		print "CONDUCTED ION : serial $a POSITIVE UP --> DOWN"
           } else {
                lappend POSup $a
           }
        }

        foreach a $prevPOSdown { 
            if { [lindex $coor($a) 2] >= [expr [lindex $coor($gzidref) 2] + $tolerance] } {
		print "CONDUCTED ION : serial $a POSITIVE DOWN --> UP"
                lappend POSup $a 
           } else {
                lappend POSdown $a
           }
        }

        foreach a $prevNEGup { 
            if { [lindex $coor($a) 2] <= [expr [lindex $coor($gzidref) 2] - $tolerance] } {
                lappend NEGdown $a  
		print "CONDUCTED ION : serial $a NEGATIVE UP --> DOWN"
           } else {
                lappend NEGup $a 
           }
        }

        foreach a $prevNEGdown { 
            if { [lindex $coor($a) 2] >= [expr [lindex $coor($gzidref) 2] + $tolerance] } {
                lappend NEGup $a
		print "CONDUCTED ION : serial $a NEGATIVE DOWN --> UP"
           } else {
                lappend NEGdown $a 
           }
        }
    }

    # verify the conduction

    #if { ($time==[expr 40 + 1]) } {
        #print "$zidref \n $POSup \n $POSdown \n $NEGup \n$NEGdown"
        #write_serial_file $n_run $zidref $POSup $POSdown $NEGup $NEGdown
        #write_time_file $n_run $total_time $time
        #print "NAMD will be stopped because I wanted"
        #PleaseCrash
    #}

    
    if { ($time==[expr $timefreq + $dtimefreq + 2]) } {
    
        loadcoords coor

        foreach a $POSup {
            if { [lindex $coor($a) 2] < [expr [lindex $coor($gzidref) 2] - $tolerance] } {

                write_serial_file $n_run $zidref $POSup $POSdown $NEGup $NEGdown
                write_time_file $n_run $total_time $time

                print "NAMD will be stopped because conduction event caused by serial $a POSITIVE UP --> DOWN"
                print "CRASH COORDINATES [lindex $coor($a) 2]  REFERENCE : [lindex $coor($gzidref) 2]"
                PleaseCrash
            }
        }
        foreach a $POSdown {
            if { [lindex $coor($a) 2] > [expr [lindex $coor($gzidref) 2] + $tolerance] } {

                write_serial_file $n_run $zidref $POSup $POSdown $NEGup $NEGdown
                write_time_file $n_run $total_time $time

                print "NAMD will be stopped because conduction event caused by serial $a POSITIVE DOWN --> UP"
                print "CRASH COORDINATES [lindex $coor($a) 2]  REFERENCE : [lindex $coor($gzidref) 2]"
                PleaseCrash
            }
        }
        foreach a $NEGup {
            if { [lindex $coor($a) 2] < [expr [lindex $coor($gzidref) 2] - $tolerance] } {

                write_serial_file $n_run $zidref $POSup $POSdown $NEGup $NEGdown
                write_time_file $n_run $total_time $time
                 
                print "NAMD will be stopped because conduction event caused by serial $a NEGATIVE UP --> DOWN"
                print "CRASH COORDINATES [lindex $coor($a) 2]  REFERENCE : [lindex $coor($gzidref) 2]"
                PleaseCrash
            }
        }
        foreach a $NEGdown {
            if { [lindex $coor($a) 2] > [expr [lindex $coor($gzidref) 2] + $tolerance] } {

                write_serial_file $zidref $POSup $POSdown $NEGup $NEGdown
                write_time_file $n_run $total_time $time

                print "NAMD will be stopped because conduction event caused by serial $a NEGATIVE DOWN --> UP"
                print "CRASH COORDINATES [lindex $coor($a) 2]  REFERENCE : [lindex $coor($gzidref) 2]"
                PleaseCrash
            }
        }
        set timefreq [expr $timefreq + $dtimefreq]
    }
    if { ($time==[expr $run_steps + $mini_steps]) } {
        set timefile [open restart.dat a]
        puts $timefile "$n_run [expr $total_time + $time] $time"
        close $timefile
	write_serial_file $n_run $zidref $POSup $POSdown $NEGup $NEGdown
    }
    incr time
}
