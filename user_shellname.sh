# Intentionally not specifying the shell to run this script with the usual
# #!/ at the top. The very purpose of this file is to be sourced by whichever
# shell and still do its job. It's short and portable.

# IMPORTANT: this script prints back the shell that is default for the current
#            and NOT the one that is sourcing the script. If you want the
#            opposite - that is, to know the shell that's running the script,
#            use ./shellname.sh instead of this file.

# Tested with the following shells: sh, bash, zsh, tcsh, csh, fish
# On these operating systems:       FreeBSD, Ubuntu, MacOSX

sh -c 'echo "$(getent passwd $USER 2> /dev/null || echo $SHELL)" | grep -oE "[^\/]+$"'
