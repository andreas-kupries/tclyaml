# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## Tcl level.

package require TclOO

# # ## ### ##### ######## #############
## Parser wrapping, and conveniences.

namespace eval ::tclyaml {
    namespace eval get {
	namespace export channel
	namespace ensemble create
    }

    namespace export get
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc ::tclyaml::get::channel {c} {
    set p [::tclyaml::parser new]
    set data [$p channel $c]
    $p destroy
    return $data
}

# # ## ### ##### ######## #############

oo::class create ::tclyaml::parser {
    variable mybuffer mystack

    method channel {c} {
	::tclyaml::parse::channel $c [self]
	return $mybuffer
    }

    method none {} {}

    method stream-start {details} {
    }

    method stream-end {} {
    }

    method document-start {details} {
	set mybuffer {}
	set mystack {}
	return
    }

    method document-end {details} {
    }

    method alias {details} {
    }

    method scalar {details} {
	lappend mybuffer [dict get $details scalar]
	return
    }

    method sequence-start {details} {
	lappend mystack $mybuffer
	set mybuffer {}
	return
    }

    method sequence-end {} {
	set previous [lindex $mystack end]
	lappend previous $mybuffer
	set mybuffer $previous
	set mystack [lrange $mystack 0 end-1]
	return
    }

    method mapping-start {details} {
	lappend mystack $mybuffer
	set mybuffer {}
	return
    }

    method mapping-end {} {
	set previous [lindex $mystack end]
	lappend previous $mybuffer
	set mybuffer $previous
	set mystack [lrange $mystack 0 end-1]
	return
    }
}

# # ## ### ##### ######## #############
