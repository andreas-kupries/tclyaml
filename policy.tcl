# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## Tcl level.

package require TclOO

# # ## ### ##### ######## #############
## Parser wrapping, and conveniences.

namespace eval ::tclyaml {
    namespace export read readTags write writeTags version type
    namespace ensemble create
}
namespace eval ::tclyaml::read {
    namespace export channel file
    namespace ensemble create
}
namespace eval ::tclyaml::readTags {
    namespace export channel file
    namespace ensemble create
}
namespace eval ::tclyaml::write {
    namespace export channel file string deftype
    namespace ensemble create
}
namespace eval ::tclyaml::write::type {
}
namespace eval ::tclyaml::writeTags {
    namespace export channel file string
    namespace ensemble create
}

# # ## ### ##### ######## #############

proc ::tclyaml::type {value} {
    set type string
    if {$value in {{} null NULL Null ~}} {
	set type null
	set value {}
    } elseif {$value in {true True TRUE false False FALSE}} {
	set type bool
	set value [expr {$value ? "true" : "false"}]
    } elseif {[regexp -- {^[+-]?[0-9]+$} $value]} {
	set type int
    } elseif {[regexp -- {^0o[0-7]+$} $value]} {
	set type int
	set value [expr $value]
    } elseif {[regexp -- {^0x[0-9a-fA-F]+$} $value]} {
	set type int
	set value [expr $value]
    } elseif {[regexp -- {^[-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?$} $value]} {
	set type float
	set value [expr $value]
    } elseif {[regexp -- {^([+-]?)(\.inf|\.Inf|\.INF)$} $value _ sign]} {
	set type float
	set value ${sign}Inf
    } elseif {$value in {.nan .NaN .NAN}} {
	set type float
	set value NaN
    }
    return [list $type $value]
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

proc ::tclyaml::read::channel {chan} {
    set reader [::tclyaml::reader new]
    catch {
	$reader channel $chan
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

proc ::tclyaml::readTags::channel {chan} {
    set reader [::tclyaml::taggedreader new]
    catch {
	$reader channel $chan
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
	return -code error -errorcode {YAML READ ALIAS NOT IMPLEMENTED} \
	    "Currently not able to handle aliases"
    }

    method scalar {details} {
	# details = (
	#   anchor          -> string
	#   tag             -> string
	#   scalar          -> string
	#   plain-implicit  -> bool
	#   quoted-implicit -> bool
	#   style           -> enum (any, plain, single, double, literal, folded)
	# )

	# We use type detection here only to perform normalization of
	# the value.

	dict with details {}
	if { ${quoted-implicit} } {
	    # Attention! Quoting prevents the application of the
	    # implicit typing rules.
	} else {
	    lassign [::tclyaml type $scalar] _ scalar
	}

	lappend mybuffer $scalar
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
	return -code error -errorcode {YAML READ ALIAS NOT IMPLEMENTED} \
	    "Currently not able to handle aliases"
    }

    method scalar {details} {
	# details = (
	#   anchor          -> string
	#   tag             -> string
	#   scalar          -> string
	#   plain-implicit  -> bool
	#   quoted-implicit -> bool
	#   style           -> enum (any, plain, single, double, literal, folded)
	# )
	dict with details {}
	set type string
	if { ${quoted-implicit} } {
	    # Attention! Quoting prevents the application of the
	    # implicit typing rules.
	} else {
	    lassign [::tclyaml type $scalar] type scalar
	}

	lappend mybuffer [list $type $scalar]
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

    method scalar {type value {anchor {}} {tag {}}} {
	# Determine styling based on type and, in case of string,
	# actual value as well.
	set plain  1
	set quoted 0
	set style  $myscalarstyle
	switch -exact -- $type {
	    int    {
		set value [expr $value]
	    }
	    float  {
		if {$value eq "Inf"} {
		    set value .inf
		} elseif {$value eq "-Inf"} {
		    set value -.inf
		} elseif {$value in {NaN -NaN}} {
		    set value .nan
		} else {
		    set value [expr $value]
		}
	    }
	    bool   { set value [expr {$value ? "true" : "false"}] }
	    null   { set value null }
	    string {
		# Quote only strings which would be mistaken for a
		# different type of value without them.
		lassign [::tclyaml type $value] itype _
		if {$itype ne $type} {
		    set quoted 1
		}
		# Further, restyle multi-line strings.
		if {[string match *\n* $value]} {
		    set style literal
		    set quoted 1
		}
	    }
	}
	if {$quoted} { set plain 0 }
	E scalar $anchor $tag $value $plain $quoted $style
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

proc ::tclyaml::writeTags::channel {chan value} {
    set data [Core $value]
    puts -nonewline $chan $data
    flush $chan
    return
}

proc ::tclyaml::writeTags::file {path value} {
    set data [Core $value]
    set chan [open $path w]
    puts -nonewline $chan $data
    close $chan
    return
}

proc ::tclyaml::writeTags::string {value} {
    return [Core $value]
}

proc ::tclyaml::writeTags::Core {value} {
    if {$value eq {}} {
	# Fast return for nothing
	return
    }
    set writer [::tclyaml::writer new]
    catch {
	$writer stream-start
	$writer document-start

	Convert $writer $value

	$writer document-end
	$writer stream-end
	$writer yaml
    } e o
    $writer destroy
    return {*}$o $e
}

proc ::tclyaml::writeTags::Convert {writer value} {
    lassign $value tag spec
    switch -exact -- $tag {
	int - float - bool - null - string {
	    $writer scalar $tag $spec
	}
	sequence {
	    $writer sequence-start
	    foreach element $spec {
		Convert $writer $element
	    }
	    $writer sequence-end
	}
	mapping {
	    $writer mapping-start
	    # Attention! The writer normalizes the key order
	    # (dictionary sorting), pre-quoting.
	    foreach k [lsort -dict -index 1 [dict keys $spec]] {
		Convert $writer $k
		Convert $writer [dict get $spec $k]
	    }
	    $writer mapping-end
	}
	default {
	    return -code error -errorcode {YAML WRITE-TAGS BAD TAG} \
		"Bad tag $tag"
	}
    }
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

proc ::tclyaml::write::string {def value} {
    return [Core $def $value]
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

	type::__convert $writer $structure $value

	$writer document-end
	$writer stream-end
	$writer yaml
    } e o
    $writer destroy
    return {*}$o $e
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

proc ::tclyaml::write::type::int {writer structure value} {
    if {![::string is int -strict $value]} {
	return -code error -errorcode {YAML WRITE BAD INT} \
	    "Expected an integer, got \"$value\""
    }
    $writer scalar int $value
    return
}

proc ::tclyaml::write::type::float {writer structure value} {
    if {![::string is double -strict $value]} {
	return -code error -errorcode {YAML WRITE BAD INT} \
	    "Expected a double, got \"$value\""
    }
    $writer scalar float $value
    return
}

proc ::tclyaml::write::type::bool {writer structure value} {
    $writer scalar bool [expr {$value ? "true" : "false"}]
    return
}

proc ::tclyaml::write::type::null {writer structure value} {
    $writer scalar null null
    return
}

proc ::tclyaml::write::type::string {writer structure value} {
    $writer scalar string $value
    return
}

proc ::tclyaml::write::type::sequence {writer structure value} {
    if {$structure eq {}} { set structure {scalar {}} }

    $writer sequence-start
    foreach element $value {
	__convert $writer $structure $element
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

    foreach k [lsort -dict [::dict keys $value]] {
	if {[::dict exists $structure $k]} {
	    set valuetype [::dict get $structure $k]
	} else {
	    set valuetype $defaulttype
	}

	__convert $writer scalar     $k
	__convert $writer $valuetype [::dict get $value $k]
    }

    $writer mapping-end
    return
}

interp alias {} ::tclyaml::write::type::scalar {} ::tclyaml::write::type::string
interp alias {} ::tclyaml::write::type::list   {} ::tclyaml::write::type::sequence
interp alias {} ::tclyaml::write::type::array  {} ::tclyaml::write::type::sequence
interp alias {} ::tclyaml::write::type::dict   {} ::tclyaml::write::type::mapping
interp alias {} ::tclyaml::write::type::object {} ::tclyaml::write::type::mapping

# # ## ### ##### ######## #############
return
