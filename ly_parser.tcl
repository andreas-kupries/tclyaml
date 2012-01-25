# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## C level. Parser binding.

# # ## ### ##### ######## #############

critcl::class def tclyaml::Parser {
    #introspect-methods
    # auto instance method 'methods'.
    # auto classvar 'methods'
    # auto field    'class'
    # auto instance method 'destroy'.

    include yaml.h
    # # ## ### ##### ######## #############

    field yaml_parser_t yp {
	libyaml parser object managed by the binding class.
	NOT a pointer.
    }

    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    constructor { /* Syntax: <epsilon> */
	int ok;
#if 0
	if (objc != 0) {
	    Tcl_WrongNumArgs (interp, 0, objv, "");
	    return TCL_ERROR;
	}
#endif
	ok = yaml_parser_initialize (&instance->yp);
	if (!ok) {
	    Tcl_AppendResult (interp, "Failed to create libyaml parser instance", NULL);
	    goto error;
	}
    }

    # # ## ### ##### ######## #############
    destructor {
	yaml_parser_delete (&instance->yp);
    }

    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    support {
	/* ======================================================================= */
	/* ======================================================================= */
	/* ======================================================================= */
    }
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
