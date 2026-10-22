# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Shopt
shopt -u array_expand_once
shopt -u assoc_expand_once
shopt -u autocd
shopt -u bash_source_fullpath
shopt -u cdable_vars
shopt -u cdspell
shopt -u checkhash
shopt -u checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -u compat31
shopt -u compat32
shopt -u compat40
shopt -u compat41
shopt -u compat42
shopt -u compat43
shopt -u compat44
shopt -s complete_fullquote
shopt -u direxpand
shopt -u dirspell
shopt -u dotglob
shopt -u execfail
shopt -u expand_aliases
shopt -u extdebug
shopt -u extglob
shopt -s extquote
shopt -u failglob
shopt -s force_fignore
shopt -s globasciiranges
shopt -s globskipdots
shopt -u globstar
shopt -u gnu_errfmt
shopt -u histappend
shopt -u histreedit
shopt -u histverify
shopt -s hostcomplete
shopt -u huponexit
shopt -u inherit_errexit
shopt -s interactive_comments
shopt -u lastpipe
shopt -u lithist
shopt -u localvar_inherit
shopt -u localvar_unset
shopt -s login_shell
shopt -u mailwarn
shopt -u no_empty_cmd_completion
shopt -u nocaseglob
shopt -u nocasematch
shopt -u noexpand_translation
shopt -u nullglob
shopt -s patsub_replacement
shopt -s progcomp
shopt -u progcomp_alias
shopt -s promptvars
shopt -u restricted_shell
shopt -u shift_verbose
shopt -s sourcepath
shopt -u varredir_close
shopt -u xpg_echo
# Functions
eval $'__systemd_osc_context_common () \n{ \n    if [ -f /etc/machine-id ]; then\n        printf ";machineid=%.36s" "$(< /etc/machine-id)";\n    fi;\n    __systemd_osc_context_escape ";user=%.255s" "$USER";\n    __systemd_osc_context_escape ";hostname=%.255s" "$HOSTNAME";\n    printf ";bootid=%.36s;pid=%.20s" "$(< /proc/sys/kernel/random/boot_id)" "$$";\n    __systemd_osc_context_escape ";cwd=%.255s" "$PWD"\n}' > /dev/null 2>&1
eval $'__systemd_osc_context_escape () \n{ \n    local systemd_format="$1";\n    local systemd_value="$2";\n    systemd_value="${systemd_value//\\\\/\\\\x5c}";\n    systemd_value="${systemd_value//;/\\\\x3b}";\n    systemd_value="${systemd_value//[[:cntrl:]]/⍰}";\n    printf "$systemd_format" "$systemd_value"\n}' > /dev/null 2>&1
eval $'__systemd_osc_context_precmdline () \n{ \n    local systemd_exitstatus="$?" systemd_signal;\n    if [ -n "${systemd_osc_context_cmd_id:-}" ]; then\n        if [ "$systemd_exitstatus" -gt 128 ] && systemd_signal=$(kill -l "$systemd_exitstatus" 2>&-); then\n            printf "\\033]3008;end=%.64s;exit=failure;status=%d;signal=SIG%s\\033\\\\" "$systemd_osc_context_cmd_id" "$systemd_exitstatus" "$systemd_signal";\n        else\n            if [ "$systemd_exitstatus" -ne 0 ]; then\n                printf "\\033]3008;end=%.64s;exit=failure;status=%d\\033\\\\" "$systemd_osc_context_cmd_id" "$systemd_exitstatus";\n            else\n                printf "\\033]3008;end=%.64s;exit=success\\033\\\\" "$systemd_osc_context_cmd_id";\n            fi;\n        fi;\n    fi;\n    if [ -z "${systemd_osc_context_shell_id:-}" ]; then\n        read -r systemd_osc_context_shell_id < /proc/sys/kernel/random/uuid;\n    fi;\n    printf "\\033]3008;start=%.64s;type=shell%s\\033\\\\" "$systemd_osc_context_shell_id" "$(__systemd_osc_context_common)";\n    read -r systemd_osc_context_cmd_id < /proc/sys/kernel/random/uuid\n}' > /dev/null 2>&1
eval $'__systemd_osc_context_ps0 () \n{ \n    [ -n "${systemd_osc_context_cmd_id:-}" ] || return;\n    printf "\\033]3008;start=%.64s;type=command%s\\033\\\\" "$systemd_osc_context_cmd_id" "$(__systemd_osc_context_common)"\n}' > /dev/null 2>&1
eval $'gawklibpath_append () \n{ \n    [ -z "$AWKLIBPATH" ] && AWKLIBPATH=`gawk \'BEGIN {print ENVIRON["AWKLIBPATH"]}\'`;\n    export AWKLIBPATH="$AWKLIBPATH:$*"\n}' > /dev/null 2>&1
eval $'gawklibpath_default () \n{ \n    unset AWKLIBPATH;\n    export AWKLIBPATH=`gawk \'BEGIN {print ENVIRON["AWKLIBPATH"]}\'`\n}' > /dev/null 2>&1
eval $'gawklibpath_prepend () \n{ \n    [ -z "$AWKLIBPATH" ] && AWKLIBPATH=`gawk \'BEGIN {print ENVIRON["AWKLIBPATH"]}\'`;\n    export AWKLIBPATH="$*:$AWKLIBPATH"\n}' > /dev/null 2>&1
eval $'gawkpath_append () \n{ \n    [ -z "$AWKPATH" ] && AWKPATH=`gawk \'BEGIN {print ENVIRON["AWKPATH"]}\'`;\n    export AWKPATH="$AWKPATH:$*"\n}' > /dev/null 2>&1
eval $'gawkpath_default () \n{ \n    unset AWKPATH;\n    export AWKPATH=`gawk \'BEGIN {print ENVIRON["AWKPATH"]}\'`\n}' > /dev/null 2>&1
eval $'gawkpath_prepend () \n{ \n    [ -z "$AWKPATH" ] && AWKPATH=`gawk \'BEGIN {print ENVIRON["AWKPATH"]}\'`;\n    export AWKPATH="$*:$AWKPATH"\n}' > /dev/null 2>&1
# Shell Options
set -o braceexpand
set -o hashall
set -o interactive-comments
set -o monitor
set -o onecmd
shopt -s expand_aliases
# Aliases
# Check for rg availability
if ! hash rg 2>/dev/null && ! typeset -f rg >/dev/null 2>&1; then
  function rg {
  local _cc_bin="${CLAUDE_CODE_EXECPATH:-}"
  [[ -x $_cc_bin ]] || _cc_bin=/home/pipo/.local/bin/claude
  if [[ ! -x $_cc_bin ]]; then command rg ${1+"$@"}; return; fi
  if [[ -n ${ZSH_VERSION:-} ]]; then
    ARGV0=rg "$_cc_bin" ${1+"$@"}
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=rg "$_cc_bin" ${1+"$@"}
  else
    (exec -a rg "$_cc_bin" ${1+"$@"})
  fi
}
fi
# Shadow find/grep with embedded bfs/ugrep
unalias find 2>/dev/null || true
unalias grep 2>/dev/null || true
function find {
  local _cc_bin="${CLAUDE_CODE_EXECPATH:-}"
  [[ -x $_cc_bin ]] || _cc_bin=/home/pipo/.local/bin/claude
  if [[ ! -x $_cc_bin ]]; then command find ${1+"$@"}; return; fi
  if [[ -n ${ZSH_VERSION:-} ]]; then
    ARGV0=bfs "$_cc_bin" -S dfs -regextype findutils-default ${1+"$@"}
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=bfs "$_cc_bin" -S dfs -regextype findutils-default ${1+"$@"}
  else
    (exec -a bfs "$_cc_bin" -S dfs -regextype findutils-default ${1+"$@"})
  fi
}
function grep {
  local _cc_a
  for _cc_a in ${1+"$@"}; do
    case "$_cc_a" in -*-filter*|-*-pager*|-*-view*|-*-format-open*|-*-config*|---*|-@*|-*-save-config*|-[Zz]*|-[!-]*[Zz]*|--null|--null-data) command grep ${1+"$@"}; return ;; esac
  done
  local _cc_bin="${CLAUDE_CODE_EXECPATH:-}"
  [[ -x $_cc_bin ]] || _cc_bin=/home/pipo/.local/bin/claude
  if [[ ! -x $_cc_bin ]]; then command grep ${1+"$@"}; return; fi
  if [[ -n ${ZSH_VERSION:-} ]]; then
    ARGV0=ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl ${1+"$@"}
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    ARGV0=ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl ${1+"$@"}
  else
    (exec -a ugrep "$_cc_bin" -G --ignore-files --hidden -I --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=.bzr --exclude-dir=.jj --exclude-dir=.sl ${1+"$@"})
  fi
}
# Shadow pkill to refuse patterns matching the CLI process
unalias pkill 2>/dev/null || true
function pkill {
  if [ -n "${CLAUDE_PID:-}" ] && [ -r "/proc/${CLAUDE_PID}/comm" ]; then
    local _cc_skip="" _cc_a
    local -a _cc_probe=()
    for _cc_a in ${1+"$@"}; do
      if [ -n "$_cc_skip" ]; then _cc_skip=""; continue; fi
      case "$_cc_a" in
        --signal) _cc_skip=1 ;;
        --signal=*|-e|--echo) ;;
        -[0-9]*) ;;
        -[PUGOF]?*) _cc_probe+=("$_cc_a") ;;
        -[ABCDEFGHIJKLMNOPQRSTUVWXYZ][ABCDEFGHIJKLMNOPQRSTUVWXYZ0-9]*) ;;
        *) _cc_probe+=("$_cc_a") ;;
      esac
    done
    if command pgrep ${_cc_probe[@]+"${_cc_probe[@]}"} 2>/dev/null | command grep -qx "${CLAUDE_PID}"; then
      printf 'pkill: refusing to run — this pattern matches the Claude CLI process (PID %s). Narrow the pattern, or target your own children with `pkill -P $$ ...`.\n' "${CLAUDE_PID}" >&2
      return 1
    fi
  fi
  command pkill ${1+"$@"}
}
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/pipo/.local/share/JetBrains/Toolbox/scripts:/home/pipo/.dotnet/tools
