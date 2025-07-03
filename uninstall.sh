#!/bin/bash

set -e

DEST="$HOME/.local/bin/aurwrap"

if [ -f "$DEST" ]; then
    rm "$DEST"
    echo -e "\e[32mComando 'aurwrap' rimosso da $DEST\e[0m"
else
    echo -e "\e[31mNessun comando 'aurwrap' trovato in $DEST\e[0m"
fi

echo "Disinstallazione completata. Se vuoi, puoi rimuovere anche la cartella del progetto." 