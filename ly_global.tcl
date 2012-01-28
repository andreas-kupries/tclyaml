# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## C level. Global commands

# # ## ### ##### ######## #############

critcl::ccode {
    #include <yaml.h>
}

critcl::cproc tclyaml::version {} char* {
    return (char*) yaml_get_version_string ();
}

# # ## ### ##### ######## #############
## Handling various enumerations in the libyaml API.
## (encoding, and decoding).

critcl::ccode {
    /* ==================================================================== */

    static const char* ty_scalar_style_names [] = {
	"any", "plain", "single", "double",
	"literal", "folded",
	NULL
    };

    /* Maximum sharing of the string as Tcl_Obj's */
    /* XXX This setup is not thread safe, nor oblivious */

    static Tcl_Obj*
    decode_scalar_style (yaml_scalar_style_t t)
    {
	static Tcl_Obj* styleobj [YAML_FOLDED_SCALAR_STYLE+1] = { NULL };

	if (!styleobj [0]) {
	    int e;
	    for (e = YAML_ANY_SCALAR_STYLE;
		 e <= YAML_FOLDED_SCALAR_STYLE;
		 e++) {
	       styleobj [e] = Tcl_NewStringObj (ty_scalar_style_names [e], -1);
	       Tcl_IncrRefCount (styleobj [e]);
	    }
	}

	return styleobj [t];
    }

    static int
    encode_scalar_style (Tcl_Interp* interp, Tcl_Obj* style, yaml_scalar_style_t* estyle)
    {
	if (Tcl_GetIndexFromObj (interp, style, ty_scalar_style_names,
				 "scalar style", 0, estyle) != TCL_OK) {
	    return 0;
	}
	return 1;
    }

    /* ==================================================================== */

    static const char* ty_block_style_names [] = {
	"any", "block", "flow", NULL
    };

    /* Maximum sharing of the string as Tcl_Obj's */
    static Tcl_Obj*
    decode_sequence_style (yaml_sequence_style_t t)
    {
	/* XXX This setup is not thread safe, nor oblivious */
	static Tcl_Obj* styleobj [YAML_FLOW_SEQUENCE_STYLE+1] = { NULL };

	if (!styleobj [0]) {
	    int e;

	    for (e = YAML_ANY_SEQUENCE_STYLE;
		 e <= YAML_FLOW_SEQUENCE_STYLE;
		 e++) {
	       styleobj [e] = Tcl_NewStringObj (ty_block_style_names [e], -1);
	       Tcl_IncrRefCount (styleobj [e]);
	    }
	}

	return styleobj [t];
    }

    static int
    encode_sequence_style (Tcl_Interp* interp, Tcl_Obj* style, yaml_sequence_style_t* estyle)
    {
	if (Tcl_GetIndexFromObj (interp, style, ty_block_style_names,
				 "sequence style", 0, estyle) != TCL_OK) {
	    return 0;
	}
	return 1;
    }

    /* Maximum sharing of the string as Tcl_Obj's */
    static Tcl_Obj*
    decode_mapping_style (yaml_mapping_style_t t)
    {
	/* XXX This setup is not thread safe, nor oblivious */
	static Tcl_Obj* styleobj [YAML_FLOW_MAPPING_STYLE+1] = { NULL };

	if (!styleobj [0]) {
	    int e;

	    for (e = YAML_ANY_MAPPING_STYLE;
		 e <= YAML_FLOW_MAPPING_STYLE;
		 e++) {
	       styleobj [e] = Tcl_NewStringObj (ty_block_style_names [e], -1);
	       Tcl_IncrRefCount (styleobj [e]);
	    }
	}

	return styleobj [t];
    }

    static int
    encode_mapping_style (Tcl_Interp* interp, Tcl_Obj* style, yaml_mapping_style_t* estyle)
    {
	if (Tcl_GetIndexFromObj (interp, style, ty_block_style_names,
				 "mapping style", 0, estyle) != TCL_OK) {
	    return 0;
	}
	return 1;
    }
}

# # ## ### ##### ######## #############
