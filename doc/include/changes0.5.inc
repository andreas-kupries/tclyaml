[subsection {Changes for version 0.5}]

[para] In detail:

[list_begin enumerated]
[comment {- - -- --- ----- -------- ------------- ---------------------}]

[enum] As a non-breaking change, a test suite was added.

[para] All following changes are breaking, versus version [const 0.4].

[enum] Removed the untyped structure tag [const scalar].  Replaced it
       with five new tags providing type information:

[list_begin enumerated]
[enum] [const bool]
[enum] [const float]
[enum] [const int]
[enum] [const null]
[enum] [const string]
[list_end]

[enum] When reading YAML data types are now determined as per the
       [vset yaml/schema/core] rules. And the assumption that quoted
       values are always strings, and none of the other types.

[enum] Read values are now normalized, as per their type. For example,
       the internally seen value of an integer is always in decimal
       form, regardless of if it was octal or hex in the input.

[enum] On the writing side the new structural tags now exist as
       pre-defined type converters. The [const scalar] converter is
       still present, and aliases now to [const string]. In the
       previous version [const string] aliased to [const scalar] as
       the only scalar type.

[enum] Most styling of scalar values is now automatically determined
       by their type, and, in case of strings, by the value as well.

[comment {- - -- --- ----- -------- ------------- ---------------------}]
[list_end]
