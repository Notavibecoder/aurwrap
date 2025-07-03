# aurwrap

**aurwrap** è un wrapper/software manager tutto italiano per Arch Linux, pensato per semplificare la gestione dei pacchetti sia dai repository ufficiali che da AUR, con un'interfaccia semplice e scriptabile.

## Funzionalità principali
- Ricerca pacchetti nei repository ufficiali e su AUR
- Installazione automatica da repo ufficiali o AUR
- Aggiornamento pacchetti AUR
- Rimozione pacchetti
- Aggiornamento automatico del wrapper tramite git (`self-update`)
- Comandi user-friendly e messaggi chiari

## Installazione
1. Clona la repository:
   ```bash
   git clone <URL-della-tua-repo>
   cd aurwrap
   ```
2. Installa il wrapper:
   ```bash
   bash install.sh
   ```
   **ATTENZIONE: AURWRAP NON FUNZIONA CON SUDO!**

## Utilizzo
Esegui i comandi senza sudo:

- Cerca un pacchetto:
  ```bash
  aurwrap search nome_pacchetto
  ```
- Installa un pacchetto (repo ufficiali o AUR):
  ```bash
  aurwrap install nome_pacchetto
  ```
- Aggiorna un pacchetto AUR:
  ```bash
  aurwrap update nome_pacchetto
  ```
- Rimuovi un pacchetto:
  ```bash
  aurwrap remove nome_pacchetto
  ```
- Aggiorna il wrapper dal repository git:
  ```bash
  aurwrap self-update
  ```
- Aggiorna manualmente il comando wrapper:
  ```bash
  aurwrap update-wrapper
  ```
- Mostra il menù di help:
  ```bash
  aurwrap -h
  ```

## Disinstallazione
Per rimuovere aurwrap:
```bash
bash uninstall.sh
```

## Note
- Non usare mai `sudo aurwrap`! Lo script chiederà la password solo quando necessario.
- Per aggiornare il wrapper, usa `aurwrap self-update` se hai installato tramite git, oppure aggiorna manualmente la cartella e lancia `aurwrap update-wrapper`.

---

Creato con ❤️ per la community Arch italiana. 