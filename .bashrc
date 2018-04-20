# Aliases

if [ $(expr index "$-" i) -eq 0 ]; then
    return
fi

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile
fi
