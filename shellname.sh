# Intentionally not specifying the shell to run this script with the usual #!/
# at the top as one of the purposes of this file is to be sourced by whichever
# shell is running and print back the shell's name with current() sub-function.

ShellName() {

  current() {
    # IMPORTANT: this script prints back the SHELL THAT CURRENT SCRIPT IS RUNNING
    # and NOT the one that's default for the user. If you want to get
    # user's default shell, use ./user_shellname.sh script.

    # Tested with the following shells: sh, bash, zsh, tcsh, csh
    # On these operating systems:       FreeBSD, Ubuntu, MacOSX
    #
    # Throws ERROR with:                FISH SHELL, it doesn't like $$
    #
    # Still, should be be highly portable.

    ps -o comm= $$ | tr -d '-' # Removing "-" character, because it's in the output
                               # in MacOSX for some reasons.
  }

  user() {
    # IMPORTANT: this script prints back the shell that is default for the
    # current and NOT the one that is sourcing the script. If you want the
    # opposite - that is, to know the shell that's running the script, use
    # current() instead of this file.

    # Tested with the following shells: sh, bash, zsh, tcsh, csh, fish
    # On these operating systems:       FreeBSD, Ubuntu, MacOSX

    if [[ -n "$(which getent)" ]]; then
      # This the usual linux/BSD way of finding out user's shell...
      sh -c 'echo "$(getent passwd $USER 2> /dev/null || echo $SHELL)" | grep -oE "[^\/]+$"'
    else
      # For MacOSX, one cannot get user's SHELL with `getent`, because it might
      # simply not be installed, which is why we use this additional code here.
      dscl . -read $HOME | grep 'UserShell:' | awk '{print $2}' | grep -oE '[a-zA-Z0-9]*$'
    fi
  }

  local cmd="$1"; shift; $cmd ${@} # calling a nested function

}
