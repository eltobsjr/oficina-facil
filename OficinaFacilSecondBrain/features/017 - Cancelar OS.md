---
data: 2026-10-30
status: planejada
fase: F7
uc: "UC17"
us: "US18"
rf: "RF17"
---

# 017 — Cancelar OS

## Objetivo

Entregar **UC17 — Cancelar OS** para o ator **Atendente, Gerente**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC17.

## Referências

| Item | Valor |
|---|---|
| Fase | F7 — Concluir, entregar e cancelar |
| Caso de uso | UC17 |
| Histórias | US18 |
| Requisitos | RF17 |
| Ator | Atendente, Gerente |
| Regras de negócio | RN05, RN06 |
| Tabelas | ordens_servico, historico_transicoes, pecas_usadas, movimentacoes_estoque |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Em qualquer estado antes de `ENTREGUE`, cancelar leva a OS para `CANCELADA` | 🔲 Pendente |
| CA02 | Motivo é obrigatório e a ação pede confirmação | 🔲 Pendente |
| CA03 | OS `ENTREGUE` ou já `CANCELADA` não pode ser cancelada | 🔲 Pendente |
| CA04 | Só atendente e gerente cancelam (RN06) | 🔲 Pendente |
| CA05 | Peças lançadas voltam ao estoque, com opção de marcar "não devolver" e registrar o motivo (D8) | 🔲 Pendente |
| CA06 | O estorno das peças acontece na mesma transação do cancelamento | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| POST | `/os/:id/cancelar` | Atendente, Gerente | Cancela com motivo e estorna as peças na mesma transação (decisão 008) |

Contrato completo em [[Endpoints]].

## Telas

- **T22 Cancelar OS (diálogo com motivo)** — `diálogo sobre T15` (Atendente, Gerente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[013 - Registrar peças usadas]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

Extensão de UC16. Já existe a regra de transição em `StatusOrdemServico`.
