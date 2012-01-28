# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## C level. Emitter binding.

# # ## ### ##### ######## #############

critcl::class def tclyaml::Emitter {
    #introspect-methods
    # auto instance method 'methods'.
    # auto classvar 'methods'
    # auto field    'class'
    # auto instance method 'destroy'.

    include yaml.h
    # # ## ### ##### ######## #############

    field yaml_emitter_t yemit {
	libyaml emitter object managed by the binding class.
	NOT a pointer.
    }

    field Tcl_Obj* output {
	This is where the emitted YAML is stored into by the output handler.
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
	ok = yaml_emitter_initialize (&instance->yemit);
	if (!ok) {
	    Tcl_AppendResult (interp, "Failed to create libyaml emitter instance", NULL);
	    goto error;
	}

	yaml_emitter_set_output(&instance->yemit, @stem@_write_handler, instance);
	instance->output = Tcl_NewObj ();
    }

    # # ## ### ##### ######## #############
    destructor {
	yaml_emitter_delete (&instance->yemit);
    }

    # # ## ### ##### ######## #############
    mdef stream_start { /* Syntax: <instance> stream_start */
	yaml_event_t e;

	if (objc != 2) {
	    Tcl_WrongNumArgs (interp, 2, objv, "");
	    return TCL_ERROR;
	}

	yaml_stream_start_event_initialize (&e, YAML_UTF8_ENCODING);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef stream_end { /* Syntax: <instance> stream_end */
	yaml_event_t e;

	if (objc != 2) {
	    Tcl_WrongNumArgs (interp, 2, objv, "");
	    return TCL_ERROR;
	}

	yaml_stream_end_event_initialize (&e);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef document_start { /* Syntax: <instance> doc_start <implicit> */
	int implicit;
	yaml_event_t e;

	/* TODO: doc-start : tag start/end, version directive */

	if (objc != 3) {
	    Tcl_WrongNumArgs (interp, 2, objv, "implicit");
	    return TCL_ERROR;
	}

	if (Tcl_GetIntFromObj (interp, objv[2], &implicit) != TCL_OK) {
	    return TCL_ERROR;
	}

	yaml_document_start_event_initialize (&e, NULL, NULL, NULL, implicit);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef document_end { /* Syntax: <instance> doc_end <implicit> */
	yaml_event_t e;
	int implicit;

	if (objc != 3) {
	    Tcl_WrongNumArgs (interp, 2, objv, "implicit");
	    return TCL_ERROR;
	}

	if (Tcl_GetIntFromObj (interp, objv[2], &implicit) != TCL_OK) {
	    return TCL_ERROR;
	}

	yaml_document_end_event_initialize (&e, implicit);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef sequence_start { /* Syntax: <instance> seq_start <anchor> <tag> <implicit> <style> */
	int alen, tlen, implicit;
	yaml_event_t e;
	char* anchor;
	char* tag;
	yaml_sequence_style_t style;

	if (objc != 6) {
	    Tcl_WrongNumArgs (interp, 2, objv, "anchor tag implicit style");
	    return TCL_ERROR;
	}

	anchor = Tcl_GetStringFromObj (objv[2], &alen);
	tag    = Tcl_GetStringFromObj (objv[3], &tlen);

	if (!alen) anchor = NULL;
	if (!tlen) tag = NULL;

	if (Tcl_GetIntFromObj (interp, objv[4], &implicit) != TCL_OK) {
	    return TCL_ERROR;
	}

	if (!encode_sequence_style (interp, objv[5], &style)) {
	    return TCL_ERROR;
	}

	yaml_sequence_start_event_initialize (&e, (yaml_char_t*) anchor,
					      (yaml_char_t*) tag, implicit, style);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef sequence_end { /* Syntax: <instance> seq_end */
	yaml_event_t e;

	if (objc != 2) {
	    Tcl_WrongNumArgs (interp, 0, objv, "");
	    return TCL_ERROR;
	}

	yaml_sequence_end_event_initialize (&e);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef mapping_start { /* Syntax: <instance> map_start <anchor> <tag> <implicit> <style> */
	int alen, tlen, implicit;
	yaml_event_t e;
	char* anchor;
	char* tag;
	yaml_mapping_style_t style;

	if (objc != 6) {
	    Tcl_WrongNumArgs (interp, 2, objv, "anchor tag implicit style");
	    return TCL_ERROR;
	}

	anchor = Tcl_GetStringFromObj (objv[2], &alen);
	tag    = Tcl_GetStringFromObj (objv[3], &tlen);

	if (!alen) anchor = NULL;
	if (!tlen) tag = NULL;

	if (Tcl_GetIntFromObj (interp, objv[4], &implicit) != TCL_OK) {
	    return TCL_ERROR;
	}

	if (!encode_mapping_style (interp, objv[5], &style)) {
	    return TCL_ERROR;
	}

	yaml_mapping_start_event_initialize (&e, (yaml_char_t*) anchor,
					     (yaml_char_t*) tag, implicit, style);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef mapping_end { /* Syntax: <instance> map_end */
	yaml_event_t e;

	if (objc != 2) {
	    Tcl_WrongNumArgs (interp, 0, objv, "");
	    return TCL_ERROR;
	}

	yaml_mapping_end_event_initialize (&e);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef scalar { /* Syntax: <instance> scalar <anchor> <tag> <value> <plain> <quoted> <style> */
	int alen, tlen, vlen, plain, quoted;
	char* anchor;
	char* tag;
	char* value;
	yaml_scalar_style_t style;
	yaml_event_t e;

	if (objc != 8) {
	    Tcl_WrongNumArgs (interp, 2, objv, "anchor tag value plain quoted style");
	    return TCL_ERROR;
	}

	anchor = Tcl_GetStringFromObj (objv[2], &alen);
	tag    = Tcl_GetStringFromObj (objv[3], &tlen);
	value  = Tcl_GetStringFromObj (objv[4], &vlen);

	if (!alen) anchor = NULL;
	if (!tlen) tag = NULL;

	if (Tcl_GetIntFromObj (interp, objv[5], &plain) != TCL_OK) {
	    return TCL_ERROR;
	}

	if (Tcl_GetIntFromObj (interp, objv[6], &quoted) != TCL_OK) {
	    return TCL_ERROR;
	}

	if (!encode_scalar_style (interp, objv[7], &style)) {
	    return TCL_ERROR;
	}

	if (!yaml_scalar_event_initialize (&e,
		   (yaml_char_t*) anchor,
		   (yaml_char_t*) tag,
		   (yaml_char_t*) value, vlen,
		   plain, quoted, style)) {
	    Tcl_AppendResult (interp, "Bad event", NULL);
	    return TCL_ERROR;
	}
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef alias { /* Syntax: <instance> alias <anchor> */
	int alen;
	char* anchor;
	yaml_event_t e;

	if (objc != 3) {
	    Tcl_WrongNumArgs (interp, 2, objv, "anchor");
	    return TCL_ERROR;
	}

	anchor = Tcl_GetStringFromObj (objv[2], &alen);

	yaml_alias_event_initialize (&e, (yaml_char_t*) anchor);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    mdef yaml { /* Syntax: <> */
	Tcl_SetObjResult (interp, instance->output);
	return TCL_OK;
    }

    # # ## ### ##### ######## #############
    # config methods:
    #   encoding <enum>, canonical <bool>, indent <n>
    #   width <n>, unicode <bool>, break <enum>

    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    # # ## ### ##### ######## #############
    support {
	/* ======================================================================= */

	static int
	@stem@_write_handler (void* data, unsigned char* buffer, size_t size)
	{
	    @instancetype@ instance = (@instancetype@) data;

	    /* fprintf (stderr,"writing %d (%*s)\n", size, size, buffer);fflush(stderr); */

	    Tcl_AppendToObj (instance->output, (char*) buffer, size);
	    return 1;
	}

	/* ======================================================================= */

	static void
	decode_emitter_error (Tcl_Interp* interp, yaml_emitter_t* ye)
	{
	    /* fprintf (stderr,"throw error\n");fflush(stderr); */
	    Tcl_AppendResult (interp,
			      decode_error_type (ye->error), " error: ",
			      ye->problem, ".", NULL);
	}

	/* ======================================================================= */

	static int
	@stem@_emit (Tcl_Interp* interp, @instancetype@ instance, yaml_event_t* e)
	{
	    /* fprintf (stderr,"emit-e(%d) %s\n",e->type,Tcl_GetString (decode_event_type (e->type)));fflush(stderr);*/

	    if (!yaml_emitter_emit (&instance->yemit, e)) {
		decode_emitter_error (interp, &instance->yemit);
		return TCL_ERROR;
	    }
	    return TCL_OK;
	}

	/* ======================================================================= */
    }
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
