# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## C level. Emitter binding.

# # ## ### ##### ######## #############

critcl::class define tclyaml::Emitter {
    #introspect-methods
    # auto instance method 'methods'.
    # auto classvar 'methods'
    # auto field    'class'
    # auto instance method 'destroy'.

    include yaml.h
    # # ## ### ##### ######## #############

    insvariable yaml_emitter_t yemit {
	libyaml emitter object managed by the binding class.
	NOT a pointer.
    } {
	int ok = yaml_emitter_initialize (&instance->yemit);
	if (!ok) {
	    Tcl_AppendResult (interp, "Failed to create libyaml emitter instance", NULL);
	    goto error;
	}

	yaml_emitter_set_output(&instance->yemit, @stem@_write_handler, instance);
    } {
	yaml_emitter_delete (&instance->yemit);
    }

    insvariable Tcl_Obj* output {
	This is where the emitted YAML is stored into by the output handler.
    } {
	instance->output = Tcl_NewObj ();
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
    }

    # # ## ### ##### ######## #############
    destructor {
    }

    # # ## ### ##### ######## #############
    method stream_start proc {} ok {
	/* Syntax: <instance> stream_start */
	yaml_event_t e;

	yaml_stream_start_event_initialize (&e, YAML_UTF8_ENCODING);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method stream_end proc {} ok {
	/* Syntax: <instance> stream_end */
	yaml_event_t e;

	yaml_stream_end_event_initialize (&e);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method document_start proc {int implicit} ok {
	/* Syntax: <instance> doc_start <implicit> */
	yaml_event_t e;

	/* TODO: doc-start : tag start/end, version directive */

	yaml_document_start_event_initialize (&e, NULL, NULL, NULL, implicit);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method document_end proc {int implicit} ok {
	/* Syntax: <instance> doc_end <implicit> */
	yaml_event_t e;

	yaml_document_end_event_initialize (&e, implicit);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method sequence_start proc {char* anchor char* tag int implicit Tcl_Obj* style} ok {
	/* Syntax: <instance> seq_start <anchor> <tag> <implicit> <style> */
	yaml_event_t e;
	yaml_sequence_style_t ystyle;

	if (!strlen(anchor)) anchor = NULL;
	if (!strlen(tag))    tag    = NULL;

	if (!encode_sequence_style (interp, style, &ystyle)) {
	    return TCL_ERROR;
	}

	yaml_sequence_start_event_initialize (&e, (yaml_char_t*) anchor,
					      (yaml_char_t*) tag, implicit, ystyle);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method sequence_end proc {} ok {
	/* Syntax: <instance> seq_end */
	yaml_event_t e;

	yaml_sequence_end_event_initialize (&e);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method mapping_start proc {char* anchor char* tag int implicit Tcl_Obj* style} ok {
	/* Syntax: <instance> map_start <anchor> <tag> <implicit> <style> */
	yaml_event_t e;
	yaml_mapping_style_t ystyle;

	if (!strlen(anchor)) anchor = NULL;
	if (!strlen(tag))    tag = NULL;

	if (!encode_mapping_style (interp, style, &ystyle)) {
	    return TCL_ERROR;
	}

	yaml_mapping_start_event_initialize (&e, (yaml_char_t*) anchor,
					     (yaml_char_t*) tag, implicit, ystyle);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method mapping_end proc {} ok {
	/* Syntax: <instance> map_end */
	yaml_event_t e;

	yaml_mapping_end_event_initialize (&e);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method scalar proc {char* anchor char* tag char* value int plain int quoted Tcl_Obj* style} ok {
	/* Syntax: <instance> scalar <anchor> <tag> <value> <plain> <quoted> <style> */
	yaml_scalar_style_t ystyle;
	int vlen;
	yaml_event_t e;

	if (!strlen(anchor)) anchor = NULL;
	if (!strlen(tag))    tag = NULL;

	if (!encode_scalar_style (interp, style, &ystyle)) {
	    return TCL_ERROR;
	}

	vlen = strlen (value);
	if (!yaml_scalar_event_initialize (&e,
		   (yaml_char_t*) anchor,
		   (yaml_char_t*) tag,
		   (yaml_char_t*) value, vlen,
		   plain, quoted, ystyle)) {
	    Tcl_AppendResult (interp, "Bad event", NULL);
	    return TCL_ERROR;
	}
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method alias proc {char* anchor} ok {
	/* Syntax: <instance> alias <anchor> */
	yaml_event_t e;

	yaml_alias_event_initialize (&e, (yaml_char_t*) anchor);
	return @stem@_emit (interp, instance, &e);
    }

    # # ## ### ##### ######## #############
    method yaml proc {} ok {
	/* Syntax: <> */
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
