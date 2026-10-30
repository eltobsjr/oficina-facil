---
data: 2026-10-30
status: aceita
---

# 012 — Estrutura do repositório

## Contexto

Havia dúvida entre deixar o app Flutter na raiz com `backend/` ao lado, ou separar em pastas irmãs. O usuário pediu monorepo organizado como o do Confia, com backend e front separados.

## Alternativas consideradas

- Flutter na raiz e `backend/` ao lado (primeira escolha, revertida)
- Monorepo com `mobile/` e `backend/`, como o Confia (escolhida)

## Decisão

Monorepo com `mobile/` (app Flutter, web e Android), `backend/` (API Node/TypeScript) e `OficinaFacilSecondBrain/` (o vault de documentação), **tudo no mesmo repositório e versionado**. Na raiz ficam só `CLAUDE.md`, `README.md` e `.gitignore`. **Toda a documentação vive no SecondBrain**: não existe pasta `docs/`, e o `README.md` é só um resumo que aponta para o vault. O kit do logo está em `identidade-visual/` do vault.

## Consequências

- Comandos do app rodam dentro de `mobile/` (`cd mobile && flutter ...`).
- Segredos: `backend/.env` e `mobile/env.json`, ambos ignorados pelo git.
- Migrations em `backend/prisma/`; RLS, gatilhos e índices extras vão **dentro** das migrations (`prisma migrate dev --create-only`).
- Se um painel admin web for preciso um dia, entra como `admin/` (padrão do Confia).
- Em 2026-10-30 o usuário decidiu que o vault fica no mesmo repositório (antes era ignorado pelo git). Como o repositório é público, a documentação também é pública: ver a regra R30 do `CLAUDE.md`.
