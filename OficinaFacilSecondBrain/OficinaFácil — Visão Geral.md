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

Estado hoje: só o app existe (tela inicial + `StatusOrdemServico`). Backend e Supabase ainda não foram criados.

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
├── backend/     API Node/TypeScript (a criar na F1)
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

Entrega 1 concluída em 2026-10-29. Em 2026-10-30: casos de uso, histórias, requisitos, modelo de dados, arquitetura, 12 decisões, features e checklist, **tudo dentro deste vault**; stack definida (Flutter + Node/TypeScript + Supabase). Próximo passo: resolver a [[004 - Conferência com o enunciado oficial]] e começar a [[000 - Fundação técnica]]. Prioridades em `prioridade/atual.md`.
