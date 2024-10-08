# # ## ### ##### ######## #############
## Tclyaml = A Tcl Binding to the libyaml C library.
## C level. Parser binding.

# # ## ### ##### ######## #############

critcl::ccode {
    static int
    read_handler (void* data, unsigned char* buffer, size_t size, size_t* size_read)
    {
	Tcl_Size got;
	Tcl_Channel chan = (Tcl_Channel) data;

	/*fprintf (stderr,"RH rq(" TCL_SIZE_FMT ")\n", size);fflush (stderr);*/
	/*fprintf (stderr,"RH chan = %s\n", Tcl_GetChannelName (chan));fflush (stderr);*/

	if (Tcl_Eof (chan)) {
	    /*fprintf (stderr,"RH eof\n");fflush (stderr);*/

	    *size_read = 0;
	    return 1;
	}

	/*fprintf (stderr,"RH read\n");fflush (stderr);*/

	got = Tcl_Read (chan, (char*) buffer, size); /* OK tcl9 */

	/*fprintf (stderr,"RH got " TCL_SIZE_FMT " e%d\n\n", got, Tcl_GetErrno());fflush (stderr);*/

	/* XXX check other code reading from channel */
#if 0
	if (Tcl_GetErrno()) {
	    /*fprintf (stderr,"RH fail\n");fflush (stderr);*/
	    return 0;
	}
#endif
	/*fprintf (stderr,"RH ok\n");fflush (stderr);*/
	*size_read = got;
	return 1;
    }

    /* Maximum sharing of the string as Tcl_Obj's */
    static Tcl_Obj*
    decode_event_type (yaml_event_type_t t)
    {
	/* XXX This setup is not thread safe, nor oblivious */
	static Tcl_Obj* events [YAML_MAPPING_END_EVENT+1] = { NULL };

	if (!events [0]) {
	    int e;

	    static const char* es [] = {
		"none",
		"stream-start",	"stream-end",
		"document-start", "document-end",
		"alias",
		"scalar",
		"sequence-start", "sequence-end",
		"mapping-start", "mapping-end"
	    };

	    for (e = YAML_NO_EVENT;
		 e <= YAML_MAPPING_END_EVENT;
		 e++) {
	       events [e] = Tcl_NewStringObj (es [e], TCL_AUTO_LENGTH); /* OK tcl9 */
	       Tcl_IncrRefCount (events[e]);
	    }
	}

	return events [t];
    }

    /* Maximum sharing of the string as Tcl_Obj's */
    static Tcl_Obj*
    decode_encoding_type (yaml_encoding_t t)
    {
	/* XXX This setup is not thread safe, nor oblivious */
	static Tcl_Obj* events [YAML_UTF16BE_ENCODING+1] = { NULL };

	if (!events [0]) {
	    int e;

	    static const char* es [] = {
		"any", "utf8", "utf16le", "utf16be"
	    };

	    for (e = YAML_ANY_ENCODING;
		 e <= YAML_UTF16BE_ENCODING;
		 e++) {
	       events [e] = Tcl_NewStringObj (es [e], TCL_AUTO_LENGTH); /* OK tcl9 */
	       Tcl_IncrRefCount (events[e]);
	    }
	}

	return events [t];
    }

    static const char*
    decode_error_type (yaml_error_type_t t)
    {
	static const char* es [] = {
	    "no", "memory",
	    "reader", "scanner", "parser", "composer",
	    "writer", "emitter"
	};

	return es [t];
    }

    static Tcl_Obj*
    decode_event_stream_start (yaml_event_t* ye)
    {
	/* XXX Should put the totality of dict keys into a setup for Tcl_Obj* sharing as well */

	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("encoding", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, decode_encoding_type (ye->data.stream_start.encoding));
	return dict;
    }

    static Tcl_Obj*
    decode_event_document_start (yaml_event_t* ye)
    {
	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	if (ye->data.document_start.version_directive) {
	    Tcl_Obj* v = Tcl_NewListObj (0,0); /* OK tcl9 */
	    Tcl_ListObjAppendElement (NULL, v, Tcl_NewIntObj (ye->data.document_start.version_directive->major)); /* OK tcl9 */
	    Tcl_ListObjAppendElement (NULL, v, Tcl_NewIntObj (ye->data.document_start.version_directive->minor)); /* OK tcl9 */
	    Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("version", TCL_AUTO_LENGTH)); /* OK tcl9 */
	    Tcl_ListObjAppendElement (NULL, dict, v);
	}
/* XXX tags... optional */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("implicit", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewBooleanObj (ye->data.document_start.implicit));
	return dict;
    }

    static Tcl_Obj*
    decode_event_document_end (yaml_event_t* ye)
    {
	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("implicit", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewBooleanObj (ye->data.document_end.implicit));
	return dict;
    }

    static Tcl_Obj*
    decode_event_alias (yaml_event_t* ye)
    {
	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("anchor", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.alias.anchor, TCL_AUTO_LENGTH)); /* OK tcl9 */
	return dict;
    }

    static Tcl_Obj*
    decode_event_scalar (yaml_event_t* ye)
    {
	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("anchor", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.scalar.anchor, TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("tag", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.scalar.tag, TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("scalar", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.scalar.value, ye->data.scalar.length)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("plain-implicit", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewBooleanObj (ye->data.scalar.plain_implicit));
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("quoted-implicit", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewBooleanObj (ye->data.scalar.quoted_implicit));
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("style", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, decode_scalar_style (ye->data.scalar.style));
	return dict;
    }


    static Tcl_Obj*
    decode_event_sequence_start (yaml_event_t* ye)
    {
	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("anchor", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.sequence_start.anchor, TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("tag", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.sequence_start.tag, TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("implicit", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewBooleanObj (ye->data.sequence_start.implicit));
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("style", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, decode_sequence_style (ye->data.sequence_start.style));
	return dict;
    }

    static Tcl_Obj*
    decode_event_mapping_start (yaml_event_t* ye)
    {
	Tcl_Obj* dict = Tcl_NewListObj (0,0); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("anchor", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.mapping_start.anchor, TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("tag", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ((char*) ye->data.mapping_start.tag, TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("implicit", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewBooleanObj (ye->data.mapping_start.implicit));
	Tcl_ListObjAppendElement (NULL, dict, Tcl_NewStringObj ("style", TCL_AUTO_LENGTH)); /* OK tcl9 */
	Tcl_ListObjAppendElement (NULL, dict, decode_mapping_style (ye->data.mapping_start.style));
	return dict;
    }

    static void
    decode_event (Tcl_Obj* cmd, yaml_event_t* ye)
    {
	Tcl_Obj* dict = NULL;

	Tcl_ListObjAppendElement (NULL, cmd, decode_event_type (ye->type));

	switch (ye->type) {
	    case YAML_NO_EVENT:									break;
	    case YAML_STREAM_START_EVENT: 	dict = decode_event_stream_start (ye);		break;
	    case YAML_STREAM_END_EVENT:								break;
	    case YAML_DOCUMENT_START_EVENT:	dict = decode_event_document_start (ye);	break;
	    case YAML_DOCUMENT_END_EVENT:	dict = decode_event_document_end (ye);		break;
	    case YAML_ALIAS_EVENT:		dict = decode_event_alias (ye);			break;
	    case YAML_SCALAR_EVENT:		dict = decode_event_scalar (ye);		break;
	    case YAML_SEQUENCE_START_EVENT:	dict = decode_event_sequence_start (ye);	break;
	    case YAML_SEQUENCE_END_EVENT:							break;
	    case YAML_MAPPING_START_EVENT:	dict = decode_event_mapping_start (ye);		break;
	    case YAML_MAPPING_END_EVENT:							break;
	}

	if (dict) {
	    Tcl_ListObjAppendElement (NULL, cmd, dict);
	}
    }

    static void
    decode_parse_error (Tcl_Interp* interp, yaml_parser_t* yp)
    {
	char buf [60];

	sprintf (buf, "line %ld, column %ld",
		 yp->problem_mark.line,
		 yp->problem_mark.column);

	Tcl_AppendResult (interp,
			  decode_error_type (yp->error), " error: ",
			  yp->problem, " at ", buf,
			  NULL);

	if (yp->context) {
	    sprintf (buf, "line %ld column %ld",
		     yp->context_mark.line,
		     yp->context_mark.column);

	    Tcl_AppendResult (interp, " ", yp->context, " at ", buf, NULL);
	}

	Tcl_AppendResult (interp, ".", NULL);
    }
}

critcl::ccommand ::tclyaml::parse::channel {} { /* syntax: <x> <channel> <cmd>.... */
    int ok, mode, run, res;
    yaml_parser_t yp;
    yaml_event_t  ye;
    Tcl_Channel chan;
    Tcl_Obj* cmdprefix;
    Tcl_Obj* cmd;

    if (objc < 2) {
	Tcl_WrongNumArgs (interp, 0, objv, "channel cmd ?arg...?"); /* OK tcl9 */
	return TCL_ERROR;
    }

    chan = Tcl_GetChannel (interp, Tcl_GetString (objv[1]), &mode);
    if (!chan) {
	goto error;
    }
    if (mode != TCL_READABLE) {
	Tcl_AppendResult (interp, "Expected readable channel", NULL);
	goto error;
    }

    ok = yaml_parser_initialize (&yp);
    if (!ok) {
	Tcl_AppendResult (interp, "Failed to create libyaml parser instance", NULL);
	goto error;
    }

    /* XXX: encoding ! - question is how does the value come out of it! */
    /* yaml_parser_set_encoding (&yp, YAML_ANY_ENCODING); */

    yaml_parser_set_input    (&yp, read_handler, chan);

    cmdprefix = Tcl_NewListObj (objc - 2, objv + 2); /* OK tcl9 */
    Tcl_IncrRefCount (cmdprefix);

    run = 1;
    while (run) {
	ok = yaml_parser_parse (&yp, &ye);
	if (!ok) {
	    decode_parse_error (interp, &yp);
	    goto abort;
	}

	cmd = Tcl_DuplicateObj (cmdprefix);
	Tcl_IncrRefCount (cmd);
	decode_event (cmd, &ye);

	res = Tcl_GlobalEvalObj (interp, cmd);
	Tcl_DecrRefCount (cmd);

	if (res != TCL_OK) {
	    goto abort;
	}

	run = (ye.type != YAML_STREAM_END_EVENT);
	yaml_event_delete (&ye);
    }

    Tcl_DecrRefCount (cmdprefix);

done:
    yaml_parser_delete (&yp);
    return TCL_OK;
abort:
    yaml_event_delete (&ye);
    yaml_parser_delete (&yp);
error:
    return TCL_ERROR;
}

# # ## ### ##### ######## #############
