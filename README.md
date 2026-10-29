# Timecly

Piattaforma self-service per piccole attività: un unico posto per telefono, WhatsApp, social, email e prenotazioni, con un assistente AI che risponde ai clienti quando l'attività non può.

Dominio: [timecly.it](https://timecly.it)

## Stato

Progetto in fase iniziale: preparazione del server di sviluppo e della demo.

## Struttura (prevista)

```
timecly/
├── apps/
│   ├── panel/        # Pannello Timecly: registrazione, configurazione guidata, gestione clienti
│   └── booking/      # Pagine di prenotazione pubbliche dei clienti
├── services/
│   ├── flows/        # Motore dei flussi automatici (chiamata persa → WhatsApp, promemoria…)
│   └── telephony/    # Configurazione centralino (FreeSWITCH) e integrazione SIP
├── sector-packs/     # Pacchetti di settore (bellezza, sanità, officine, ristorazione…)
├── infra/            # docker-compose, reverse proxy, script di installazione e backup
└── docs/             # Documentazione tecnica e decisioni
```

## Segreti

Le chiavi API stanno solo nel file `.env` sul server, mai nel repository. Il file `.env.example` elenca le variabili necessarie, senza valori.
