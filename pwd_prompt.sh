#!/usr/bin/env bash
source $BASHJAZZ_PATH/utils/path_section.sh
source $BASHJAZZ_PATH/utils/array.sh
source $BASHJAZZ_PATH/utils/colors.sh

# contains subdirectories that are to be be included int
# the displayed path after stropping. For exampple, if you're in
# directory ~/dev/myproject/src the PROMPT should be ./myproject/src
if [[ -z "$KEEP_DIR_SUFFIXES" ]]; then
  KEEP_DIR_SUFFIXES=( src )
fi

declare -A PWD_COLORS=(     \
  [default]=Green           \
  [unimportant]=Gray        \
  [standalone_tilda]=Green  \
  [home]=Dim                \
  [main]=Green              \
  [subpath]=Gray            \
  [kept_path_suffix]=Gray   \
  [strip_replacement]=Gray  \
)
declare -A CUSTOM_PWD_COLORS=()

Pwd_replace_home_with_tilda() {
  result="$(printf "$(pwd)" | sed "s|$HOME|~|")"
  if [[ "$(pwd)" == "$HOME" ]]; then
    result="$(Pwd_colorize standalone_tilda "$result")"
  fi
  printf "$result"
}

# This function breaks down path info several parts, puts them into
# different variables and highglits them according to the keys
# you see $DEFAULT_PWD_COLORS associated array. The values for
# those keys can be changed in two ways: either by creating another associative
# array - $CUSTOM_PWD_COLORS - which should contain key/value pairs you want
# altered from the default one, or by calling Pwd_colorized_print() function
# and providing it key/value value pairs as arguments (see comments above that
# function.
#
# Here's a diagram serving as an example of how the function
# would break down a particular path:
#
#                | $kept_path_suffix |
#     $base_path |   .---------------·
#     ----^------|---|--------------------
#      ~/dev/dock/src/guestmounts/dotfiles
#      |------^------|--------^----------|
#      | (git repo)  |    $subpath       |
#
#   The diagram above would be true if we ran the following command:
#   inside that directory:
#
#       $ source $BASHJAZZ_PATH/utils/pwd.sh && Pwd_strip $HOME/dev/dock/src/
#       # => ./dock/src/guestmounts/dotfiles
#
#   It would then return the string you can see above, colorized, if
#   it was requires (default: not colorized). The "./" you see prepended to
#   that string is controlled by a variable called $PWD_PATH_STRIP_REPLACEMENT,
#   so you may change it if you like by prepending calling this function or
#   other funtions that call this function with it.
#
#   However, if you were to run the same command without the argument
#   the results would be rather different:
#
#       $ source $BASHJAZZ_PATH/utils/pwd.sh && Pwd_strip
#       ./scripts 
#
#   Not quite what we expected. That's because this function doesn not care
#   or know about git or any other repositories. This is all deteremined in
#   Pwd_print() and Pwd_repo_path().
#
Pwd_strip() {
  PWD_PATH_STRIP_REPLACEMENT="${PWD_PATH_STRIP_REPLACEMENT:-./}"
  PWD_PATH_STRIP_REPLACEMENT="$(Pwd_colorize strip_replacement "$PWD_PATH_STRIP_REPLACEMENT")"

  local base_path="${1:-"$(pwd)"}"
  local name="$(basename "$base_path")"
  local full_path="$(pwd)"
  local out

  if [[ -n "$name" ]]; then

    local kept_path_suffix="$(Array_contains "$name" ${KEEP_DIR_SUFFIXES[@]})"

    local parent_dir_full_path="$(dirname "$base_path")"
    local subpath="$(echo "$full_path" | sed -E "s|^$base_path||" | sed -E "s|/$||")"

    if [[ -n "$kept_path_suffix" ]] && [[ "$base_path" == *"$kept_path_suffix" ]]; then
      out="$(basename "$parent_dir_full_path")/"
    fi

    if [[ -n "$subpath" ]]; then
      out+="$(Pwd_colorize main "$name")/$(Pwd_colorize subpath "$subpath")"
    else
      out+="$(Pwd_colorize main "$name")"
    fi

    printf "$PWD_PATH_STRIP_REPLACEMENT$out" | sed 's|//|/|g'
  else 
    printf "$(pwd)"
  fi

}

# Returns proper value from the DEFAULT_PROMPT_PATH_COLORS associative array
# if COLORIZE_PROMPT is set to a non null value. That way, we avoid a lot
# of "if-then" expressions.
# 
# Also, $2 is optional. I personally used it for testing.
Pwd_colorize() {

  local _color="$1"
  local content="$2"

  if [[ -n "$COLORIZE_PWD" ]]; then
    local _color="${PWD_COLORS[$_color]}"
    local color=${!_color}
    local color="${color:-$default_color}"
    printf "${color}${content}${!PWD_COLORS[unimportant]}"
  else
    printf "$content"
  fi
}

Pwd_in_repo_path() {
  local path="$(pwd)"
  while [[ -z "$path" ]] || [[ "$path" != "/" ]]; do
    [[ "$path" == "/" ]] && break
    if [ -d "$path/.git" ] || [ -f "$path/.fslckout" ]; then
      local repo_found=yes
      break
    else
      path="$(dirname "$path")"
    fi
  done
  [[ -n $repo_found ]] && printf "$path"
}

Pwd_colorized_print() {
  COLORIZE_PWD=1

  # Colors arre all assigned this when calling
  # the function:
  #
  #     Pwd_colorized_print main=color1 standalone_tilda=color2
  #
  # etc... So each argument passed is basically a key/value pair.
  # The associative array below defines the default values:
  for key in "${!PWD_COLORS[@]}"; do
    custom_value="$(echo "${ARGV[@]}" | grep -o "$key=[^\s]+" | grep -o "$key=")"
    if [[ -n "$custom_value" ]]; then
      PWD_COLORS[$key]="$custom_value"
    fi
  done

  printf "${!PWD_COLORS[default]}$(Pwd_print)${Color_Off}"
  # If you want to colorize your output, always use Pwd_print()
  # Unsetting COLORIZE_PWD just in case it remains dangling for some reasons.
  unset COLORIZE_PWD
}

Pwd_print() {
  local repo_path="$(Pwd_in_repo_path)"
  if [[ -n "$repo_path" ]]; then
    Pwd_strip "$repo_path"
  else
    Pwd_replace_home_with_tilda
  fi
}
