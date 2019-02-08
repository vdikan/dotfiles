# Minimalistic zsh inspired by:
# https://zserge.com/blog/terminal.html
#
autoload -U compinit colors
#vcs_info
colors
compinit
# Report command running time if it is more than 3 seconds
REPORTTIME=3
# Keep a lot of history
HISTFILE=~/.zhistory
HISTSIZE=5000
SAVEHIST=5000
# Add commands to history as they are entered, don't wait for shell to exit
setopt INC_APPEND_HISTORY
# Also remember command start time and duration
setopt EXTENDED_HISTORY
# Do not keep duplicate commands in history
setopt HIST_IGNORE_ALL_DUPS
# Do not remember commands that start with a whitespace
setopt HIST_IGNORE_SPACE
# Correct spelling of all arguments in the command line
#setopt CORRECT_ALL
# Enable autocompletion
zstyle ':completion:*' completer _complete _approximate

_setup_ps1() {
#  vcs_info
  GLYPH="↪"
  PS1=" %(?.%F{blue}.%F{red})$GLYPH%f %(1j.%F{cyan}[%j]%f .)%F{blue}%2~%f "
}
_setup_ps1

# user-friendly command output
export CLICOLOR=1
ls --color=auto &> /dev/null && alias ls='ls --color=auto'


# The following is inspired by (read: stolen)
# https://ebzzry.io/en/

function def_real_alias () {
  while [[ $# -ge 2 ]]; do
    alias "$1=$2"
    shift 2
  done
}

function def_real_aliases () {
  def_real_alias $real_aliases
  unset real_aliases
}

function def_global_alias () {
  while [[ $# -ge 2 ]]; do
    alias -g "$1=$2"
    shift 2
  done
}

function def_global_aliases () {
  def_global_alias $global_aliases
  unset global_aliases
}

function def_fun () {
  while [[ $# -ge 2 ]]; do
    eval "function $1 () { $2 \$@ }"
    shift 2
  done
}

function def_funs () {
  def_fun $funs
  unset funs
}

real_aliases=(
  meh "echo meh"
); def_real_aliases

global_aliases=(
  ecl "emacsclient -c"  # emacs in window
  ec "emacsclient -nw"  # emacs in shell

  :: ':>!'

  B '`git rev-parse --abbrev-ref HEAD`'

  V "|& less"
  G "|& egrep --color"
  S "|& sort"
  R "|& sort -rn"
  L "|& wc -l | sed 's/^\ *//'"

  H  "|& head"
  T  "|& tail"
  H1 "H -n 1"
  T1 "T -n 1"

  ZF '*(.L0)'     # zero-length regular files
  ZD '*(/L0)'     # zero-length directories

  AE '{,.}*'      # all files, including dot files
  AF '**/*(.)'    # all regular files
  AD '**/*(/)'    # all directories
  AS '**/*(@)'    # all symlinks

  OF '*(.om[-1])' # oldest regular file
  OD '*(/om[-1])' # oldest directory
  OS '*(@om[-1])' # oldest symlink

  NF '*(.om[1])'  # newest regular file
  ND '*(/om[1])'  # newest directory
  NS '*(@om[1])'  # newest symlink

); def_global_aliases

funs=(
  z "exec zsh"
  s "sudo"

  d "pushd"
  \- "popd"
  ds "dirs -l"

  cp "command cp -i"
  mv "command mv -i"

  l "ls -GFAtr --color"
  la "ls -AF --color"
  ll "l -l"
  l1 "l -1"
  lh "l -H"
  lr "l -R"
  lk "la -l"

  # t "tree"
  # t1 "tree -L 1"
  # t2 "tree -L 2"
  # t3 "tree -L 3"

  sl "ln -sf"
  md "mkdir -p"

  # f "fd"
  g "grep --color=auto"
  gi "g -i"
  tf "tail -F"
  rh "rehash"

  mount "s mount"
  umount "s umount"
  reboot "s reboot"
  poweroff "s poweroff"
  halt "s halt -p"
); def_funs


# Saving and restoring directory stack:
function z! () {
  dirs -lv | awk -F '\t' '{print $2}' | tac >! $HOME/.z
  exec zsh
}

function z+ () {
  if [[ -f $HOME/.z ]]; then
      local pwd=$PWD

      while read -r line; do
        pushd "$line"
      done < $HOME/.z

      pushd $pwd
  fi
}

# Aliases for tree-ing:
function t () {
    if [[ "$1" == [0-9] ]]; then
        tree -L $@
    else
        tree $@
    fi
}

for n in {1..9}; do
    def_global_alias t$n "t "$n;
done
