# Make a cuppa
export HOMEBREW_INSTALL_BADGE="☕️"

# Set config location to ~/.config where possible
export PARALLEL_HOME=~/.config/parallel

if [[ "$OSTYPE" = msys ]]; then
  # Always use the regular Windows temp directory instead of
  # /tmp. This also works with R.
  export TMPDIR=$HOME/AppData/Local/Temp
  export TMP=$TMPDIR
  export TEMP=$TMPDIR
fi
