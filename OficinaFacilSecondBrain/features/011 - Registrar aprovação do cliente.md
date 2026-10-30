---
data: 2026-10-30
status: planejada
fase: F6
uc: "UC11"
us: "US11, US12"
rf: "RF11"
---

# 011 — Registrar aprovação do cliente

## Objetivo

Entregar **UC11 — Registrar aprovação do cliente** para o ator **Atendente**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC11.

## Referências

| Item | Valor |
|---|---|
| Fase | F6 — Aprovação e execução |
| Caso de uso | UC11 |
| Histórias | US11, US12 |
| Requisitos | RF11 |
| Ator | Atendente |
| Regras de negócio | RN03, RN04 |
| Tabelas | aprovacoes, ordens_servico, historico_transicoes |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Aprovação leva a OS de `AGUARDANDO_APROVACAO` para `APROVADA`, com data/hora e forma de contato | 🔲 Pendente |
| CA02 | Recusa leva a OS para `CANCELADA` e registra o motivo (US12) ⚠️ | 🔲 Pendente |
| CA03 | Cliente pedir ajuste e voltar ao orçamento (FORA DO MVP até a decisão D3) | ❌ Descartado (fora do MVP) |
| CA04 | Orçamento fica imutável em `AGUARDANDO_APROVACAO`: tentativa de alterar recebe 409 | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| POST | `/os/:id/aprovacao` | Atendente | Aprova (`APROVADA`) ou recusa (`CANCELADA`) |

Contrato completo em [[Endpoints]].

## Telas

- **T19 Aprovação ou recusa do cliente** — `/os/:id/aprovacao` (Atendente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[009 - Montar orçamento]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

D3 aberta: no MVP o cliente só aprova ou recusa.
