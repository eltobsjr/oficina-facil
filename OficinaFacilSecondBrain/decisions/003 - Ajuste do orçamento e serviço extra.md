---
data: 2026-10-30
status: aberta
---

# 003 — Ajuste do orçamento e serviço extra

## Contexto

UC11/FA2 (cliente pede ajuste) e UC12/FA1 (serviço extra) pedem retorno de estado que o diagrama de estados não prevê.

## Alternativas consideradas

- (a) Fora do escopo: o cliente só aprova ou recusa
- (b) `AGUARDANDO_APROVACAO` aceita orçamento revisado
- (c) Orçamento complementar durante `EM_EXECUCAO`, com aprovação do cliente

## Decisão

Em aberto. **Recomendação: (a) no MVP.** Os dois fluxos ficam marcados "fora do MVP" nas features 011 e 012.

## Consequências

- Enquanto não decidir, `StatusOrdemServico` não ganha transições de retorno.
