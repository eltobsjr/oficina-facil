---
data: 2026-10-30
status: planejada
fase: F7
uc: "UC15"
us: "US16"
rf: "RF15"
---

# 015 — Entregar e registrar pagamento

## Objetivo

Entregar **UC15 — Entregar e registrar pagamento** para o ator **Atendente**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC15.

## Referências

| Item | Valor |
|---|---|
| Fase | F7 — Concluir, entregar e cancelar |
| Caso de uso | UC15 |
| Histórias | US16 |
| Requisitos | RF15 |
| Ator | Atendente |
| Regras de negócio | RN05, RN08 |
| Tabelas | pagamentos, ordens_servico, historico_transicoes |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Entregar com pagamentos cuja soma é igual ao total leva a OS de `CONCLUIDA` para `ENTREGUE`, tudo na mesma transação | 🔲 Pendente |
| CA02 | Registra forma, valor, data/hora e quem entregou | 🔲 Pendente |
| CA03 | Soma diferente do total (a menos ou a mais) é recusada e a OS continua em `CONCLUIDA` | 🔲 Pendente |
| CA04 | OS fora de `CONCLUIDA` não pode ser entregue | 🔲 Pendente |
| CA05 | `ENTREGUE` é estado final | 🔲 Pendente |
| CA06 | Vários pagamentos (formas diferentes) na mesma entrega | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| POST | `/os/:id/entregar` | Atendente | Corpo com `pagamentos[]` (forma, valor); exige soma igual ao total e leva a `ENTREGUE` numa transação |

Contrato completo em [[Endpoints]].

## Telas

- **T21 Pagamento e entrega** — `/os/:id/entrega` (Atendente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[014 - Concluir OS]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

Decisão 009 revisada: pagamentos só são gravados no ato da entrega, sem estado intermediário de pagamento parcial.
