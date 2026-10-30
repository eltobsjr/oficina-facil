---
data: 2026-10-30
status: aceita
---

# 001 — Persistência no Supabase Postgres via backend

## Contexto

Quatro perfis usam dispositivos diferentes (web e Android) e precisam enxergar os mesmos dados.

## Alternativas consideradas

- SQLite local (cada aparelho teria o seu banco, nada compartilhado)
- Firebase (NoSQL encaixa mal em estoque, totais e relatórios)
- Postgres em container (perde Auth e Realtime do Supabase)

## Decisão

Postgres do Supabase, acessado **somente pelo backend** (Prisma, conexão direta). O app não escreve no banco.

## Consequências

- Precisa de internet.
- RLS ligada em todas as tabelas e sem política de escrita para o app.
- Migrations versionadas pelo Prisma.
- Banco nunca roda em container.
