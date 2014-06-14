DTrace book scripts
===================

Scripts from "DTrace: Dynamic Tracing in Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro, Prentice Hall, 2011.
ISBN-10: 0132091518, ISBN-13: 978-0132091510

This is a copy of the scripts published on http://dtracebook.com, and is a static collection to support the book.

See the book for descriptions of these scripts, examples, and any related warnings.

WARNING: These scripts are not tools that are expected to work. They are examples of solving problems, but are often tied to the kernel version they were written for. You can treat them as starting points: they embody an idea, approach, and presentation for an observability problem. Their implementation details will likely need adjusting to work correctly on your OS. This is explained, in detail, in the book, which should help you use and update the scripts as needed.

The hardest part of using DTrace is knowing what to do with it. That is what these scripts provide -- proven usage ideas. Even if they don't work on your current kernel version, they still help with the hardest problem faced by new users of DTrace, showing by example what can be done. The nature of dynamic tracing (the DTrace fbt and pid providers) means that writing tools that work across every OS, now, and in the future, is not possible.

If you repurpose a script (in the same way that a reader of a textbook might reuse an example), I'd ask that you please identify the origin in the script; eg, in the header:

```
 * Based on a script from Chapter X of the book: DTrace: Dynamic Tracing in
 * Oracle Solaris, Mac OS X, and FreeBSD", by Brendan Gregg and Jim Mauro,
 * Prentice Hall, 2011. ISBN-10: 0132091518. http://dtracebook.com.
```

Thanks Mike Harsch for transcribing and testing these scripts.
