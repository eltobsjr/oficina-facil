---
data: 2026-10-30
---

# CHECKLIST — OficinaFácil

Lista mestra de tudo que o projeto precisa ter. Marque com `[x]` conforme avança.
Stack: Flutter + backend Node/TypeScript + Supabase ([[Arquitetura]]).
**Semana atual: S1 (02/11 a 08/11)**, ver [[Roadmap]] e [[atual|Prioridades atuais]].

**Regras para marcar:**
1. Cada feature de caso de uso tem 9 tarefas fixas (modelo, API, testes da API, contrato, app em dois blocos, testes do app, verificação, documentação). A `000` e a `020` têm tarefas próprias.
2. A linha da feature só é marcada quando as tarefas estão marcadas **e** todos os CAs do arquivo da feature estão ✅.
3. A fase só é marcada quando todas as suas features estão marcadas.
4. O comportamento esperado vive no arquivo da feature (CAs). O que construir vive aqui. Não duplicar texto entre os dois.
5. Ao concluir uma feature: atualizar o devtrack, o quadro do GitHub Projects e, se mudou algo, as notas do vault e os PDFs de `entregas/`.

## Entrega 1 (concluída)

- [x] Tela inicial com logo, nome e etapas da OS
- [x] Repositório no GitHub
- [x] Nome e ícone (web e Android)
- [x] Diagramas Mermaid (casos de uso, estados, arquitetura, pastas)
- [x] `StatusOrdemServico` no domínio, com testes
- [x] Documento de casos de uso (UC01 a UC19)
- [x] Histórias de usuário (23, derivadas)
- [x] PDFs dos documentos
- [x] Quadro no GitHub Projects (visão Board a criar pela interface)

## Base de documentação e arquitetura (2026-10-30)

- [x] Stack definida: Flutter + Node/TypeScript + Supabase (D1, D2, D6, D12)
- [x] Documentação toda dentro do vault: [[Requisitos]], [[Casos de uso]], [[Histórias de usuário]], [[Arquitetura]], [[Modelo de dados]], [[Diagramas]], [[Roadmap]], 12 decisões em `decisions/`
- [x] [[Endpoints]] e [[Rastreabilidade]] gerados das features
- [x] README e CLAUDE.md alinhados à nova stack, com regras invioláveis
- [x] Revisão por agente Opus de tudo, com correções aplicadas (ver [[2026-10-30 - Revisão Opus]])

## Pendências transversais

- [ ] Teste do app em dispositivo Android (celular não detectado pelo adb em 2026-10-30)
- [x] Decisão 004 resolvida: o professor não entregou documento; seguem UC18, UC19 e as histórias deduzidas
- [ ] Decisões 003, 005 e 011 abertas; 007 a 010 propostas, confirmar (ver [[00 - Índice de decisões]])
- [ ] Criar a visão Board no GitHub Projects
- [ ] Decidir se `identidade-visual/opcoes-v2/` fica no vault ou sai
- [ ] Escolher hospedagem do backend (Railway ou Render) e confirmar planos gratuitos
- [x] Vault versionado no mesmo repositório do código (decisão do usuário, 2026-10-30)
- [x] Mudanças de regras do CLAUDE.md aplicadas (ver [[2026-10-30 - Revisão Opus]])
- [ ] Decidir escopo: anonimização LGPD (RNF09), Plano de testes e Wireframes

## F1 — Fundação técnica

_Supabase de desenvolvimento, backend base, banco com RLS, app ligado ao backend, seed e CI_

- [ ] **Fase F1 concluída**

### [[000 - Fundação técnica]]

- [ ] **000 — Fundação técnica**
  - [ ] Projetos Supabase de desenvolvimento e de teste criados; chaves guardadas fora do git; `.env.example` e `mobile/env.example.json` sem valores (desenvolvimento feito; falta o de teste)
  - [x] Backend base: Express 5, TypeScript, env com Zod, Pino com redação, Helmet, rate limit, CORS, erros padronizados, `/health`
  - [x] JWT validado por JWKS (algoritmos do projeto, `iss`, `aud`, `exp`) e middleware de perfil
  - [x] Prisma: migration inicial do modelo de dados com RLS, gatilhos de só-inserção, índice único parcial e FK para `auth.users` (sem banco-sombra: `migrate diff` + `migrate deploy`)
  - [ ] Teste com a chave publicável: o app não lê nem escreve nas tabelas, exceto `avisos` do próprio usuário (escrito; falta rodar no projeto de teste)
  - [x] OpenAPI + Swagger e script `openapi:gerar`
  - [x] Vitest e teste de arquitetura dos módulos
  - [ ] Seed do gerente inicial e do catálogo fictício de dev; `scripts/smoke.sh` com o primeiro fluxo (catálogo e smoke feitos; falta o gerente: precisa da `SUPABASE_SERVICE_ROLE_KEY`)
  - [x] Dockerfile do backend
  - [x] App: `supabase_flutter`, `dio`, `--dart-define`, `flutter_localizations` pt-BR, permissão INTERNET no manifesto, `fromApi/toApi` do estado com teste, relógio injetável
  - [ ] CI: backend (lint, typecheck, test) e app (analyze, test, build) (arquivo criado; executa no primeiro push)
  - [x] Documentação: nota em `metodos/` com o passo a passo de rodar o backend; devtrack

## F2 — Acesso e usuários

_Login com 4 perfis e gestão de usuários_

- [ ] **Fase F2 concluída**

### [[001 - Autenticar]] (UC01)

- [ ] **001 — Autenticar**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[006 - Gerir usuários]] (UC06)

- [ ] **006 — Gerir usuários**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F3 — Clientes e veículos

_Cadastros que a OS referencia_

- [ ] **Fase F3 concluída**

### [[002 - Gerir clientes]] (UC02)

- [ ] **002 — Gerir clientes**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[003 - Gerir veículos]] (UC03)

- [ ] **003 — Gerir veículos**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F4 — Catálogos e estoque

_Serviços, peças e entrada no estoque_

- [ ] **Fase F4 concluída**

### [[004 - Gerir peças]] (UC04)

- [ ] **004 — Gerir peças**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[005 - Gerir serviços]] (UC05)

- [ ] **005 — Gerir serviços**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[018 - Dar entrada no estoque]] (UC18)

- [ ] **018 — Dar entrada no estoque**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F5 — Abrir, diagnosticar e orçar

_Primeira metade do ciclo da OS_

- [ ] **Fase F5 concluída**

### [[007 - Abrir OS]] (UC07)

- [ ] **007 — Abrir OS**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[008 - Registrar diagnóstico]] (UC08)

- [ ] **008 — Registrar diagnóstico**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[009 - Montar orçamento]] (UC09)

- [ ] **009 — Montar orçamento**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[010 - Autorizar desconto]] (UC10)

- [ ] **010 — Autorizar desconto**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F6 — Aprovação e execução

_Cliente decide, mecânico executa e lança peças_

- [ ] **Fase F6 concluída**

### [[011 - Registrar aprovação do cliente]] (UC11)

- [ ] **011 — Registrar aprovação do cliente**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[012 - Executar serviço]] (UC12)

- [ ] **012 — Executar serviço**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[013 - Registrar peças usadas]] (UC13)

- [ ] **013 — Registrar peças usadas**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F7 — Concluir, entregar e cancelar

_Fim do ciclo: primeiro fluxo ponta a ponta_

- [ ] **Fase F7 concluída**

### [[014 - Concluir OS]] (UC14)

- [ ] **014 — Concluir OS**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[015 - Entregar e registrar pagamento]] (UC15)

- [ ] **015 — Entregar e registrar pagamento**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[017 - Cancelar OS]] (UC17)

- [ ] **017 — Cancelar OS**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F8 — Consulta, histórico e faturamento

_Visão gerencial_

- [ ] **Fase F8 concluída**

### [[016 - Consultar OS]] (UC16)

- [ ] **016 — Consultar OS**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

### [[019 - Ver faturamento]] (UC19)

- [ ] **019 — Ver faturamento**
  - [ ] Modelo: tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]
  - [ ] API: rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend
  - [ ] Testes da API: Vitest: regras e exceções de cada CA, e permissão por perfil
  - [ ] Contrato: OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger
  - [ ] App: domínio e dados: entidades, contrato do repositório e implementação com `dio`
  - [ ] App: telas: telas do Mapa de telas e providers Riverpod
  - [ ] Testes do app: domínio e widget cobrindo os CAs
  - [ ] Verificação: backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk
  - [ ] Documentação: CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`

## F9 — Acabamento e entrega final

_Android, integração, documentos e release_

- [ ] **Fase F9 concluída**

### [[020 - Acabamento e entrega final]]

- [ ] **020 — Acabamento e entrega final**
  - [ ] Testar em dispositivo Android e ajustar o layout para telas pequenas
  - [ ] Conferir o layout web responsivo
  - [ ] Teste de integração do fluxo completo (`scripts/smoke.sh`)
  - [ ] Publicar a imagem Docker e a API de demonstração; publicar o web e gerar o APK
  - [ ] Atualizar diagramas, casos de uso, histórias, ER, API e regerar os PDFs de `entregas/`
  - [ ] Changelog, versão e tag
