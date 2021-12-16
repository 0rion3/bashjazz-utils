# Intentionally nor specifying the actual shell at the top,
# as the the very purpose of this file is to be sourced by whichever
# shell is running and return this shell's name.

# This code was tested under sh, bash, zsh, tcsh and csh, under Linux and FreeBSD
# In FreeBSD the `ps -p` returns full path to the shell executable, not just it's name,
# so we had to adjust for that with another grep. We're also not using the -P flag with
# grep as Perl support for grep might not be available and it's not reasonable to ask
# the user to install Perl for just this one line of code. Which is very useful indeed.
ps -p $$ | tail -n1 | grep -Eo '[ \/][a-zA-Z]+' | tail -n1 | grep -Eo '[a-zA-Z]+'
