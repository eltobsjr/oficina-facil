---
data: 2026-10-30
status: em andamento
fase: F1
uc: "—"
us: "—"
rf: "—"
---

# 000 — Fundação técnica

## Objetivo

Supabase de desenvolvimento, backend base, banco com RLS, app ligado ao backend, seed e CI.

## Referências

| Item | Valor |
|---|---|
| Fase | F1 — Fundação técnica |
| Caso de uso | — |
| Histórias | — |
| Requisitos | — |
| Ator | Time de desenvolvimento |
| Regras de negócio | — |
| Tabelas | todas (RLS) |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Projetos Supabase de desenvolvimento e de teste criados; chaves e segredos fora do git (`backend/.env`, `mobile/env.json`); `.env.example` e `mobile/env.example.json` sem valores reais | 🔄 Em progresso — projeto de **desenvolvimento** criado e configurado; falta o projeto de **teste** |
| CA02 | Backend sobe com `npm run dev`; `GET /health` responde 200 e `/docs` mostra o Swagger | ✅ Concluído — `smoke.sh` 12/12 contra a API real |
| CA03 | Variáveis de ambiente validadas com Zod: o backend recusa subir com configuração incompleta | ✅ Concluído — 6 testes de configuração |
| CA04 | Migration inicial aplicada (modelo em [[Modelo de dados]]) com RLS, gatilhos de só-inserção, índice único parcial de OS ativa e FK para `auth.users` dentro das migrations do Prisma (geradas por `prisma migrate diff` e aplicadas por `migrate deploy`, sem precisar de banco-sombra) | ✅ Concluído — migration aplicada no projeto de desenvolvimento e conferida no banco (17 tabelas, RLS, 6 gatilhos, 22 CHECKs, índice parcial, FK, Realtime) |
| CA05 | Teste com a chave publicável comprova que o app não lê nem escreve em nenhuma tabela, exceto as próprias linhas de `avisos` | 🔄 Em progresso — teste escrito e passou 24/24 uma vez contra o projeto de desenvolvimento (exceção pontual); falta rodá-lo no projeto de **teste** |
| CA06 | JWT validado por JWKS (só os algoritmos do projeto; confere `iss`, `aud` e `exp`); rota sem token recebe 401 e perfil sem permissão recebe 403 | ✅ Concluído — 8 testes de JWT com chaves locais; falta testar com um token real de usuário logado (feature 001) |
| CA07 | Erros da API padronizados num único formato JSON, sem vazar detalhe interno; logs Pino com redação de `authorization`, `senha` e `password` | ✅ Concluído — erros no formato único e redação de segredos testados; nenhum segredo no log da API real |
| CA08 | CORS aceita só as origens do web do projeto; `helmet` e rate limit ativos | ✅ Concluído — CORS, helmet e rate limit testados |
| CA09 | Teste de arquitetura impede um módulo de importar o interior de outro | ✅ Concluído |
| CA10 | Seed cria o gerente inicial com e-mail e senha vindos de variável de ambiente e só dados fictícios no catálogo de dev | 🔄 Em progresso — catálogo fictício semeado (idempotente); o gerente inicial depende da `SUPABASE_SERVICE_ROLE_KEY` |
| CA11 | App lê a configuração por `--dart-define`, chama `GET /health` com `dio` e abre em pt-BR (`flutter_localizations`); manifesto Android principal com permissão INTERNET | ✅ Concluído — configuração, `/health` com `dio`, pt-BR e INTERNET; `flutter analyze`, 20 testes, `build web` e `build apk` passam |
| CA12 | Conversão do estado da OS entre API (`UPPER_SNAKE`) e Dart (`camelCase`) num único lugar, com teste; relógio injetável nos dois lados | ✅ Concluído — `fromApi`/`toApi` com 4 testes e `Relogio` injetável |
| CA13 | Dockerfile do backend gera imagem que sobe e responde em `/health` | ✅ Concluído — imagem de 712 MB roda como usuário `node` e responde em `/health` (com rede que tem IPv6) |
| CA14 | Verificações verdes no backend e no app, e CI rodando (analyze, test, lint, typecheck, build) | ✅ Concluído — CI rodou no GitHub (execução 41129044900): jobs backend e mobile passaram |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| GET | `/health` | Público | Estado do serviço |
| GET | `/docs` | Público (dev) | Swagger a partir do OpenAPI |

Contrato completo em [[Endpoints]].

## Telas

Sem tela própria.

## Dependências

Nenhuma.

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

Stack e arquitetura em [[Arquitetura]]. Decisões 001, 002, 006 e 012 já aceitas. Nada de BullMQ/Redis. O login por perfil no app (`redirect`) é da feature 001.
