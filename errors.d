Ddoc

$(SPEC_S Error Handling in D,

$(BLOCKQUOTE 
I came, I coded, I crashed. -- Julius C'ster
)

All programs have to deal with errors. Errors are unexpected conditions that
are not part of the normal operation of a program. Examples of common errors
are:

$(UL 
	$(LI Out of memory.)
	$(LI Out of disk space.)
	$(LI Invalid file name.)
	$(LI Attempting to write to a read-only file.)
	$(LI Attempting to read a non-existent file.)
	$(LI Requesting a system service that is not supported.)
)

<h2>The Error Handling Problem</h2>

The traditional C way of detecting and reporting errors is not traditional,
it is ad-hoc and varies from function to function, including:

$(UL 
	$(LI Returning a NULL pointer.)
	$(LI Returning a 0 value.)
	$(LI Returning a non-zero error code.)
	$(LI Requiring errno to be checked.)
	$(LI Requiring that a function be called to check if the previous
		function failed.)
)

To deal with these possible errors, tedious error handling code must be added
to each function call. If an error happened, code must be written to recover
from the error, and the error must be reported to the user in some user friendly
fashion. If an error cannot be handled locally, it must be explicitly
propagated back to its caller.
The long list of errno values needs to be converted into appropriate
text to be displayed. Adding all the code to do this can consume a large part
of the time spent coding a project - and still, if a new errno value is added
to the runtime system, the old code can not properly display a meaningful
error message.
<p>

Good error handling code tends to clutter up what otherwise would be a neat
and clean looking implementation.
<p>

Even worse, good error handling code is itself error prone, tends to be the
least tested (and therefore buggy) part of the project, and is frequently
simply omitted. The end result is likely a "blue screen of death" as the
program failed to deal with some unanticipated error.
<p>

Quick and dirty programs are not worth writing tedious error handling code
for, and so such utilities tend to be like using a table saw with no
blade guards.
<p>

What's needed is an error handling philosophy and methodology such that:

$(UL 
	$(LI It is standardized - consistent usage makes it more useful.)
	$(LI The result is reasonable even if the programmer fails
	to check for errors.)
	$(LI Old code can be reused with new code without having
	to modify the old code to be compatible with new error types.)
	$(LI No errors get inadvertently ignored.)
	$(LI 'Quick and dirty' utilities can be written that still
	correctly handle errors.)
	$(LI It is easy to make the error handling source code look good.)
)

<h2>The D Error Handling Solution</h2>

Let's first make some observations and assumptions about errors:

$(UL 
	$(LI Errors are not part of the normal flow of a program. Errors
	are exceptional, unusual, and unexpected.)
	$(LI Because errors are unusual, execution of error handling code
	is not performance critical.)
	$(LI The normal flow of program logic is performance critical.)
	$(LI All errors must be dealt with in some way, either by
	code explicitly written to handle them, or by some system default
	handling.)
	$(LI The code that detects an error knows more about the error
	than the code that must recover from the error.)
)

The solution is to use exception handling to report errors. All errors are
objects derived from abstract class Error. class Error has a pure virtual
function called toString() which produces a char[] with a human readable
description of the error.
<p>

If code detects an error like "out of memory," then an Error is thrown
with a message saying "Out of memory". The function call stack is unwound,
looking for a handler for the Error.
$(LINK2 statement.html#TryStatement, Finally blocks)
are executed as the
stack is unwound. If an error handler is found, execution resumes there. If
not, the default Error handler is run, which displays the message and
terminates the program.
<p>

How does this meet our criteria?

<dl>
	<dt> It is standardized - consistent usage makes it more useful.
	<dd> This is the D way, and is used consistently in the D
	    runtime library and examples.

	<dt> The result is reasonable result even if the programmer fails
	to check for errors.
	<dd> If no catch handlers are there for the errors, then the
	program gracefully exits through the default error handler
	with an appropriate message.

	<dt> Old code can be reused with new code without having
	to modify the old code to be compatible with new error types.
	<dd> Old code can decide to catch all errors, or only specific ones,
	propagating the rest upwards. In any case, there is no more
	need to correlate error numbers with messages, the correct message
	is always supplied.

	<dt> No errors get inadvertently ignored.
	<dd> Error exceptions get handled one way or another. There is nothing
	like a NULL pointer return indicating an error, followed by trying to
	use that NULL pointer.

	<dt> 'Quick and dirty' utilities can be written that still
	correctly handle errors.
	<dd> Quick and dirty code need not write any error handling code at
	all, and don't need to check for errors. The errors will be caught,
	an appropriate message displayed, and the program gracefully shut down
	all by default.

	<dt> It is easy to make the error handling source code look good.
	<dd> The try/catch/finally statements look a lot nicer than endless
	if (error) goto errorhandler; statements.
</dl>

How does this meet our assumptions about errors?

<dl>
	<dt> Errors are not part of the normal flow of a program. Errors
	are exceptional, unusual, and unexpected.
	<dd> D exception handling fits right in with that.

	<dt> Because errors are unusual, execution of error handling code
	is not performance critical.
	<dd> Exception handling stack unwinding is a relatively slow process.

	<dt> The normal flow of program logic is performance critical.
	<dd> Since the normal flow code does not have to check every
	function call for error returns, it can be realistically faster
	to use exception handling for the errors.

	<dt> All errors must be dealt with in some way, either by
	code explicitly written to handle them, or by some system default
	handling.
	<dd> If there's no handler for a particular error, it is handled
	by the runtime library default handler. If an error is ignored,
	it is because the programmer specifically added code to ignore
	an error, which presumably means it was intentional.

	<dt> The code that detects an error knows more about the error
	than the code that must recover from the error.
	<dd> There is no more need to translate error codes into human
	readable strings, the correct string is generated by the error
	detection code, not the error recovery code. This also leads to
	consistent error messages for the same error between applications.
</dl>

Using exceptions to handle errors leads to another issue - how to write
exception safe programs. $(LINK2 exception-safe.html, Here's how).

$(COMMENT
	$(OL 

	$(LI Programmers, especially inexperienced ones, tend to neglect
	to test for the special error return value.
	Their code just assumed the function completed successfully.
	This leads to erratic and unpredictable 
	behavior if the function did fail.)

	$(LI How each function deals with errors tends to be unique and
	inconsistent, leading to more unintended
	programmatic errors.)

	$(LI How the error gets reported to the user tends to vary
	arbitrarily from one program to the next and one
	error case to the next.)

	$(LI Dealing with error cases causes tedious and error-prone code
	to be written, and so can consume much
	programming effort.)

	$(LI Error handling logic tends to be buggy because it rarely
	gets tested by the test team.)

	$(LI Functions that should have clean interfaces wind up
	cluttering them with error return parameters and
	cases.)

	)
)

)

Macros:
	TITLE=Errors
	WIKI=Errors

