---
data: 2026-10-30
status: proposta
---

# 008 — Estoque no cancelamento da OS

## Contexto

UC17/FA1 devolve ao estoque as peças lançadas, mas uma peça já aplicada no veículo não volta fisicamente.

## Alternativas consideradas

- Devolver tudo
- Não devolver nada
- Devolver por padrão, com opção de "não devolver" e motivo (proposta)

## Decisão

Ao cancelar, as peças lançadas voltam ao estoque. O usuário pode marcar uma peça como "não devolver" e informar o motivo; fica registrado.

## Consequências

- O estorno gera movimentação `ESTORNO` no razão do estoque.
