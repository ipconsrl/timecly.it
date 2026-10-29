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

- **Sviluppo/demo**: NUC dedicato nell'ufficio, IP pubblico statico, Ubuntu Server 24.04 LTS, utente `timecly`, hostname `timecly-01`. IP locale: _da ricevere_.
- Accesso: chiave SSH per postazione (questo PC: `~/.ssh/timecly_ed25519`, senza passphrase, da sostituire in produzione). Accesso remoto previsto via Tailscale, SSH non esposto su internet.
- **Produzione**: in un data center (non nell'ufficio) quando arrivano i primi clienti paganti.
- Segreti: solo in `.env` sul server + copia nel password manager. Mai nel repository né in chat.

## Nome e marchio

Nome: **Timecly**, dominio **timecly.it**. Verifica del marchio da fare: è simile a "Timely" (gettimely.com, software di prenotazione per saloni). Nome di riserva: **Timecli**.

## Stato dei lavori

- [x] Nome e dominio
- [x] Chiave SSH per il server
- [x] Repository Git locale
- [ ] Repository GitHub privato collegato
- [ ] NUC installato e raggiungibile via SSH
- [ ] Server messo in sicurezza (firewall, fail2ban, Docker, SSL)
- [ ] Chatwoot + FreeSWITCH installati
- [ ] Pannello con configurazione guidata
- [ ] Flusso chiamata persa → WhatsApp funzionante (demo)
- [ ] Agente vocale AI

## Lingua

L'utente scrive in italiano: rispondi in italiano. Codice, nomi di variabili e commit in inglese.
