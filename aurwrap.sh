#!/bin/bash

# Funzione: mostra l'help
usage() {
    echo "Uso: $0 {search|install|update|remove|update-wrapper|self-update} nome_pacchetto"
    echo "  search         - Cerca un pacchetto nei repo ufficiali e su AUR"
    echo "  install        - Installa un pacchetto (repo ufficiali o AUR)"
    echo "  update         - Aggiorna un pacchetto AUR (pull, ricompila, reinstalla)"
    echo "  remove         - Rimuove un pacchetto installato"
    echo "  update-wrapper - Aggiorna il wrapper manualmente"
    echo "  self-update    - Aggiorna automaticamente il wrapper dal repository git"
}

# Funzione: logga errori
log_error() {
    echo "[$(date)] ERRORE: $1" >> aurwrap_error.log
}

# Funzione: controlla dipendenze base
check_deps() {
    for dep in git curl makepkg pacman; do
        if ! command -v $dep >/dev/null 2>&1; then
            echo "Dipendenza mancante: $dep"
            log_error "Dipendenza mancante: $dep"
            exit 1
        fi
    done
}

# Funzione: cerca pacchetto
search_pkg() {
    echo "[Repo ufficiali]"
    pacman -Ss "$1"
    echo
    echo "[AUR]"
    if command -v jq >/dev/null 2>&1; then
        curl -s "https://aur.archlinux.org/rpc/?v=5&type=search&arg=$1" | jq -r '
            if .resultcount == 0 then
                "Nessun risultato trovato su AUR."
            else
                "Nome\t\tDescrizione"
                + "\n" +
                ( .results[] | "\(.Name)\t\t\(.Description)" )
                | join("\n")
            end'
    else
        echo "Per una migliore leggibilità installa jq (sudo pacman -S jq)"
        echo "Impossibile mostrare i risultati AUR senza jq."
    fi
}

# Funzione: installa pacchetto AUR
install_aur() {
    if pacman -Qi "$1" >/dev/null 2>&1; then
        echo "Il pacchetto '$1' risulta già installato. Vuoi reinstallarlo? [s/N]"
        read -r conferma
        if [[ ! "$conferma" =~ ^[sS]$ ]]; then
            echo "Installazione annullata."
            return 1
        fi
    fi
    git clone "https://aur.archlinux.org/$1.git" || { echo "Errore nel clonare il pacchetto."; exit 1; }
    cd "$1" || exit 1
    echo "Controllo dipendenze e conflitti..."
    makepkg -s --nobuild || { echo "Errore nelle dipendenze o conflitti."; cd ..; rm -rf "$1"; exit 1; }
    read -p "Procedere con la compilazione e installazione di '$1'? [s/N]: " conferma
    if [[ ! "$conferma" =~ ^[sS]$ ]]; then
        echo "Installazione annullata."
        cd ..
        rm -rf "$1"
        return 1
    fi
    makepkg -si --noconfirm
    cd ..
    rm -rf "$1"
}

# Funzione: aggiorna pacchetto AUR
update_aur() {
    if [ ! -d "$1" ]; then
        echo "Clono il pacchetto $1..."
        git clone "https://aur.archlinux.org/$1.git" || { echo "Errore nel clonare il pacchetto."; log_error "Errore clone $1"; exit 1; }
    fi
    cd "$1" || { echo "Cartella $1 non trovata."; log_error "Cartella $1 non trovata"; exit 1; }
    git pull || { echo "Errore nel fare pull."; log_error "Errore pull $1"; exit 1; }
    makepkg -si --noconfirm
    cd ..
    rm -rf "$1"
}

# Funzione: rimuove pacchetto
remove_pkg() {
    if ! pacman -Qi "$1" >/dev/null 2>&1; then
        echo "Il pacchetto '$1' non risulta installato."
        return 1
    fi
    read -p "Vuoi davvero rimuovere '$1'? [s/N]: " conferma
    if [[ ! "$conferma" =~ ^[sS]$ ]]; then
        echo "Rimozione annullata."
        return 1
    fi
    sudo pacman -Rns "$1"
}

# Funzione: installa pacchetto (repo ufficiali o AUR)
install_pkg() {
    if pacman -Qi "$1" >/dev/null 2>&1; then
        echo "Il pacchetto '$1' risulta già installato. Vuoi reinstallarlo? [s/N]"
        read -r conferma
        if [[ ! "$conferma" =~ ^[sS]$ ]]; then
            echo "Installazione annullata."
            return 1
        fi
    fi
    # Installa automaticamente dai repo ufficiali se disponibile, altrimenti da AUR
    if pacman -Si "$1" >/dev/null 2>&1; then
        echo "Il pacchetto '$1' è disponibile nei repo ufficiali. Procedo con pacman."
        sudo pacman -S "$1"
    else
        install_aur "$1"
    fi
}

# Funzione: aggiorna il wrapper
update_wrapper() {
    SCRIPT_PATH="$(realpath "$0")"
    DEST="$HOME/.local/bin/aurwrap"
    cp "$SCRIPT_PATH" "$DEST"
    chmod +x "$DEST"
    echo "Wrapper aggiornato in $DEST"
}

# Funzione: self-update dal repository git
self_update() {
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    if [ -d "$SCRIPT_DIR/.git" ]; then
        echo "Aggiornamento dal repository git..."
        git -C "$SCRIPT_DIR" pull && update_wrapper && echo "Aggiornamento completato!" || echo "Errore durante l'aggiornamento."
    else
        echo "Self-update disponibile solo se hai installato aurwrap tramite git clone."
        echo "Altrimenti, scarica manualmente la nuova versione dal repository."
    fi
}

# Main
check_deps
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    usage
    exit 0
fi
if [ "$1" == "update-wrapper" ]; then
    update_wrapper
    exit 0
fi
if [ "$1" == "self-update" ]; then
    self_update
    exit 0
fi
case "$1" in
    search)
        if [ -z "$2" ]; then usage; exit 1; fi
        search_pkg "$2"
        ;;
    install)
        if [ -z "$2" ]; then usage; exit 1; fi
        install_pkg "$2"
        ;;
    update)
        if [ -z "$2" ]; then usage; exit 1; fi
        update_aur "$2"
        ;;
    remove)
        if [ -z "$2" ]; then usage; exit 1; fi
        remove_pkg "$2"
        ;;
    *)
        usage
        ;;
esac 