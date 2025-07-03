#!/bin/bash

set -e

# Percorso destinazione
DEST="$HOME/.local/bin/aurwrap"

# Crea la cartella se non esiste
mkdir -p "$HOME/.local/bin"

# Copia e rende eseguibile
cp aurwrap.sh "$DEST"
chmod +x "$DEST"

echo -e "\e[31;1mATTENZIONE: AURWRAP NON FUNZIONA CON SUDO!\e[0m"
echo "aurwrap installato in $DEST"

# Controlla se ~/.local/bin è nel PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
    echo "Aggiunto ~/.local/bin al PATH. Riavvia il terminale o esegui: source ~/.bashrc"
fi

echo "Ora puoi usare 'aurwrap' come comando da qualsiasi directory!" 