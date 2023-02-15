#!/usr/bin/env bash
#
# This scripts decides where the output goes based on the arguments provided
# or other conditions specified.
# Dash (-) arguments

declare urgency
declare timeout
declare title
declare body
declare receiver

notify() {

  gui() {

    if [[ $timeout != 0 ]]; then
      case $urgency in
        (low)       timeout=10;;
        (normal)    timeout=15;;
        (warn)      timeout=25 && urgency="normal";;
        (critical)  timeout=0;; # sticks until clicked
        (*)         timeout=10
      esac
    fi

    # In `dunstify`, --timeout is in milliseconds, so we add three zeros at the end.
    local timeout="${timeout}000"


    # NOTE:
    #
    #   `dunstify` needs to be able to send notifications to the correct user
    #   and the correct display even when launched with sudo or from root.
    #   In that case, receiver must be specified with the -r option to this
    #   function. However...
    #
    #   The below code -- strangely so -- seems now unnecessary, but I'll
    #   leave it here for cases when it might actually "kick in", because
    #   I remember those cases did exist. As of the current moment, I tried
    #   running the `./notify` script with both `sudo` and under `sudo -s`
    #   and it worked just fine: it showed notifications to my current user's
    #   desktop without specifying it explicitly.
    #
    #       local display=${DISPLAY-:':0.0'}
    #       local dbus="$(sudo -u $receiver dbus-launch head -n1 |\
    #       sed 's/DBUS_SESSION_BUS_ADDRESS=//')"
    #
    #   We then prepend the `dunstify` call with it:
    #
    #       DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=$dbus
    #
    #   However, after testing it with `sudo` and `sudo -s` (at least on Linux --
    #   I'll have to check FreeBSD) it seems to be working just fine without
    #   this additional code. Perhaps, they updates `dunsitify`, so it no longer
    #   requires these complexities.
    #
    #   SO FOR NOW THIS WORKS JUST FINE WITHOUT ALL OF THE ABOVE:
    #
    dunstify -u $urgency -t ${timeout}000 "$title" "$body" > /dev/null
  }

  cli() {
    source $BASHJAZZ_PATH/utils/formatting.sh
    local urgency=${urgency:-low}

    case $urgency in
      (low)       color="gray";;
      (normal)    color="white";;
      (warn)      color="yellow";;
      (critical)  color="red";;
    esac

    if [[ -n "$title" ]]; then
      echo -e "$(wrap "$title" "color $color; color bold")"
    fi
    echo -e "$(wrap "$body" "color $color")"
  }

  # MAIN PART OF THE FUNCTION CALLING either cli() or gui()

  # Declaring OPTIND local, so it picks up the arguments passed to the function
  # itself, not to the script.
  local OPTIND

  while getopts "t:r:u:cg" option; do
    case $option in
      # For how many seconds to display the message (only applies to GUI mode).
      # Defaults are set based on priority below, but this overrides them.
      (t) timeout="${OPTARG}";; # Because milliseconds.
      # Urgency. Affects the colors of the message that's displayed,
      # be it in GUI or CLI mode.
      (u) urgency=$OPTARG;;
      # Most probably it applies to GUI and displaying it in in dunstify.
      # In case the message must to the terminal output, the title will
      # simply be the first line, displayed in bold (formatting might change
      # in the future.
      (g) force_gui=1;;
      (c) force_cli=1;;
      (r) receiver=${OPTARG:-$(whoami)};;
    esac
  done
  shift $((OPTIND-1))

  # Title is the first positional argument,
  # Body is the second.
  #
  #  * in CLI mode $title is displayed in bold as the first line, 
  #    with the body following the linebreak.
  #
  #  * in GUI mode $title is used when calling `dunstify` as, well, the title.
  #
  title="$1"
  body="$2"
  receiver=${receiver:-$(whoami)}
  urgency=${urgency:-low}

  # Determine where the output goes
  if [[ -n "$DESKTOP_STARTUP_ID" ]]; then
    if [[ -n $force_cli ]]; then cli; else gui; fi
  else
    if [[ -n $force_gui ]]; then gui; else cli; fi
  fi

}
