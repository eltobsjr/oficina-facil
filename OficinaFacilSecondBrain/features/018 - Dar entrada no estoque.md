---
data: 2026-10-30
status: planejada
fase: F4
uc: "UC18"
us: "US19"
rf: "RF18"
---

# 018 — Dar entrada no estoque

## Objetivo

Entregar **UC18 — Dar entrada no estoque** para o ator **Almoxarife**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC18.

## Referências

| Item | Valor |
|---|---|
| Fase | F4 — Catálogos e estoque |
| Caso de uso | UC18 |
| Histórias | US19 |
| Requisitos | RF18 |
| Ator | Almoxarife |
| Regras de negócio | RN07 |
| Tabelas | pecas, movimentacoes_estoque |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Registrar quantidade, custo unitário e nota de origem soma ao saldo ⚠️ | 🔲 Pendente |
| CA02 | A entrada fica registrada com data e responsável ⚠️ | 🔲 Pendente |
| CA03 | Quantidade menor ou igual a zero é recusada ⚠️ | 🔲 Pendente |
| CA04 | Peça não cadastrada leva o almoxarife ao cadastro (UC04) ⚠️ | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| POST | `/pecas/:id/entradas` | Almoxarife | Entrada: quantidade, custo e nota |
| GET | `/pecas/:id/movimentacoes` | Almoxarife | Razão do estoque |

Contrato completo em [[Endpoints]].

## Telas

- **T12 Entrada no estoque** — `/pecas/:id/entrada` (Almoxarife)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[004 - Gerir peças]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

UC18 foi deduzido dos papéis; conferir com o documento oficial.
