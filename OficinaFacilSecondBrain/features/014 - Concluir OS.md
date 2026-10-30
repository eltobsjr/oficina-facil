---
data: 2026-10-30
status: planejada
fase: F7
uc: "UC14"
us: "US15"
rf: "RF14, RF20"
---

# 014 — Concluir OS

## Objetivo

Entregar **UC14 — Concluir OS** para o ator **Mecânico**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC14.

## Referências

| Item | Valor |
|---|---|
| Fase | F7 — Concluir, entregar e cancelar |
| Caso de uso | UC14 |
| Histórias | US15 |
| Requisitos | RF14, RF20 |
| Ator | Mecânico |
| Regras de negócio | RN01 |
| Tabelas | ordens_servico, historico_transicoes, avisos |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Concluir leva a OS de `EM_EXECUCAO` para `CONCLUIDA` com data/hora | 🔲 Pendente |
| CA02 | O atendente recebe aviso no app de que o veículo está pronto (D10) | 🔲 Pendente |
| CA03 | OS fora de `EM_EXECUCAO` não pode ser concluída | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| POST | `/os/:id/concluir` | Mecânico | Leva a `CONCLUIDA` e cria aviso para o atendente |

Contrato completo em [[Endpoints]].

## Telas

- **T15 Detalhe da OS (dados, orçamento, peças, histórico, ações por estado)** — `/os/:id` (Atendente, Gerente, Mecânico (sem documento e telefone do cliente))
- **T24 Notificações no app (desconto pendente ou decidido, saldo insuficiente, OS concluída)** — `/notificacoes` (Atendente, Almoxarife, Gerente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[012 - Executar serviço]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.
