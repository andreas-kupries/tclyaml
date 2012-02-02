# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## Tcl level.

package require TclOO

# # ## ### ##### ######## #############
## Parser wrapping, and conveniences.

namespace eval ::tclyaml {
    namespace eval read {
	namespace export channel file
	namespace ensemble create
    }

    namespace eval readTags {
	namespace export channel file
	namespace ensemble create
    }

    namespace eval write {
	namespace export channel file deftype
	namespace ensemble create
    }

    namespace export read readTags write
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc ::tclyaml::read::file {path} {
    set c [open $path r]
    catch {
      channel $c
    } e o
    close $c
    return {*}$o $e
}

proc ::tclyaml::read::channel {c} {
    set reader [::tclyaml::reader new]
    catch {
	$reader channel $c
    } e o
    $reader destroy
    return {*}$o $e
}

# # ## ### ##### ######## #############

proc ::tclyaml::readTags::file {path} {
    set c [open $path r]
    catch {
      channel $c
    } e o
    close $c
    return {*}$o $e
}

proc ::tclyaml::readTags::channel {c} {
    set reader [::tclyaml::taggedreader new]
    catch {
	$reader channel $c
    } e o
    $reader destroy
    return {*}$o $e
}

# # ## ### ##### ######## #############

oo::class create ::tclyaml::reader {
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

oo::class create ::tclyaml::taggedreader {
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
	lappend mybuffer [list scalar [dict get $details scalar]]
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
	lappend previous [list sequence $mybuffer]
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
	lappend previous [list mapping $mybuffer]
	set mybuffer $previous
	set mystack [lrange $mystack 0 end-1]
	return
    }
}

# # ## ### ##### ######## #############

oo::class create ::tclyaml::writer {
    constructor {} {
	::tclyaml::Emitter create E
	set myblockstyle  any
	set myscalarstyle any
	return
    }

    # # ## ### ##### ######## #############

    forward yaml         E yaml
    forward stream-start E stream_start
    forward stream-end   E stream_end

    forward sequence-end E sequence_end
    forward mapping-end  E mapping_end
    forward alias        E alias

    method document-start {{implicit 1}} {
	E document_start $implicit
	return
    }

    method document-end {{implicit 1}} {
	E document_end $implicit
	return
    }

    method sequence-start {{anchor {}} {tag {}} {implicit 1}} {
	E sequence_start $anchor $tag $implicit $myblockstyle
	return
    }

    method mapping-start {{anchor {}} {tag {}} {implicit 1}} {
	E mapping_start $anchor $tag $implicit $myblockstyle
	return
    }

    method scalar {value {anchor {}} {tag {}} {plain 1} {quoted 1}} {
	E scalar $anchor $tag $value $plain $quoted $myscalarstyle
	return
    }

    # # ## ### ##### ######## #############

    method blockstyle {style} {
	set myblockstyle $style
	return
    }

    method scalarstyle {style} {
	set myscalarstyle $style
	return
    }

    variable myblockstyle myscalarstyle
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
## Todo: Configuration of styling.

proc ::tclyaml::write::channel {def chan value} {
    set data [Core $def $value]
    puts -nonewline $chan $data
    flush $chan
    return
}

proc ::tclyaml::write::file {def path value} {
    set data [Core $def $value]
    set chan [open $path w]
    puts -nonewline $chan $data
    close $chan
    return
}

proc ::tclyaml::write::deftype {name arguments body} {
    proc ::tclyaml::write::type::$name \
	[linsert $arguments end writer structure value] \
	$body
    return
}

# # ## ### ##### ######## #############

proc ::tclyaml::write::Core {structure value} {
    set writer [::tclyaml::writer new]

    catch {
	$writer stream-start
	$writer document-start

	__convert $writer $structure $value

	$writer document-end
	$writer stream-end
	$writer yaml
    } e o
    $writer destroy
    return {*}$o $e
}

namespace eval ::tclyaml::write::type {
    namespace export __convert
}

proc ::tclyaml::write::type::__convert {writer structure value} {
    if {[llength $structure] == 1} {
	lappend structure {}
	lassign $structure cmd detail
    } else {
	set cmd    [lrange $structure 0 end-1]
	set detail [lindex $structure end]
    }

    {*}$cmd $writer $detail $value
    return
}

proc ::tclyaml::write::type::scalar {writer structure value} {
    $writer scalar $value
    return
}

proc ::tclyaml::write::type::sequence {writer structure value} {
    if {$structure eq {}} { set structure {scalar {}} }

    $writer sequence-start
    foreach element $value {
	__convert $writer $structure $value
    }
    $writer sequence-end
    return
}

proc ::tclyaml::write::type::mapping {writer structure value} {
    $writer mapping-start

    if {[::dict exists $structure *]} {
	set defaulttype [::dict get $structure *]
    } else {
	set defaulttype scalar
    }

    set keys [lsort -dict [::dict keys $value]]
    foreach k $keys {
	if {[::dict exists $structure $k]} {
	    set vtype [::dict get $structure $k]
	} else {
	    set vtype $defaulttype
	}

	__convert $writer scalar $k
	__convert $writer $vtype [::dict get $value $k]
    }

    $writer mapping-end
    return
}

interp alias {} ::tclyaml::write::type::string {} ::tclyaml::write::type::scalar
interp alias {} ::tclyaml::write::type::list   {} ::tclyaml::write::type::sequence
interp alias {} ::tclyaml::write::type::array  {} ::tclyaml::write::type::sequence
interp alias {} ::tclyaml::write::type::dict   {} ::tclyaml::write::type::mapping
interp alias {} ::tclyaml::write::type::object {} ::tclyaml::write::type::mapping

# # ## ### ##### ######## #############

namespace eval ::tclyaml::write {
    namespace import ::tclyaml::write::type::__convert
}

# # ## ### ##### ######## #############
