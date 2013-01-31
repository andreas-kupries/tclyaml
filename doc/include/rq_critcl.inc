
[subsection CriTcl]

To build TclYAML the tool [syscmd critcl] is required.

[para] TclYAML's build systems accepts it either as an application
found in the PATH, or as a Tcl package available to the [syscmd tclsh]
used to run their build & installation processes.

[para] TclYAML [emph must] have version 3.1, and critcl::class version 1.0.3

[para] The relevant github repository can be found at
[uri http://andreas-kupries.github.com/critcl].

[para] The relevant repository branch is [emph master].

[para] At the above url is also an explanation on how to build and
install CriTcl, including a list of its dependencies.

[para] Its instructions will not be repeated here. If there are
problems with their directions please file a bug against the critcl
project, and not TclYAML.
