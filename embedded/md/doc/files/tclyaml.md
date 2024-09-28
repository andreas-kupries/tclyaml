
[//000000001]: # (tclyaml \- TclYAML)
[//000000002]: # (Generated from file 'tclyaml\.man' by tcllib/doctools with format 'markdown')
[//000000003]: # (Copyright &copy; 2012\-2014, 2021\-2024 Andreas Kupries)
[//000000004]: # (Copyright &copy; 2012\-2014, 2021\-2024 Documentation, Andreas Kupries)
[//000000005]: # (tclyaml\(n\) 0\.6 doc "TclYAML")

<hr> [ <a href="../../../../../../home">Home</a> &#124; <a
href="../../toc.md">Main Table Of Contents</a> &#124; <a
href="../toc.md">Table Of Contents</a> &#124; <a
href="../../index.md">Keyword Index</a> ] <hr>

# NAME

tclyaml \- TclYAML \- API

# <a name='toc'></a>Table Of Contents

  - [Table Of Contents](#toc)

  - [Synopsis](#synopsis)

  - [Description](#section1)

  - [Introspection](#section2)

  - [Parsing YAML](#section3)

  - [Generating YAML](#section4)

  - [Standard converters for YAML generation](#section5)

  - [The Writer Object API](#section6)

  - [Bugs, Ideas, Feedback](#section7)

  - [Keywords](#keywords)

  - [Category](#category)

  - [Copyright](#copyright)

# <a name='synopsis'></a>SYNOPSIS

package require Tcl 8\.6  
package require tclyaml ?0\.6?  

[__tclyaml type__ *value*](#1)  
[__tclyaml version__](#2)  
[__tclyaml read channel__ *chan*](#3)  
[__tclyaml read file__ *path*](#4)  
[__tclyaml readTags channel__ *chan*](#5)  
[__tclyaml readTags file__ *path*](#6)  
[__tclyaml parse channel__ *channel* *cmd*\.\.\.](#7)  
[__tclyaml write channel__ *spec* *chan* *value*](#8)  
[__tclyaml write file__ *spec* *path* *value*](#9)  
[__tclyaml write string__ *spec* *value*](#10)  
[__tclyaml write deftype__ *name* *arguments* *body*](#11)  
[__tclyaml writeTags channel__ *chan* *value*](#12)  
[__tclyaml writeTags file__ *path* *value*](#13)  
[__tclyaml writeTags string__ *value*](#14)  
[__string__](#15)  
[__scalar__](#16)  
[__bool__](#17)  
[__int__](#18)  
[__float__](#19)  
[__null__](#20)  
[__list__](#21)  
[__array__](#22)  
[__sequence__](#23)  
[__dict__](#24)  
[__object__](#25)  
[__mapping__](#26)  
[*writer* __alias__ *anchor*](#27)  
[*writer* __sequence\-start__ ?*anchor*? ?*tag*? ?*implicit*?](#28)  
[*writer* __sequence\-end__](#29)  
[*writer* __mapping\-start__ ?*anchor*? ?*tag*? ?*implicit*?](#30)  
[*writer* __mapping\-end__](#31)  
[*writer* __scalar__ *type* *value* ?*anchor*? ?*tag*?](#32)  
[*writer* __blockstyle__ *style*](#33)  
[*writer* __scalarstyle__ *style*](#34)  

# <a name='description'></a>DESCRIPTION

Welcome to TclYAML, a binding to the C\-based libyaml parser library for [YAML
Ain't Markup Language](http://yaml\.org)\.

This document is the reference manpage for the publicly visible API, i\.e\. the
API a user will see, and use\. This API falls into two big sections, for the
generation of YAML from Tcl data structures on one side, and the parsing of YAML
into Tcl structures on the other\.

# <a name='section2'></a>Introspection

  - <a name='1'></a>__tclyaml type__ *value*

    This command applies the typing rules of the [YAML Core
    Schema](https://yaml\.org/spec/1\.2/spec\.html\#id2804923) to the *value*
    and returns a 2\-element list containing the type of the value, and the value
    normalized according to the type, in this order\.

    *Examples*:

        % puts [type NULL]
        null {}

        % puts [type 0xff4f]
        int 65359

        % puts [type 0.1e3]
        float 100.0

        % puts [type .inf]
        float Inf

        % puts [type foo]
        string foo

  - <a name='2'></a>__tclyaml version__

    This command returns a string containing the version number of the libyaml
    library wrapped and provided by this Tcl package\.

# <a name='section3'></a>Parsing YAML

  - <a name='3'></a>__tclyaml read channel__ *chan*

  - <a name='4'></a>__tclyaml read file__ *path*

    These two commands read the YAML documents found in the channel \(*chan*\),
    or file \(*path*\) and return a Tcl list where each element represents a
    single document found in the input\.

    For each document YAML scalars are converted to Tcl strings, and YAML
    sequences and mappings to Tcl lists and dictionaries\.

    *Note* that the command applies the typing rules of the [YAML Core
    Schema](https://yaml\.org/spec/1\.2/spec\.html\#id2804923) to the retrieved
    values\. While the type information is not part of the returned structure the
    normalization implied by a type are applied to the values\.

  - <a name='5'></a>__tclyaml readTags channel__ *chan*

  - <a name='6'></a>__tclyaml readTags file__ *path*

    These two commands behave like their plain __read__ counterparts above,
    except that the data structure they return per element is a *tagged*
    structure where each YAML construct is converted into a 2\-element list of
    type\-tag and value \(in this order\)\. In other words, the type determined by
    rules of the [YAML Core
    Schema](https://yaml\.org/spec/1\.2/spec\.html\#id2804923) is not discarded
    here\.

    While this type of structure is more difficult to access due to the
    additional nesting levels, in return it does not lose YAML's type
    information\. This allows users to properly distinguish between lists and
    dictionaries, for example, if the input YAML allows different syntax for
    specific keys\. Another example would be string versus list, for example in a
    key allowing one to many things of some kind, and a string is the same as a
    list of one element\. In an untagged conversion these cases are difficult to
    impossible to distinguish\.

    The tags able to appear in the result are:

      * bool

        The value is a boolean\. The only possible values are __true__ and
        __false__\.

      * float

        The value is a floating point number\.

      * int

        The value is an integer number

      * mapping

        The value is a mapping from keys to other values\. Note that the keys are
        tagged structures as well, i\.e\. values\.

      * null

        The value indicates a nothingness\. The only possible value is the empty
        string\.

      * sequence

        The value is a sequence of values\.

      * string

        The value is a string, and not any of the other types\.

  - <a name='7'></a>__tclyaml parse channel__ *channel* *cmd*\.\.\.

    This command provides the lowest level of access to the YAML parser\. Reading
    YAML data from the specified *channel* each structural element encountered
    is reported through an invokation of the command prefix *cmd*\.\.\.

    This command prefix is invoked with one or two additional arguments, the
    type of the found element, and a dictionary holding detailed information
    about it\. The contents of the latter are type specific, and may be missing
    completely if the type does not have details\.

    The possible types, with their details, if any, are listed below\. For the
    details, the dictionary keys and their meanings are listed\.

      * __stream\-start__

        Parsing has begun\.

          + __encoding__

            Name of the character encoding used by the input\.

      * __stream\-end__

        Parsing of the current stream ended\. No details\.

      * __document\-start__

        A new document has begun\.

          + __implicit__

            Boolean flag\.

          + __version__

            Version information as 2\-element list of integers\.

          + __tags__

            Yaml type tags\.

      * __document\-end__

        The current document has ended\.

          + __implicit__

            Boolean flag\.

      * __alias__

          + __anchor__

            %%TODO%% explain

      * __scalar__

        A scalar value has been found\.

          + __anchor__

            %%TODO%% explain

          + __tag__

            Yaml type tag\. %%TODO%% which known

          + __scalar__

            Value of the scalar, string\.

          + __plain\-implicit__

            Boolean flag\.

          + __quoted\-implicit__

            Boolean flag\.

          + __style__

            One of __any__, __plain__, __single__, __double__,
            __literal__, or __folded__\.

      * __sequence\-start__

        A sequence \(aka list\) has started\.

          + __anchor__

            %%TODO%% explain

          + __tag__

            Yaml type tag\. %%TODO%% which known

          + __implicit__

            Boolean flag\.

          + __style__

            One of __any__, __block__, or __flow__\.

      * __sequence\-end__

        The current sequence ends\. No details\.

      * __mapping\-start__

        A mapping \(aka dictionary\) has started\.

          + __anchor__

            %%TODO%% explain

          + __tag__

            Yaml type tag\. %%TODO%% which known

          + __implicit__

            Boolean flag\.

          + __style__

            One of __any__, __block__, or __flow__\.

      * __mapping\-end__

        The current mapping ends\. No details\.

# <a name='section4'></a>Generating YAML

  - <a name='8'></a>__tclyaml write channel__ *spec* *chan* *value*

  - <a name='9'></a>__tclyaml write file__ *spec* *path* *value*

  - <a name='10'></a>__tclyaml write string__ *spec* *value*

    These three commands convert the Tcl data structure in *value* into YAML,
    under the guidance of the type information in *spec*\.

    The *spec* describes the expected structure of the *value*\. In essence
    it is the type/tag information which is missing from the *value* itself\.

    The resulting YAML is written to the channel *chan*, or to the file
    referenced by *path*, or returned as the result of the command\.

    For channels, *chan* is expected to be open for writing\. For files, an
    existing file is overwritten with the generated YAML\.

    The syntax of structure *spec*'ification is:

      1. A list of one or more elements\.

      1. The first element of the list is the name of the type\. This name has to
         be the name of a conversion command declared via __tclyaml write
         deftype__, see below\.

      1. The command name can be followed by additional arguments and detail
         information\.

      1. If the list contains only the command name then no additional arguments
         are assumed, and the detail information defaults to the empty string or
         list\.

         Otherwise the detail information is the last element of the list and
         anything else between command name and details are the additional
         arguments to use\.

      1. The interpretation of the detail information depends on the conversion
         command\. For examples please see the descriptions of the standard
         converters the package makes available in section [Standard converters
         for YAML generation](#section5)\.

    To convert the *value* the conversion command is run, with the additional
    arguments from the *spec*, followed by the handle of the low\-level writer
    object, the detail information from the *spec*, and the *value* itself\.
    The conversion command then uses the API of the writer object to add YAML
    structures to it, representing the value\.

  - <a name='11'></a>__tclyaml write deftype__ *name* *arguments* *body*

    This command defines a new type conversion command *name* for use in the
    __tclyaml write \.\.\.__ commands above\. This part of tclyaml is only
    relevant to users wishing to write their own type conversions\.

    The *arguments* are what has to be specified in a structure specification
    \(see *spec* above\)\. Beyond these the *body* will have access to three
    standard arguments, namely:

      * object *writer*

        This is the low\-level object instance holding the YAML structures we
        wish to generate\. The conversion command has to use its API to add the
        structures it needs to represent the *value*\.

        For more details about this object and its API please section [The
        Writer Object API](#section6)\.

      * list *structure*

        This is the detail information from the structure specification given to
        the __tclyaml write__ commands\. The conversion command may interpret
        this as it sees fit\.

        For the use type information in this data, to be applied to parts of the
        *value* \(see below\) the body has access to the otherwise internal
        command __::tclyaml::write::type::\_\_convert__\. It has to be called
        with three arguments, the *writer*, the relevant type structure
        \(extracted from our current structure\), and the value to apply it to
        \(extracted from our current value\)\.

        This allows new type converters to make use of all other types known to
        the system in their type specifications, be they builtin or custom\.

        Note, when going this far for custom conversions it is strongly
        recommended to look at the implementations of the standard converters
        for sequences and mappings provided by the package\.

      * any *value*

        This argument holds the Tcl structure to convert\.

  - <a name='12'></a>__tclyaml writeTags channel__ *chan* *value*

  - <a name='13'></a>__tclyaml writeTags file__ *path* *value*

  - <a name='14'></a>__tclyaml writeTags string__ *value*

    These three commands convert the Tcl data structure *value* into YAML\.
    Instead of taking a separate structure holding the necessary type
    information these commands expected a data structure where all elements are
    *pairs* of type and a value proper for that type\. In other words, the type
    tags are part of the incoming *value*\.

    *Note* that this is the same kind of data structure as is returned by the
    __tclyaml readTags__ command\.

    The resulting YAML is written to the channel *chan*, or to the file
    referenced by *path*, or returned as the result of the command\.

    For channels, *chan* is expected to be open for writing\. For files, an
    existing file is overwritten with the generated YAML\.

# <a name='section5'></a>Standard converters for YAML generation

The package provides the following pre\-defined conversion commands for use in
structure specifications taken by the __tclyaml write__ commands\.

  - <a name='15'></a>__string__

  - <a name='16'></a>__scalar__

    This command/type is for the conversion of plain Tcl strings\.

    No additional arguments\.

    The detail information is ignored\.

    Adds a scalar entry of type string to the writer, with the value as the
    value of the scalar\.

  - <a name='17'></a>__bool__

  - <a name='18'></a>__int__

  - <a name='19'></a>__float__

    This command/type is for the conversion of plain Tcl strings whose value
    matches the particular type\.

    No additional arguments\.

    The detail information is ignored\.

    Adds a scalar entry of the given type to the writer, with the value as the
    value of the scalar\.

    *Note* that the value is normalized according to its type, and the
    capabilities of YAML, before being written\. For example, Tcl is able to
    handle both positive and negative __NaN__'s\. YAML does not handle a
    signed NaN, thus both kinds are mapped to that\.

  - <a name='20'></a>__null__

    This command/type forces the writing of a null value to the YAML, regardless
    of the value in the provided data\. As such its use in a specification does
    not truly makes sense\. It exists mainly to have full symmetry here with the
    tags returned by __readTags__ and accepted by __writeTags__\.

    No additional arguments\.

    The detail information is ignored\.

  - <a name='21'></a>__list__

  - <a name='22'></a>__array__

  - <a name='23'></a>__sequence__

    This command/type is for the conversion of Tcl lists\. In YAML parlance,
    sequences\. In JSON parlance, arrays\.

    No additional arguments\.

    The detail information is treated as a single structure specification as
    taken by the __tclyaml write__ commands\. This specification describes
    the type with which to convert the elements of the Tcl list held in the
    *value*\.

    The converter starts a sequence in the writer object, then converts all list
    elements as per the type, and at last ends the sequence in the writer\.

  - <a name='24'></a>__dict__

  - <a name='25'></a>__object__

  - <a name='26'></a>__mapping__

    This command/type is for the conversion of Tcl dictionaries\. In YAML
    parlance, mappings\. In JSON parlance, objects\.

    No additional arguments\.

    The detail information is treated as a dictionary of structure
    specifications as taken by the __tclyaml write__ commands\. This
    dictionary describes the types with which to convert the values of the Tcl
    dictionary held in the *value*\. All keys in *value* also found as key in
    the *structure* use the associated type specification for the conversion
    of their value\. The values of all keys without an explicit conversion are
    converted with the type specification found under the key __\*__\. If such
    a key does not exist their conversion is done with type "string"\.

    The keys of *value* themselves are always converted with type "string"\.

    The converter starts a mapping in the writer object, then converts all
    dictionary elements \(keys, and values\), and at last ends the mapping in the
    writer\.

    *Note* that the mapping always writes the keys in dictionary order\.

# <a name='section6'></a>The Writer Object API

This section is only relevant to users wishing to write their own type
conversions\. See the command __tclyaml write deftype__ above, also\.

Here we are documenting the instance API of the low\-level object holding the
YAML structures we wish to generate\. Construction and destruction of these
instances is done internally by the package as needed and the relevant APIs are
not documented\. Neither are the instance methods reserved for use by the package
internals\.

  - <a name='27'></a>*writer* __alias__ *anchor*

    %%TODO%% method \- alias \- description

      * ?? *anchor*

        %%TODO%% description

  - <a name='28'></a>*writer* __sequence\-start__ ?*anchor*? ?*tag*? ?*implicit*?

    This method starts a sequence \(list\) of yaml values\.

    After this method the user has to issue calls for each value in the
    sequence, followed lastly by a call to __sequence\-end__ \(see below\), to
    close it\.

      * ?? *anchor*

        %%TODO%% description

      * ?? *tag*

        %%TODO%% description

      * boolean *implicit*

        %%TODO%% description

  - <a name='29'></a>*writer* __sequence\-end__

    This method is the complement to __sequence\-start__, above\. Calling it
    closes the currently open sequence \(which may be nested in other sequences,
    mappings, etc\)\. Calling it while not within an open sequence is an error\.

  - <a name='30'></a>*writer* __mapping\-start__ ?*anchor*? ?*tag*? ?*implicit*?

    The method starts a mapping \(dictionary\) of yaml values\.

    After this method the user has to issue calls for each key and value in the
    mapping, followed lastly by a call to __mapping\-end__ \(see below\), to
    close it\.

      * ?? *anchor*

        %%TODO%% description

      * ?? *tag*

        %%TODO%% description

      * boolean *implicit*

        %%TODO%% description

  - <a name='31'></a>*writer* __mapping\-end__

    This method is the complement to __mapping\-start__, above\. Calling it
    closes the currently open mapping \(which may be nested in other sequences,
    mappings, etc\)\. Calling it while not within an open mapping is an error\.

  - <a name='32'></a>*writer* __scalar__ *type* *value* ?*anchor*? ?*tag*?

    This method adds a single scalar *value* to the yaml structure, of the
    given *type*\. The only acceptable types are the scalar types as returned
    by __readTags__\. In other words, __bool__, __float__,
    __int__, __null__, and __string__\.

    The formatting of the value is decided automatically, based on the type,
    and, in case of strings, on the actual value\.

      * ?? *anchor*

        %%TODO%% description

      * ?? *tag*

        %%TODO%% description

  - <a name='33'></a>*writer* __blockstyle__ *style*

    These methods set the currently active formatting style for blocks
    \(sequences, mappings\)\. The active style applies only to blocks started after
    it was set\. A block opened, but not yet closed during a style change is
    *not* affected by that change\.

    The default, i\.e\. initial style is "any"\.

    The available styles are:

      * any

        %%TODO%% description

      * block

        %%TODO%% description

      * flow

        %%TODO%% description

  - <a name='34'></a>*writer* __scalarstyle__ *style*

    These methods set the currently active formatting style for scalar values\.
    The active style applies only to scalars added after it was set\.

    The default, i\.e\. initial style is "any"\.

    The available styles are

      * any

        %%TODO%% description

      * plain

        %%TODO%% description

      * single

        %%TODO%% description

      * double

        %%TODO%% description

      * literal

        %%TODO%% description

      * folded

        %%TODO%% description

# <a name='section7'></a>Bugs, Ideas, Feedback

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
