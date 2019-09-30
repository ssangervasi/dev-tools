##
# Navigiate to directories of files that have been edited.
# Mostly handy for tab completion.

git_cd() {
  local repo_root="$(git root-dir)"
  # First arg can be used a ref for completion, but is optional.
  # Use second arg, first arg, or repo root.
  local destination="${2:-${1:-${repo_root}}}"
  cd "${destination}"
}

alias cdg=git_cd

_complete_git_cd() {
  if (( $COMP_CWORD > 2 )); then
    return 0
  fi

  # Use the first argument as ref, if passed.
  local ref='head'
  if (( $COMP_CWORD > 1 )); then
    ref="${COMP_WORDS[1]}"
  fi
  # echo_info "$COMP_CWORD | ${COMP_WORDS[@]} | $ref"

  local diff_paths=$(
    git diff \
      --name-only \
      --relative \
      "${ref}" 2>/dev/null
  )
  if [[ -z ${diff_paths} ]]; then
    return 0
  fi

  local diff_dirs=$(
    echo "${diff_paths}" |
      while read one_path; do
        dirname "${one_path}"
      done |
      grep -Ev '^.$'
  )

  local current_word="${COMP_WORDS[$COMP_CWORD]}"
  COMPREPLY=(
    $(IFS=$'\n' compgen -W "${diff_dirs}" "${current_word}")
  )
}

complete -o bashdefault -F _complete_git_cd git_cd cdg
