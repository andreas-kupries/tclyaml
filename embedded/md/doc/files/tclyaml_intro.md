
[//000000001]: # (tclyaml\_introduction \- TclYAML)
[//000000002]: # (Generated from file 'tclyaml\_intro\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2012\-2014, 2021 Andreas Kupries
Copyright &copy; 2012\-2014, 2021 Documentation, Andreas Kupries)
[//000000004]: # (tclyaml\_introduction\(n\) 0\.4 doc "TclYAML")

<hr> [ <a href="../../../../../../home">Home</a> | <a
href="../../toc.md">Main Table Of Contents</a> | <a
href="../toc.md">Table Of Contents</a> | <a
href="../../index.md">Keyword Index</a> ] <hr>

# NAME

tclyaml\_introduction \- TclYAML \- Introduction to TclYAML

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Related Documents](#section2)

  - [System Architecture](#section3)

  - [Bugs, Ideas, Feedback](#section4)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5
package require tclyaml ?0\.4?

# <a name='description'></a>DESCRIPTION

Welcome to TclYAML, a binding to the C\-based libyaml parser library for
[YAML](http://yaml\.org) \(YAML Ain't Markup Language\)\.

# <a name='section2'></a>Related Documents

  1. *[TclYAML \- License](tclyaml\_license\.md)*\.

  1. *[TclYAML \- How To Get The Sources](tclyaml\_sources\.md)*\.

  1. *[TclYAML \- The Installer's Guide](tclyaml\_installer\.md)*\.

  1. *[TclYAML \- The Developer's Guide](tclyaml\_devguide\.md)*\.

  1. *[TclYAML \- API](tclyaml\.md)*

# <a name='section3'></a>System Architecture

The system's structure is not very complicated\.

At the bottom is the libyaml library doing the heavy lifting for both parsing
and generation of YAML\.

TclYAML sits on top of that, with two distinguishable parts, binding to the
parsing and generation sides of libyaml\.

# <a name='section4'></a>Bugs, Ideas, Feedback

This document, and the package it describes, will undoubtedly contain bugs and
other problems\. Please report such at the [TclYAML
Tracker](http://chiselapp\.com/user/andreas\_kupries/repository/tclyaml)\.
Please also report any ideas for enhancements you may have for either package
and/or documentation\.

# <a name='keywords'></a>KEYWORDS

[YAML](\.\./\.\./index\.md\#key2), [markup language](\.\./\.\./index\.md\#key0),
[serialization](\.\./\.\./index\.md\#key1)

# <a name='category'></a>CATEGORY

3rd party library binding

# <a name='copyright'></a>COPYRIGHT

Copyright &copy; 2012\-2014, 2021 Andreas Kupries
Copyright &copy; 2012\-2014, 2021 Documentation, Andreas Kupries
