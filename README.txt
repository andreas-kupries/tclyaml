
Directory contents.

	do*.sh    - Convenience shell scripts for building tclyaml via critcl.
		    Not under revision control

	trial.sh  - Run tclyaml on input file.
		    Not under revision control

	build.tcl - Official build script for integration with AT build.

	tests/	  Example input files.
		    Not under revision control

	tclyaml.tcl	Critcl Tcl/C code, main file, admin, etc.
	ly_global.tcl	Critcl Tcl/C code, shared stuff
	ly_parser.tcl	Critcl Tcl/C code, parser, low-level
	ly_emitter.tcl	Critcl Tcl/C code, emitter, low-level, empty
	policy.tcl	Tcl code working on top of the low-level C pieces.
			Parser class, export commands.

	libyaml/	Copy of libyaml 0.1.4
			Built as part of tclyaml
