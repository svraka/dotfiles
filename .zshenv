# Windows MSYS2 specific env
if [[ "$OSTYPE" = msys ]]; then
  # Executable path to `statab.sh`. Needs to be set as a Windows-style
  # path.
  export STATA_EXEC="C:/Program Files (x86)/Stata15/StataSE-64.exe"

  # Path for the utilities outside MSYS2/MinGW. We use Git for Windows
  # because it seems to be more reliable and it has `wincred`.
  PATH_GIT_FOR_WINDOWS="/d/Git/cmd"
  PATH_MIKTEX="/d/MiKTeX/miktex/bin/x64"
  PATH_R="/d/R/$(ls -v1 /d/R/ | tail -1)/bin/x64"
  PATH_BIN_MISC="/d/bin"

  # MSYS2 is on D: because of silly corporate policy and uses tempdirs
  # there but we don't have enoug space, so we set all sorts of
  # tempdir to the regular Windows tempdir.
  export TEMP="/c/Users/$USER/AppData/Local/Temp"
  export TMP="/c/Users/$USER/AppData/Local/Temp"

  # This is used by statab.sh.
  export TMPDIR="/c/Users/$USER/AppData/Local/Temp"
fi
