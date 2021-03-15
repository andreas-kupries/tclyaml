
[subsection CriTcl]

To build [vset PROJECT] the tool [syscmd critcl] is required.

[para] [vset PROJECT]'s build systems accepts it either as an
application found in the PATH, or as a Tcl package available to the
[syscmd tclsh] used to run their build & installation processes.

[para] [vset PROJECT] [emph must] have at least version 3.1 of critcl
itself, and at least version 1.0.3 of [package critcl::class].

[para] The relevant github repository can be found at [vset critcl].

[para] The relevant repository branch is [emph master].

[para] At the above url is also an explanation on how to build and
install CriTcl, including a list of its dependencies.

[para] Its instructions will not be repeated here. If there are
problems with their directions please file a bug against the critcl
project, and not [vset PROJECT].
