#!/bin/sh
# -*- tcl -*- \
exec tclsh "$0" ${1+"$@"}
package require Tcl 8.5
set me [file normalize [info script]]
set packages {
    tclyaml
}
proc main {} {
    global argv tcl_platform tag
    set tag {}
    if {![llength $argv]} {
	if {$tcl_platform(platform) eq "windows"} {
	    set argv gui
	} else {
	    set argv help
	}
    }
    if {[catch {
	eval _$argv
    }]} usage
    exit 0
}
proc usage {{status 1}} {
    global errorInfo
    if {($errorInfo ne {}) &&
	![string match {invalid command name "_*"*} $errorInfo]
    } {
	puts stderr $::errorInfo
	exit
    }

    global argv0
    set prefix "Usage: "
    foreach c [lsort -dict [info commands _*]] {
	set c [string range $c 1 end]
	if {[catch {
	    H${c}
	} res]} {
	    puts stderr "$prefix$argv0 $c args...\n"
	} else {
	    puts stderr "$prefix$argv0 $c $res\n"
	}
	set prefix "       "
    }
    exit $status
}
proc tag {t} {
    global tag
    set tag $t
    return
}
proc myexit {} {
    tag ok
    puts DONE
    return
}
proc log {args} {
    global tag
    set newline 1
    if {[lindex $args 0] eq "-nonewline"} {
	set newline 0
	set args [lrange $args 1 end]
    }
    if {[llength $args] == 2} {
	lassign $args chan text
	if {$chan ni {stdout stderr}} {
	    ::_puts {*}[lrange [info level 0] 1 end]
	    return
	}
    } else {
	set text [lindex $args 0]
	set chan stdout
    }
    # chan <=> tag, if not overriden
    if {[string match {Files left*} $text]} {
	set tag warn
	set text \n$text
    }
    if {$tag eq {}} { set tag $chan }
    #::_puts $tag/$text

    .t insert end-1c $text $tag
    set tag {}
    if {$newline} { 
	.t insert end-1c \n
    }

    update
    return
}
proc +x {path} {
    catch { file attributes $path -permissions u+x }
    return
}
proc grep {file pattern} {
    set lines [split [read [set chan [open $file r]]] \n]
    close $chan
    return [lsearch -all -inline -glob $lines $pattern]
}
proc version {file} {
    #puts GREP\t[join [grep $file {*package provide *}] \nGREP\t]
    set v [lindex [grep $file {*package provide *}] 0 3]
    puts "Version:  $v"
    return $v
}
proc Hhelp {} { return "\n\tPrint this help" }
proc _help {} {
    usage 0
    return
}
proc Hrecipes {} { return "\n\tList all brew commands, without details." }
proc _recipes {} {
    set r {}
    foreach c [info commands _*] {
	lappend r [string range $c 1 end]
    }
    puts [lsort -dict $r]
    return
}
proc Hdrop {} { return "?destination?\n\tUninstall all packages.\n\tdestination = path of package directory, default \[info library\]." }
proc _drop {{ldir {}}} {
    global packages
    if {[llength [info level 0]] < 2} {
	set ldir [info library]
	set idir [file dirname [file dirname $ldir]]/include
    } else {
	set idir [file dirname $ldir]/include
    }

    foreach p $packages {
	set src     [file dirname $::me]/$p.tcl
	set version [version $src]

	file delete -force $ldir/$p$version
	puts -nonewline "Removed package:     "
	tag ok
	puts $ldir/$p$version
    }
    return
}
proc Hdoc {} { return "\n\t(Re)Generate the embedded documentation." }
proc _doc {} {
    cd [file dirname $::me]/doc

    puts "Removing old documentation..."
    file delete -force ../embedded/man
    file delete -force ../embedded/www

    puts "Generating man pages..."
    exec 2>@ stderr >@ stdout dtplite        -o ../embedded/man -ext n nroff .
    puts "Generating 1st html..."
    exec 2>@ stderr >@ stdout dtplite -merge -o ../embedded/www html .
    puts "Generating 2nd html, resolving cross-references..."
    exec 2>@ stderr >@ stdout dtplite -merge -o ../embedded/www html .

    return
}
proc Hinstall {} { return "?destination?\n\tInstall all packages.\n\tdestination = path of package directory, default \[info library\]." }
proc _install {{ldir {}} {config {}}} {
    global packages
    if {$ldir eq {}} {
	set ldir [info library]
	set idir [file dirname [file dirname $ldir]]/include
    } else {
	set idir [file dirname $ldir]/include
    }

    # Create directories, might not exist.
    file mkdir $idir
    file mkdir $ldir

    foreach p $packages {
	set src     [file dirname $::me]/$p.tcl
	set version [version $src]

	file delete -force [pwd]/BUILD.$p

	if {$config ne {}} {
	    RunCritcl -target $config -cache [pwd]/BUILD.$p -libdir $ldir -includedir $idir -pkg $src
	} else {
	    RunCritcl -cache [pwd]/BUILD.$p -libdir $ldir -includedir $idir -pkg $src
	}

	if {![file exists $ldir/$p]} {
	    set ::NOTE {warn {DONE, with FAILURES}}
	    break
	}

	file delete -force $ldir/$p$version
	file rename        $ldir/$p $ldir/$p$version

	puts -nonewline "Installed package:     "
	tag ok
	puts $ldir/$p$version
	puts ""
    }
    return
}
proc Hdebug {} { return "?destination?\n\tInstall debug builds of all packages.\n\tdestination = path of package directory, default \[info library\]." }
proc _debug {{ldir {}} {config {}}} {
    global packages
    if {$ldir eq {}} {
	set ldir [info library]
	set idir [file dirname [file dirname $ldir]]/include
    } else {
	set idir [file dirname $ldir]/include
    }

    # Create directories, might not exist.
    file mkdir $idir
    file mkdir $ldir

    foreach p $packages {
	set src     [file dirname $::me]/$p.tcl
	set version [version $src]

	file delete -force [pwd]/BUILD.$p
	if {$config ne {}} {
	    RunCritcl -target $config -keep -debug symbols -cache [pwd]/BUILD.$p -libdir $ldir -includedir $idir -pkg $src
	} else {
	    RunCritcl -keep -debug symbols -cache [pwd]/BUILD.$p -libdir $ldir -includedir $idir -pkg $src
	}

	file delete -force $ldir/$p$version
	file rename        $ldir/$p $ldir/$p$version

	puts -nonewline "Installed package:     "
	tag ok
	puts $ldir/$p$version
    }
    return
}
proc Hgui {} { return "\n\tInstall all packages.\n\tDone from a small GUI." }
proc _gui {} {
    global INSTALLPATH
    package require Tk
    package require widget::scrolledwindow

    wm protocol . WM_DELETE_WINDOW ::_exit

    label  .l -text {Install Path: }
    entry  .e -textvariable ::INSTALLPATH
    button .i -command Install -text Install
    button .d -command Install -text Debug

    widget::scrolledwindow .st -borderwidth 1 -relief sunken
    text   .t
    .st setwidget .t

    .t tag configure stdout -font {Helvetica 8}
    .t tag configure stderr -background red    -font {Helvetica 12}
    .t tag configure ok     -background green  -font {Helvetica 8}
    .t tag configure warn   -background yellow -font {Helvetica 12}

    grid .l  -row 0 -column 0 -sticky new
    grid .e  -row 0 -column 1 -sticky new
    grid .i  -row 0 -column 2 -sticky new
    grid .st -row 1 -column 0 -sticky swen -columnspan 2

    grid rowconfigure . 0 -weight 0
    grid rowconfigure . 1 -weight 1

    grid columnconfigure . 0 -weight 0
    grid columnconfigure . 1 -weight 1
    grid columnconfigure . 2 -weight 0

    set INSTALLPATH [info library]

    # Redirect all output into our log window, and disable uncontrolled exit.
    rename ::puts ::_puts
    rename ::log ::puts
    rename ::exit   ::_exit
    rename ::myexit ::exit

    # And start to interact with the user.
    vwait forever
    return
}
proc Install {} {
    global INSTALLPATH NOTE
    .i configure -state disabled
    .d configure -state disabled

    set NOTE {ok DONE}
    set fail [catch {
	_install $INSTALLPATH

	puts ""
	tag  [lindex $NOTE 0]
	puts [lindex $NOTE 1]
    } e o]

    .i configure -state normal
    .d configure -state normal
    .i configure -command ::_exit -text Exit -bg green

    if {$fail} {
	# rethrow
	return {*}$o $e
    }
    return
}
proc Debug {} {
    global INSTALLPATH
    .i configure -state disabled
    .d configure -state disabled

    set fail [catch {
	_debug $INSTALLPATH

	puts ""
	tag ok
	puts DONE
    } e o]

    .i configure -state normal
    .d configure -state normal
    .d configure -command ::_exit -text Exit -bg green

    if {$fail} {
	# rethrow
	return {*}$o $e
    }
    return
}
proc Hwrap4tea {} { return "?destination?\n\tGenerate source packages with TEA-based build system wrapped around critcl.\n\tdestination = path of source package directory, default is sub-directory 'tea' of the CWD." }
proc _wrap4tea {{dst {}}} {
    global packages
    if {[llength [info level 0]] < 2} {
	set dst [file join [pwd] tea]
    }

    # Generate TEA directory hierarchies

    foreach p $packages {
	set src     [file dirname $::me]/$p.tcl
	set version [version $src]

	file delete -force [pwd]/BUILD.$p
	RunCritcl   -cache [pwd]/BUILD.$p -libdir $dst -tea $src
	file delete -force $dst/$p$version
	file rename        $dst/$p $dst/$p$version

	puts "Installed package:     $dst/$p$version"
	puts ""
    }
    return
}

proc RunCritcl {args} {
    #puts [info level 0]
    if {![catch {
	package require critcl::app 3.1
    }]} {
	#puts "......... [package ifneeded critcl::app [package present critcl::app]]"
	critcl::app::main $args
	return
    } else {
	foreach cmd {
	    critcl3 critcl3.kit critcl3.tcl critcl3.exe
	    critcl critcl.kit critcl.tcl critcl.exe
	} {
	    # Locate the candidate.
	    set cmd [auto_execok $cmd]

	    # Ignore applications which were not found.
	    if {![llength $cmd]} continue

	    # Proper native path needed, especially on windows. On
	    # windows this also works (best) with a starpack for
	    # critcl, instead of a starkit.

	    set cmd [file nativename [lindex [auto_execok $cmd] 0]]

	    # Ignore applications which are too old to support
	    # -v|--version, or are too old as per their returned
	    # version.
	    if {[catch {
		set v [eval [list exec $cmd --version]]
	    }] || ([package vcompare $v 3.1] < 0)} continue

	    # Perform the requested action.
	    set cmd [list exec 2>@ stderr >@ stdout $cmd {*}$args]
	    #puts "......... $cmd"
	    eval $cmd
	    return
	}
    }

    puts "Unable to find a usable critcl 3 application (package). Stop."
    ::exit 1
}

main
