# -*- tcl -*-
# Tclyaml = A Tcl Binding to the libyaml C library.
# Note that this doesn't export the libyaml C API as stubs.
# It directly exposes libyaml functionality to Tcl script.
#
# (c) 2012-2014 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#

# # ## ### ##### ######## #############
## Requisites

package require critcl 3.1.3 ; # need argtype "pstring"
critcl::buildrequirement {
    package require critcl::util 1
    package require critcl::class 1.0.3
}

# # ## ### ##### ######## #############

if {![critcl::compiling]} {
    error "Unable to build Tclyaml, no proper compiler found."
}

# # ## ### ##### ######## #############
## Administrivia

critcl::license \
    {Andreas Kupries} \
    {Under a BSD license.}

critcl::summary \
    {Binding to the libyaml parser/emitter library}

critcl::description {
    This package is a binding to the libyaml library.
    It exposes both parsing and writing functionality to Tcl.
}

critcl::subject yaml {parsing yaml} {emitting yaml} {writing yaml}
critcl::subject parser json serialization deserialization 
critcl::subject {data exchange format} {transfer format}

# # ## ### ##### ######## #############
## Implementation.

critcl::tcl 8.5

# # ## ### ##### ######## #############
## Access to the libyaml headers and sources
#
## Note: We are carrying a copy of libyaml in this package, and are
##       building libyaml as part of the binding.

critcl::cheaders  libyaml/include/yaml.h
critcl::cheaders  libyaml/src/yaml_private.h

# Note: Slow processing from critcl starkit, large files, and non-accelerated md5
critcl::csources  libyaml/src/*.c

# # ## ### ##### ######## #############
## Extract libyaml version number(s) out of its configure and put them
## into defines, for libyaml/src/api.c to pick up.

proc grep {glob lines} {
    set result {}
    foreach line $lines {
	if {![string match $glob $line]} continue
	lappend result $line
    }
    return $result
}

::apply {{} {
    # Get all defines in the configure
    set D [grep *m4_define* [split [critcl::Cat [critcl::Here]/libyaml/configure.ac] \n]]

    #puts \nD=[join $D \nD=]

    # Extract the defines relevant to us.
    set major [lindex [grep *YAML_MAJOR* $D] 0]
    set minor [lindex [grep *YAML_MINOR* $D] 0]
    set patch [lindex [grep *YAML_PATCH* $D] 0]

    #puts major=$major
    #puts minor=$minor
    #puts patch=$patch

    regsub m4_define $major {} major ; # Strip text containing digits.
    regsub m4_define $minor {} minor
    regsub m4_define $patch {} patch

    regsub -all {[^0-9]} $major {} major ; # Strip any other non-digits.
    regsub -all {[^0-9]} $minor {} minor
    regsub -all {[^0-9]} $patch {} patch

    #puts major'=$major
    #puts minor'=$minor
    #puts patch'=$patch

    # And push the configuration into the build setup.
    critcl::cflags -DYAML_VERSION_MAJOR=\"$major\"
    critcl::cflags -DYAML_VERSION_MINOR=\"$minor\"
    critcl::cflags -DYAML_VERSION_PATCH=\"$patch\"
    critcl::cflags -DYAML_VERSION_STRING=\"$major.$minor.$patch\"

    critcl::msg -nonewline " (using libyaml $major.$minor.$patch)"
}}

rename grep {}

critcl::cflags -DYAML_DECLARE_STATIC ; # Windows, no DLL export of symbols.

# # ## ### ##### ######## #############
## The C parts of the package expose libyaml as a plain C class,
## providing access to the event parts of the API. The higher-level
## Tcl code then places the conversion to and from Tcl structures
## on top of that.

critcl::tsources policy.tcl

# # ## ### ##### ######## #############
## Main C section.

# # ## ### ##### ######## #############
## C classes for the various types of objects.

critcl::source ly_global.tcl
critcl::source ly_parser.tcl
critcl::source ly_emitter.tcl

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

critcl::msg -nonewline { Building ...}
if {![critcl::load]} {
    error "Building and loading Tclyaml failed."
}

# # ## ### ##### ######## #############

package provide tclyaml 0.3
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
