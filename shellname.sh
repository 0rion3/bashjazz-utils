# Intentionally not specifying the actual shell at the top,
# as the the very purpose of this file is to be sourced by whichever
# shell is running and return the shell's name.

# This code was tested with sh, bash, zsh, tcsh and csh; On Linux and FreeBSD.
# In FreeBSD the `ps -p` returns the full path to the shell executable, not just its name,
# I had to adjust for that with another call to grep. I'm also not using the -P flag with
# grep as Perl support for grep might not be available and it's not reasonable to ask
# the user to install Perl for just this one line of code. Which is a very useful line of code.
ps -p $$ | tail -n1 | grep -Eo '[ \/][a-zA-Z]+' | tail -n1 | grep -Eo '[a-zA-Z]+'
