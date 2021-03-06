# -*- tcl -*-
## (c) 2021 Andreas Kupries
# # ## ### ##### ######## ############# #####################
## Utility functions for the tests.

proc cat {path} {
    set c [open $path r]
    fconfigure $c -encoding binary -translation binary
    set d [read $c]
    close $c
    return $d
}

proc td {} { tcltest::testsDirectory }

proc v {label args} { V $label $args }

proc V {label map} {
    set path [P $label]
    if {[file exists $path]} {
	return [M $map [tcltest::viewFile $path]]
    } else {
	return {}
    }
}
proc M  {map x}  { string map $map $x }
proc M' {x args} { string map $args $x }
proc P  {label}  { return [td]/results/${label} }

# # ## ### ##### ######## ############# #####################
return
