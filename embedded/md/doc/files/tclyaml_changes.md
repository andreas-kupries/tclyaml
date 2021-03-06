
[//000000001]: # (tclyaml\_changes \- TclYAML)
[//000000002]: # (Generated from file 'tclyaml\_changes\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2012\-2014, 2021 Andreas Kupries)
[//000000004]: # (Copyright &copy; 2012\-2014, 2021 Documentation, Andreas Kupries)
[//000000005]: # (tclyaml\_changes\(n\) 0\.5 doc "TclYAML")

<hr> [ <a href="../../../../../../home">Home</a> &#124; <a
href="../../toc.md">Main Table Of Contents</a> &#124; <a
href="../toc.md">Table Of Contents</a> &#124; <a
href="../../index.md">Keyword Index</a> ] <hr>

# NAME

tclyaml\_changes \- TclYAML \- License

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Changes](#section2)

      - [Changes for version 0\.5](#subsection1)

  - [Bugs, Ideas, Feedback](#section3)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.5  
package require tclyaml ?0\.5?  

# <a name='description'></a>DESCRIPTION

Welcome to TclYAML, a binding to the C\-based libyaml parser library for [YAML
Ain't Markup Language](http://yaml\.org)\. This document provides an overview
of the changes __[TclYAML](tclyaml\.md)__ underwent from version to
version\.

# <a name='section2'></a>Changes

## <a name='subsection1'></a>Changes for version 0\.5

In detail:

  1. As a non\-breaking change, a test suite was added\.

     All following changes are breaking, versus version __0\.4__\.

  1. Removed the untyped structure tag __scalar__\. Replaced it with five new
     tags providing type information:

       1) __bool__

       1) __float__

       1) __int__

       1) __null__

       1) __string__

  1. When reading YAML data types are now determined as per the [YAML Core
     Schema](https://yaml\.org/spec/1\.2/spec\.html\#id2804923) rules\. And the
     assumption that quoted values are always strings, and none of the other
     types\.

  1. Read values are now normalized, as per their type\. For example, the
     internally seen value of an integer is always in decimal form, regardless
     of if it was octal or hex in the input\.

  1. On the writing side the new structural tags now exist as pre\-defined type
     converters\. The __scalar__ converter is still present, and aliases now
     to __string__\. In the previous version __string__ aliased to
     __scalar__ as the only scalar type\.

  1. Most styling of scalar values is now automatically determined by their
     type, and, in case of strings, by the value as well\.

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

Copyright &copy; 2012\-2014, 2021 Andreas Kupries  
Copyright &copy; 2012\-2014, 2021 Documentation, Andreas Kupries
