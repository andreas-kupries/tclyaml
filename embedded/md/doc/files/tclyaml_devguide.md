
[//000000001]: # (tclyaml\_devguide \- TclYAML)
[//000000002]: # (Generated from file 'tclyaml\_devguide\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2012\-2014, 2021\-2024 Andreas Kupries)
[//000000004]: # (Copyright &copy; 2012\-2014, 2021\-2024 Documentation, Andreas Kupries)
[//000000005]: # (tclyaml\_devguide\(n\) 0\.6 doc "TclYAML")

<hr> [ <a href="../../../../../../home">Home</a> &#124; <a
href="../../toc.md">Main Table Of Contents</a> &#124; <a
href="../toc.md">Table Of Contents</a> &#124; <a
href="../../index.md">Keyword Index</a> ] <hr>

# NAME

tclyaml\_devguide \- TclYAML \- The Developer's Guide

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Developing for TclYAML](#section2)

      - [Directory structure](#subsection1)

  - [Bugs, Ideas, Feedback](#section3)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.6  
package require tclyaml ?0\.6?  

# <a name='description'></a>DESCRIPTION

Welcome to TclYAML, a binding to the C\-based libyaml parser library for [YAML
Ain't Markup Language](http://yaml\.org)\.

This document is a guide for developers working on TclYAML, i\.e\. maintainers
fixing bugs, extending the package's functionality, etc\.

Please read

  1. *[TclYAML \- License](tclyaml\_license\.md)*,

  1. *[TclYAML \- How To Get The Sources](tclyaml\_sources\.md)*, and

  1. *[TclYAML \- The Installer's Guide](tclyaml\_installer\.md)*

first, if that was not done already\. Here we assume that the sources are already
available in a directory of your choice, and that you not only know how to build
and install them, but also have all the necessary requisites to actually do so\.
The guide to the sources in particular also explains which source code
management system is used, where to find it, how to set it up, etc\.

# <a name='section2'></a>Developing for TclYAML

## <a name='subsection1'></a>Directory structure

  - Helpers

  - Documentation

      * "doc/"

        This directory contains the documentation sources\. The texts are written
        in *doctools* format\.

      * "embedded/"

        This directory contains the documentation converted to regular manpages
        \(nroff\), Markdown, and HTML\. It is called embedded because these files,
        while derived, are part of the fossil repository, i\.e\. embedded into it\.
        This enables fossil to access and display these files when serving the
        repositories' web interface\. The "Command Reference" link at
        [https://core\.tcl\-lang\.org/akupries/tclyaml](https://core\.tcl\-lang\.org/akupries/tclyaml)
        is, for example, accessing the generated Markdown\.

  - Package Code, General structure

      * "tclyaml\.tcl"

        This is the master file of the package\. Based on __critcl__ \(v3\.1\)
        it contain alls the necessary declarations to build the package\.

      * "policy\.tcl"

        This is the companions to the "tclyaml\.tcl" file which implements the
        higher\-level interfaces on top of the C\-based primitive operations, and
        determines policies\.

        The documentation \(see "doc/"\) mainly describes the higher\-level API,
        plus the few primitives which are passed through unchanged, i\.e\. without
        getting wrapped into Tcl procedures\.

      * "ly\_global\.tcl"

        Common global code useful to both parsing and generator sides\. Mainly
        the conversion of style values from and to Tcl strings\.

      * "ly\_emitter\.tcl"

        The generator side of the package, a __critcl::class__\-based class
        whose instances can convert various Tcl data structures into proper
        YAML\. This class is internal, the user only sees regular Tcl commands,
        which instantiate and destroy emitter objects as needed\.

      * "ly\_parser\.tcl"

        The low\-level commands for parsing YAML, returning it in the form of
        various Tcl data structures\. Plain commands, not object\-based\.

      * "libyaml/"

        A copy of the libyaml 0\.2\.5 sources\. Built as part of TclYAML\.

  - Package Code, Per Package

      * __[tclyaml](tclyaml\.md)__

          + "tclyaml\.tcl"

          + "policy\.tcl"

          + "ly\_emitter\.tcl"

          + "ly\_global\.tcl"

          + "ly\_parser\.tcl"

      * __libyaml__

          + "libyaml/"

# <a name='section3'></a>Bugs, Ideas, Feedback

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

Copyright &copy; 2012\-2014, 2021\-2024 Andreas Kupries  
Copyright &copy; 2012\-2014, 2021\-2024 Documentation, Andreas Kupries
