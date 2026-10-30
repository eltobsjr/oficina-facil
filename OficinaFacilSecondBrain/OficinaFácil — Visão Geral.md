---
data: 2026-10-29
atualizado: 2026-10-30
---

# OficinaFácil — Visão Geral

## O que é

Sistema de gestão de ordens de serviço (OS) para oficina mecânica, do veículo na entrada até a entrega e o pagamento. Projeto da disciplina Análise e Projeto de Sistemas: a cada semana o professor (Anthony) pede uma entrega nova, com diagrama UML e código que o implemente.

## Stack técnica

Decidida em [[001 - Persistência no Supabase Postgres via backend]], [[002 - Autenticação pelo Supabase Auth]] e [[006 - Backend em Node e TypeScript]]. Detalhes em [[Arquitetura]].

| Camada | Tecnologia |
|---|---|
| App | Flutter 3.44 / Dart 3.12 (web e Android), Riverpod, go_router, `dio`, `supabase_flutter`, Material 3 `#1F4E79` |
| Backend | Node 22, Express 5, TypeScript, Zod, Prisma, Pino, Helmet, rate limit, Vitest, OpenAPI |
| Banco, Auth, Realtime | Supabase (Postgres com RLS; o app não lê nem escreve fora da API, exceto os próprios `avisos`). Storage disponível, sem uso no MVP |
| Empacotamento | Docker (só o backend); o banco nunca roda em container |
| Diagramas | Mermaid |

Estado hoje: backend base, banco com RLS e app ligado ao backend existem (F1); as funcionalidades de negócio ainda não.

## Atores

- **Atendente:** clientes, veículos, abre a OS, orçamento, aprovação do cliente, entrega.
- **Mecânico:** diagnóstico, execução, peças usadas, conclusão; vê a fila da sua etapa.
- **Almoxarife:** peças e entrada no estoque.
- **Gerente:** usuários, serviços, autoriza descontos acima de 10%, cancela OS, faturamento.

## Ciclo de vida da OS

`ABERTA` → `DIAGNOSTICADA` → `AGUARDANDO_APROVACAO` → `APROVADA` (ou `CANCELADA`) → `EM_EXECUCAO` → `CONCLUIDA` → `ENTREGUE`

Cancelar vale em qualquer estado antes da entrega. Implementado em `StatusOrdemServico`. Detalhe em [[Casos de uso]].

## Mapa do vault

- [[00 - Índice]] · [[Convenções]] · [[CHECKLIST]] · [[Roadmap]]
- Especificação: [[Requisitos]], [[Casos de uso]], [[Histórias de usuário]], [[Rastreabilidade]]
- Arquitetura: [[Arquitetura]], [[Modelo de dados]], [[Diagramas]], [[Endpoints]]
- Decisões: [[00 - Índice de decisões]]
- Plano: [[Plano de construção]] · [[Rodar o projeto]]
- Telas: [[Mapa de telas]] · Features: `features/` · Auditorias: `auditorias/` · PDFs: `entregas/` · Logo: [[00 - Identidade visual]]

## Como rodar (app, hoje)

```bash
cd mobile
flutter pub get
flutter run -d chrome     # web
flutter run -d android    # Android
flutter analyze && flutter test
```

Comandos do backend entram na feature [[000 - Fundação técnica]].

## Estrutura do repositório (monorepo, como o Confia)

```
oficina_facil/
├── mobile/      app Flutter (web e Android): lib/, test/, android/, web/, assets/, pubspec.yaml
├── backend/     API Node/TypeScript (base pronta)
├── CLAUDE.md    regras do projeto
├── README.md    apresentação do projeto (a especificação fica aqui no vault)
└── OficinaFacilSecondBrain/   documentação (este vault), versionado junto com o código
```

Dentro de `mobile/`: `lib/core/` (tema e roteamento) e `lib/features/<feature>/{domain,data,presentation}` (Clean Architecture por feature). Decisão: [[012 - Estrutura do repositório]].

## Links

- Repositório: `github.com/eltobsjr/oficina-facil` (público)
- Quadro: https://github.com/users/eltobsjr/projects/4
- Repositório do Roberto (versão Java): `APS_projeto`, separado deste

## Estado atual

Em 2026-10-30: análise completa, documentação toda neste vault, monorepo (`mobile/`, `backend/`, vault no mesmo repositório) e a **F1 (fundação técnica) construída e verificada**: banco com RLS no Supabase de desenvolvimento, backend com `GET /me`, JWT por JWKS, Swagger, Docker e CI, e o app ligado ao Supabase e ao backend. Nenhum dos 19 casos de uso de negócio está implementado ainda.

Próximo: **Semana 1 do [[Roadmap]]** (fechar a F1 e backend de usuários). Plano por tela e componente em [[Plano de construção]]. Para retomar, leia [[2026-10-30 - ZZ Resumo do dia e como retomar]] e `prioridade/atual.md`.
