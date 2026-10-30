---
data: 2026-10-30
status: proposta
---

# 010 — Avisos dentro do app

## Contexto

UC13 ("avisa o almoxarife") e UC14 ("avisa o atendente") pedem notificação sem definir o canal.

## Alternativas consideradas

- Push (FCM)
- E-mail
- Notificação dentro do app via Supabase Realtime (proposta)

## Decisão

Os avisos são **gravados** na tabela `avisos` pelo backend (OS concluída, saldo insuficiente, desconto pendente). O Supabase Realtime só avisa o app de que chegou um aviso novo, e o app busca `GET /avisos`. Sem push nem e-mail no MVP.

## Consequências

- Quem estava com o app fechado vê os avisos ao abrir, porque ficam gravados (`lido_em` marca a leitura).
- Tela T24 (Notificações) e endpoints `GET /avisos` e `POST /avisos/:id/lido`.
- `avisos` é a única tabela que o app lê direto, com RLS por `destinatario_id`.
