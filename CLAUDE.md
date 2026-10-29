# Timecly: contesto per Claude

Leggi questo file all'inizio di ogni sessione. Aggiornalo quando cambiano decisioni, stato o infrastruttura.

## Il prodotto

SaaS **self-service** (product-led, deve vendersi da solo) per piccole attività, Italia come primo mercato. Riunisce:
- casella unica: WhatsApp, Instagram/Facebook, email, chat del sito (Chatwoot usato **via API**, niente fork pesante);
- centralino cloud multi-tenant (FreeSWITCH) e numeri VoIP;
- flussi automatici: chiamata persa → WhatsApp con link di prenotazione, promemoria, richiesta recensioni Google, recupero clienti inattivi;
- agente AI in chat e al telefono;
- prenotazioni.

Problema che risolve: le app tipo Treatwell gestiscono l'agenda ma non telefono, WhatsApp e assistenza. Le attività perdono clienti perché non rispondono.

## Decisioni di architettura

- **Multi-settore**: nucleo generico (Attività → Sedi → Risorse → Servizi → Appuntamenti, Contatti, Canali, Flussi) + **pacchetti di settore** che sono solo configurazione (terminologia, servizi e risorse precaricati, flussi, FAQ, personalità dell'agente, campi extra). Mai concetti specifici di un settore nel codice del nucleo.
- **Self-service**: registrazione con prova gratuita, configurazione guidata in ~10 minuti, numero assegnato automaticamente (con verifica d'identità richiesta in Italia) o inoltro del numero esistente, WhatsApp via Embedded Signup (serve diventare Meta Tech Provider), pagamenti Stripe, assistenza AI nel pannello. I rivenditori sono un canale secondario.
- **Flussi**: motore proprio o Activepieces. **Non n8n** (la licenza ne limita la rivendita come servizio).
- Pacchetto sanità: attenzione GDPR (categorie particolari di dati), niente dettagli clinici nei messaggi.
- Tutto in Docker, per poter spostare facilmente l'installazione dal NUC a un data center.

## Infrastruttura

- **Sviluppo/demo**: NUC dedicato nell'ufficio (IP pubblico statico dell'ufficio), hostname `timecly`, **IP LAN `10.10.25.114`** (gateway `10.10.25.254`).
  - Hardware: x86_64, **2 core**, 7.6 GB RAM, SSD 500 GB (root LVM `ubuntu-vg-1/ubuntu-lv` estesa a ~455 GB). Swap file 4 GB.
  - La eMMC interna (`mmcblk0`, VG `ubuntu-vg`) contiene una vecchia installazione: **non toccarla** senza chiedere.
  - Ubuntu 24.04 LTS, fuso orario Europe/Rome, aggiornamenti automatici di sicurezza attivi.
  - Utenti: `timecly` (usato da Claude, solo chiave SSH, sudo senza password, gruppo docker); `maint` (dell'utente, password ammessa solo dalla LAN).
  - SSH: root disabilitato, password disabilitate tranne da `10.10.25.0/24` (`/etc/ssh/sshd_config.d/10-timecly.conf`). fail2ban attivo su sshd.
  - Firewall ufw: aperte solo 22, 80, 443. Le porte SIP/RTP vanno aperte quando si installa il centralino.
  - Docker 29 + Compose v5 ufficiali, log ruotati (10 MB × 3). **Attenzione: Docker scavalca ufw** per le porte pubblicate: pubblicare solo il reverse proxy, gli altri servizi su `127.0.0.1` o rete interna.
  - Cartella dei servizi: `/opt/timecly` (proprietario `timecly`).
- Connessione da questo PC: `ssh -i ~/.ssh/timecly_ed25519 timecly@10.10.25.114` (chiave senza passphrase, da sostituire in produzione). Accesso remoto previsto via Tailscale, SSH non esposto su internet.
- **Produzione**: in un data center (non nell'ufficio) quando arrivano i primi clienti paganti.
- Segreti: solo in `.env` sul server + copia nel password manager. Mai nel repository né in chat.

## Nome e marchio

Nome: **Timecly**, dominio **timecly.it**. Verifica del marchio da fare: è simile a "Timely" (gettimely.com, software di prenotazione per saloni). Nome di riserva: **Timecli**.

## Stato dei lavori

- [x] Nome e dominio
- [x] Chiave SSH per il server
- [x] Repository Git locale
- [ ] Repository GitHub privato collegato
- [x] NUC installato e raggiungibile via SSH
- [x] Server messo in sicurezza (firewall, fail2ban, SSH) e Docker installato
- [ ] DNS di timecly.it verso l'IP pubblico + inoltro porte 80/443 sul router + SSL
- [ ] Chatwoot + FreeSWITCH installati
- [ ] Pannello con configurazione guidata
- [ ] Flusso chiamata persa → WhatsApp funzionante (demo)
- [ ] Agente vocale AI

## Lingua

L'utente scrive in italiano: rispondi in italiano. Codice, nomi di variabili e commit in inglese.
