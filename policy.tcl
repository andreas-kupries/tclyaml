# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## Tcl level.

package require TclOO

# # ## ### ##### ######## #############
## Parser wrapping, and conveniences.

namespace eval ::tclyaml {
    namespace eval get {
	namespace export channel file
	namespace ensemble create
    }

    namespace export get
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc ::tclyaml::get::file {path} {
    set c [open $path r]
    catch {
      channel $c
    } e o
    close $c
    return {*}$o $e
}

proc ::tclyaml::get::channel {c} {
    set p [::tclyaml::parser new]
    catch {
	$p channel $c
    } e o
    $p destroy
    return {*}$o $e
}

# # ## ### ##### ######## #############

oo::class create ::tclyaml::parser {
    variable mydocs mybuffer mystack

    method channel {c} {
	# Redirect the event callback to ourself, using our methods
	# for processing the events.
	::tclyaml::parse::channel $c [self]
	return $mydocs
    }

    method none {} {}

    method stream-start {details} {
	# details = (encoding -> encoding name)
	set mydocs {}
	return
    }

    method stream-end {} {
    }

    method document-start {details} {
	# details = (
	#   implicit -> bool
	#   version -> list (int int) /optional
	#   tags -> ??? /optional, not-yet-done
	# )
	set mybuffer {}
	set mystack {}
	return
    }

    method document-end {details} {
	# details = (implicit -> bool)
	lappend mydocs $mybuffer
    }

    method alias {details} {
	# details = (anchor -> string)
	return -code error "Currently not able to handle aliases"
    }

    method scalar {details} {
	# details = (
	#   anchor          -> string
	#   tag            -> string
	#   scalar          -> string
	#   plain-implicit  -> bool
	#   quoted-implicit -> bool
	#   style           -> enum (any, plain, single, double, literal, folded)
	# )
	lappend mybuffer [dict get $details scalar]
	return
    }

    method sequence-start {details} {
	# details = (
	#   anchor   -> string
	#   tag      -> string
	#   implicit -> bool
	#   style    -> enum (any, block, flow)
	# )
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
	# details = (
	#   anchor   -> string
	#   tag      -> string
	#   implicit -> bool
	#   style    -> enum (any, block, flow)
	# )
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
