# Intentionally not specifying the shell to run this script with the usual
# #!/ at the top. The very purpose of this file is to be sourced by whichever
# shell is running and print back the shell's name.

# IMPORTANT: this script prints back the SHELL THAT CURRENT SCRIPT IS RUNNING
#            and NOT the one that's default for the user. If you want to get
#            user's default shell, use ./user_shellname.sh script.

# Tested with the following shells: sh, bash, zsh, tcsh, csh
# On these operating systems:       FreeBSD, Ubuntu, MacOSX
#
# Throws ERROR with:                FISH SHELL, it doesn't like $$
#
# Still, should be be highly portable

ps -o comm= $$ | tr -d '-' # Removing "-" character, because it's in the output
                           # in MacOSX for some reasons.
