# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## C level. Global commands

# # ## ### ##### ######## #############

critcl::ccode {
    #include <yaml.h>
}

critcl::cproc tclyaml::version {} char* {
    return yaml_get_version_string ();
}

# # ## ### ##### ######## #############
