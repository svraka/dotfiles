if [[ "$TERM" != "dumb" ]] && [[ "$DISABLE_LS_COLORS" != "true" ]]; then
  PROMPT="%F{green}%n@%m%f %F{yellow}%~%f"$'\n'"%(?.%(!.#.$).%B%F{red}%(!.#.$)%f%b) "
else
  unsetopt zle
  unsetopt prompt_cr
  unsetopt prompt_subst
  PROMPT="%n@%m %~"$'\n'"%(?.%(!.#.$).%B%(!.#.$)%b) "
fi
