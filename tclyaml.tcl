# -*- tcl -*-
# Tclyaml = A Tcl Binding to the libyaml C library.
# Note that this doesn't export the libyaml C API as stubs.
# It directly exposes libyaml functionality to Tcl script.
#
# (c) 2012 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#

# # ## ### ##### ######## #############
## Requisites

package require critcl 3.1
critcl::buildrequirement {
    package require critcl::util 1
    package require critcl::class 1
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
critcl::csources  libyaml/src/*.c

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

critcl::source ly_parser.tcl
critcl::source ly_emitter.tcl

# # ## ### ##### ######## #############
## Make the C pieces ready. Immediate build of the binaries, no deferal.

if {![critcl::load]} {
    error "Building and loading Tclyaml failed."
}

# # ## ### ##### ######## #############

package provide tclyaml 0
return

# vim: set sts=4 sw=4 tw=80 et ft=tcl:
