---
data: 2026-10-30
status: planejada
fase: F5
uc: "UC10"
us: "US10"
rf: "RF10"
---

# 010 — Autorizar desconto

## Objetivo

Entregar **UC10 — Autorizar desconto** para o ator **Atendente (solicita), Gerente (decide)**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC10.

## Referências

| Item | Valor |
|---|---|
| Fase | F5 — Abrir, diagnosticar e orçar |
| Caso de uso | UC10 |
| Histórias | US10 |
| Requisitos | RF10 |
| Ator | Atendente (solicita), Gerente (decide) |
| Regras de negócio | RN02 |
| Tabelas | autorizacoes_desconto, avisos |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | O atendente solicita a autorização de um desconto acima de 10%; a solicitação nasce `PENDENTE` e o gerente recebe aviso | 🔲 Pendente |
| CA02 | O gerente aprova ou recusa pela própria sessão; a decisão registra gerente, valor autorizado e data | 🔲 Pendente |
| CA03 | O gerente pode autorizar um valor menor que o pedido (valor autorizado ≤ solicitado) ⚠️ | 🔲 Pendente |
| CA04 | Perfil diferente de Gerente não decide (403) | 🔲 Pendente |
| CA05 | A autorização perde a validade se o subtotal ou o desconto do orçamento mudar depois | 🔲 Pendente |
| CA06 | Recusa devolve o controle ao atendente, que ajusta o desconto ou segue sem ele | 🔲 Pendente |
| CA07 | Aprovada e válida, a autorização permite confirmar o orçamento (feature 009) | 🔲 Pendente |
| CA08 | A decisão gera o aviso `DESCONTO_DECIDIDO` para o atendente e o pedido gera `DESCONTO_PENDENTE` para o gerente | 🔲 Pendente |
| CA09 | O usuário lista os próprios avisos, marca como lido e vê o aviso novo chegar sem recarregar (Realtime); só enxerga os dele | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| POST | `/os/:id/orcamento/solicitacao-desconto` | Atendente | Pede autorização de desconto acima de 10% (nasce `PENDENTE`, avisa o gerente) |
| GET | `/solicitacoes-desconto` | Gerente | Lista pendentes e decididas |
| POST | `/solicitacoes-desconto/:id/decisao` | Gerente | Aprova (valor igual ou menor) ou recusa, com o próprio JWT; avisa o atendente |
| GET | `/avisos` | Atendente, Almoxarife, Gerente | Avisos do próprio usuário (T24); a primeira feature a produzir avisos é esta |
| POST | `/avisos/:id/lido` | Atendente, Almoxarife, Gerente | Marca aviso como lido |

Contrato completo em [[Endpoints]].

## Telas

- **T17 Orçamento (inclui pedir autorização de desconto)** — `/os/:id/orcamento` (Atendente)
- **T18 Solicitações de desconto (pendentes e decididas)** — `/descontos` (Gerente)
- **T24 Notificações no app (desconto pendente ou decidido, saldo insuficiente, OS concluída)** — `/notificacoes` (Atendente, Almoxarife, Gerente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[009 - Montar orçamento]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

Extensão de UC09 (`«extend»`). Decisão 007 revisada: autorização assíncrona, sem senha de gerente passando pelo backend.
