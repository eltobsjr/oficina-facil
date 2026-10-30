# 2026-10-30 — F1: fundação técnica (feature 000)

## O que foi feito

1. **Banco (Supabase de desenvolvimento).** Schema Prisma com as 17 tabelas do [[Modelo de dados]] e migration inicial (`prisma/migrations/20261030120000_inicial`): SQL gerado por `prisma migrate diff` e completado à mão com a FK para `auth.users`, 22 CHECKs, índice único parcial (uma OS ativa por veículo), 3 tabelas só de inserção (gatilhos de `UPDATE`, `DELETE` e `TRUNCATE`), RLS em todas as tabelas, revogação dos privilégios de `anon` e `authenticated`, política de leitura própria em `avisos` e publicação no Realtime. Aplicada com `migrate deploy` e conferida direto no banco.
2. **Backend** (`backend/`): Express 5, TypeScript, Zod, Pino com redação, Helmet, CORS, rate limit, erros no formato único (422 validação, 409 regra), validação de JWT por JWKS (só ES256/RS256, confere `iss`, `aud`, `exp`), módulo `usuarios` com `GET /me`, OpenAPI/Swagger, `/health`, Dockerfile, `scripts/smoke.sh`, seed (catálogo fictício e gerente), CI em `.github/workflows/ci.yml`.
3. **App** (`mobile/`): `supabase_flutter`, `dio`, configuração por `--dart-define-from-file`, indicador de conexão (`GET /health`), pt-BR, `StatusOrdemServico.fromApi/toApi` e `Relogio` injetável.
4. Padrões reaproveitados do backend do Confia (env, erros, rate limit, `registrarRota`, teste de arquitetura), adaptados e sem fila, gateway nem HS256.

## Verificado (comandos rodados nesta sessão)

| O quê | Resultado |
|---|---|
| Backend: `lint`, `format:check`, `typecheck`, `build` | limpos |
| Backend: `npm test` | 34 passando, 24 de integração ignorados sem projeto de teste |
| Testes de integração do banco | 24/24 passaram uma vez contra o projeto de **desenvolvimento** (rollback, sem dados residuais); exceção pontual à R19, autorizada por "vai usando essa por enquanto" |
| RLS com a chave publicável (sondagem real) | sem login: 401 em toda leitura e escrita |
| `smoke.sh` contra a API real | 12/12 |
| Log da API real | nenhum segredo |
| Docker | imagem sobe como `node` e responde em `/health` na rede do host |
| App: `format`, `analyze`, `test`, `build web`, `build apk` | limpos, 20 testes, builds ok |

## Achados

- **Conexão direta do Supabase é só IPv6.** Funciona na máquina de desenvolvimento, mas o contêiner na rede padrão do Docker marcou o banco como indisponível. Produção e CI precisam da string do **pooler**. Registrado em [[Arquitetura]] e em [[Rodar o projeto]].
- **Java sem certificados nesta máquina:** o Gradle não baixa bibliotecas novas. Contorno por variável de ambiente documentado em [[Rodar o projeto]]; nada permanente foi alterado.
- O projeto assina tokens com ES256 e publica a chave no JWKS: a decisão 002 (sem HS256) se sustenta.
- Um teste que escrevi no início ("desconto maior que o subtotal") não testava nada; foi substituído por um teste real.
- A senha do banco e a chave `anon` foram coladas no chat; o usuário vai rotacionar depois.

## Ainda falta para fechar a F1

- [ ] Projeto Supabase de **teste** (para os testes de integração e RLS rodarem onde a regra manda)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` (gerente inicial e, depois, UC06)
- [ ] String do **pooler** para `DATABASE_URL` em produção e CI
- [ ] Primeira execução do CI (depende do push)
- [ ] Rotacionar a senha do banco e a chave pasted no chat

## Commits

Backend, app e documentação, em commits separados (sem push).
