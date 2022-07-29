#!/usr/bin/env bash

newline='
'

is_root()  { if [[ $UID == 0 && $EUID == 0 ]]; then return 0; else return 1; fi; }
not_root() { if is_root;                       then return 1; else return 0; fi; }

rootrun() {

  # You can provide additional options for sudo by
  # prefixing the command with SUDO_OPTIONS='...'
  # Example:
  #
  #   WITH_SUDO_OPTIONS='-u myuser' rootrun touch ls /root

  # Consider that different scripts might use a different variable
  sudo_password="${sudo_password:-"$sudo_pass"}"
  sudo_password="${sudo_password:-"$password"}"

  # Only request for password if script is not running as root
  if not_root; then
    # Checks if already have the password. If not, let's request it.
    if [[ -z "$sudo_password" ]]; then
      # rootrun is typically called many times, we don't want to be checking
      # whether password was already request in every script that uses it.
      declare -g sudo_password="$($BASHJAZZZ_PATH/utils/request_password "Password for sudo")"
      echo ""
    fi
  fi

  if not_root; then
    prefix="echo \"$sudo_password\" | sudo -S $WITH_SUDO_OPTIONS"
  fi

  if [[ "$1" == *"$newline"* ]]; then
    readarray -t commands <<<"$1" # splits by newlines, each command is run with its own sudo and prefix

    # But we have to account for \ chars, which extend the command
    # so we store commands in full_command var and then clear it when
    # we hit \n that isn't preceded by the \ char.
    full_command=""
    for c in "${commands[@]}"; do
      if echo "$c" | grep -E '\\\s*'; then
        full_command="$full_command $(echo "$c" | sed 's/\\/ /')"
      else
        eval "$prefix $full_command $c"
        full_command=""
      fi
    done
  else
    eval "$prefix $1"
  fi

  unset WITH_SUDO_OPTIONS

}
