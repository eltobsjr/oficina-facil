---
data: 2026-10-30
status: proposta
---

# 009 — Regras de pagamento

## Contexto

UC15 aceita pagamento em mais de uma forma, mas não definia parcial, excedente nem troco. Com pagamentos de só-inserção e sem estorno, lançar antes de entregar deixaria estados parciais impossíveis de desfazer.

## Alternativas consideradas

- Aceitar pagamento parcial e entregar mesmo assim
- Soma dos lançamentos igual ao total, sem excedente (proposta)

## Decisão

Os pagamentos **só são gravados no ato da entrega**: `POST /os/:id/entregar` recebe `pagamentos[]` (forma e valor), exige soma igual ao total e, numa única transação, grava os pagamentos e leva a OS a `ENTREGUE`. Soma menor ou maior é recusada; troco é tratado fora do sistema.

## Consequências

- Sem fiado nem pagamento parcial no MVP: não existe estado intermediário de pagamento.
- Não há endpoint separado para lançar pagamento.
- Se uma OS for cancelada em `CONCLUIDA`, não há pagamento a tratar (nada foi gravado antes da entrega).
