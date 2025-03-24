##
# Navigiate to directories of files that have been edited.
# Mostly handy for tab completion.

git_cd() {
  REPO_ROOT="$(git root-dir)"
  # First arg can be used a ref for completion, but is optional.
  # Use second arg, first arg, or repo root.
  DEST="${2:-${1:-${REPO_ROOT}}}"

  find_dest
  if [[ $? > 0 ]]; then
    return $YA_DUN_GOOFED
  fi

  cd "${FOUND_DEST}"
}

find_dest() {
  if [[ -d "${DEST}" ]]; then
    FOUND_DEST="${DEST}"
    return
  elif [[ -d "${REPO_ROOT}/${DEST}" ]]; then
    FOUND_DEST="${REPO_ROOT}/${DEST}"    
    return
  fi

  DEST_DIR=$(dirname "${DEST}")

  if [[ -d "${DEST_DIR}" ]]; then
    FOUND_DEST="${DEST_DIR}"
    return
  elif [[ -d "${REPO_ROOT}/${DEST_DIR}" ]]; then
    FOUND_DEST="${REPO_ROOT}/${DEST_DIR}"    
    return
  fi

  echo_error "Can't find "${DEST}""
  return $YA_DUN_GOOFED
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
