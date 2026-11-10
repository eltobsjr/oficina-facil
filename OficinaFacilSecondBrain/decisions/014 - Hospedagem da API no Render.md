---
data: 2026-11-10
status: aceita
---

# 014 — Hospedagem da API no Render

## Contexto

O CHECKLIST pedia escolher a hospedagem do backend entre Railway e Render. O usuário queria o app usável no celular antes da F4 e publicou a API no Render em 2026-11-10. O repositório é monorepo (decisão [[012 - Estrutura do repositório]]) e o backend já tem `backend/Dockerfile`.

## Alternativas consideradas

- Railway (citada na [[Arquitetura]]).
- Render com Web Service em Docker (escolhida).

## Decisão

API publicada como **Web Service do Render**, em https://oficina-facil.onrender.com, com:

- Projeto `oficinafacil`, ambiente Production, ramo `main`, linguagem Docker.
- **Root Directory `backend/`**: é o que faz o Render tratar a subpasta do monorepo como raiz; o `Dockerfile` é usado sem mudança. Mudanças fora de `backend/` não disparam deploy.
- Plano gratuito (0,1 CPU, 512 MB) na região Ohio (EUA Leste); o banco está em `sa-east-1`.
- Verificação de saúde em `/health`.
- Variáveis de ambiente (valores só no painel do Render, nunca no vault): `NODE_ENV=production`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `DATABASE_URL` pela string do **pooler IPv4**. Opcional: `CORS_ORIGINS` (só importa para o web). Não se define `PORT` (o Render injeta). Ficam **fora** do Render: `DIRECT_URL` (só migrations), as `TEST_*`, `SHADOW_DATABASE_URL` e as de seed.
- Migrations não rodam no deploy: o banco já está migrado.

## Consequências

- O plano gratuito **dorme** quando fica parado: a primeira chamada depois de uma pausa pode levar cerca de um minuto. Antes de uma demonstração, abrir `/health` para acordar a API.
- Latência a mais por causa da região (Ohio para São Paulo); aceitável para a demonstração.
- **A API publicada usa o único projeto Supabase (desenvolvimento)**: não existe ainda o projeto de produção separado que a [[Arquitetura]] prevê. Enquanto não houver dado real, vale a exceção da R19; antes de dado real, criar projeto de teste ou de produção.
- O APK precisa ser compilado com `API_URL` apontando para essa URL ([[Rodar o projeto]]).
- Trocar a senha do banco ou a chave de serviço exige atualizar o painel do Render; o APK não precisa ser recompilado.
