
[//000000001]: # (tclyaml\_sources \- TclYAML)
[//000000002]: # (Generated from file 'tclyaml\_sources\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2012\-2014, 2021 Andreas Kupries)
[//000000004]: # (Copyright &copy; 2012\-2014, 2021 Documentation, Andreas Kupries)
[//000000005]: # (tclyaml\_sources\(n\) 0\.4 doc "TclYAML")

<hr> [ <a href="../../../../../../home">Home</a> &#124; <a
href="../../toc.md">Main Table Of Contents</a> &#124; <a
href="../toc.md">Table Of Contents</a> &#124; <a
href="../../index.md">Keyword Index</a> ] <hr>

# NAME

tclyaml\_sources \- TclYAML \- How To Get The Sources

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Source Location](#section2)

  - [Retrieval](#section3)

  - [Source Code Management](#section4)

  - [Bugs, Ideas, Feedback](#section5)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5
package require tclyaml ?0\.4?

# <a name='description'></a>DESCRIPTION

Welcome to TclYAML, a binding to the C\-based libyaml parser library for [YAML
Ain't Markup Language](http://yaml\.org)\.

The audience of this document is anyone wishing to either have just a look at
TclYAML's source code, or build the packages, or to extend and modify them\.

For builders and developers we additionally provide

  1. *[TclYAML \- License](tclyaml\_license\.md)*\.

  1. *[TclYAML \- The Installer's Guide](tclyaml\_installer\.md)*\.

  1. *[TclYAML \- The Developer's Guide](tclyaml\_devguide\.md)*\.

respectively\.

# <a name='section2'></a>Source Location

The official repository for TclYAML can be found at
[https://core\.tcl\-lang\.org/akupries/tclyaml](https://core\.tcl\-lang\.org/akupries/tclyaml),
with mirrors at
[https://chiselapp\.com/user/andreas\_kupries/repository/tclyaml](https://chiselapp\.com/user/andreas\_kupries/repository/tclyaml)
and
[https://github\.com/andreas\-kupries/tclyaml](https://github\.com/andreas\-kupries/tclyaml),
in case of trouble with the main location\.

# <a name='section3'></a>Retrieval

Assuming that you simply wish to look at the sources, or build a specific
revision, the easiest way of retrieving it is to:

  1. Log into this site, as "anonymous", using the semi\-random password in the
     captcha\.

  1. Go to the "Timeline"\.

  1. Choose the revision you wish to have and

  1. follow its link to its detailed information page\.

  1. On that page, choose either the "ZIP" or "Tarball" link to get a copy of
     this revision in the format of your choice\.

# <a name='section4'></a>Source Code Management

For the curious \(or a developer\-to\-be\), the sources are managed by the [Fossil
SCM](https://www\.fossil\-scm\.org)\. Binaries for popular platforms can be found
directly at its [download page](https://www\.fossil\-scm\.org/download\.html)\.

With that tool available the full history can be retrieved via:

    fossil clone  https://core.tcl-lang.org/akupries/tclyaml  tclyaml.fossil

followed by

    mkdir tclyaml
    cd tclyaml
    fossil open ../tclyaml.fossil

to get a checkout of the head of the trunk\.

# <a name='section5'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such at the [TclYAML
Tracker](https://core\.tcl\-lang\.org/akupries/tclyaml)\. Please also report any
ideas for enhancements you may have for either package and/or documentation\.

# <a name='keywords'></a>KEYWORDS

[YAML](\.\./\.\./index\.md\#yaml), [markup
language](\.\./\.\./index\.md\#markup\_language),
[serialization](\.\./\.\./index\.md\#serialization)

# <a name='category'></a>CATEGORY

3rd party library binding

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2012\-2014, 2021 Andreas Kupries
Copyright &copy; 2012\-2014, 2021 Documentation, Andreas Kupries
