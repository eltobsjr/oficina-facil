---
data: 2026-10-30
status: planejada
fase: F3
uc: "UC03"
us: "US03"
rf: "RF03"
---

# 003 — Gerir veículos

## Objetivo

Entregar **UC03 — Gerir veículos** para o ator **Atendente**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC03.

## Referências

| Item | Valor |
|---|---|
| Fase | F3 — Clientes e veículos |
| Caso de uso | UC03 |
| Histórias | US03 |
| Requisitos | RF03 |
| Ator | Atendente |
| Regras de negócio | — |
| Tabelas | veiculos |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Cadastrar veículo vinculado a um cliente, com placa, marca, modelo, ano, cor e quilometragem ⚠️ | 🔲 Pendente |
| CA02 | Placa duplicada é recusada e exibe o veículo existente | 🔲 Pendente |
| CA03 | Placa em formato inválido é recusada | 🔲 Pendente |
| CA04 | Buscar por placa ou por cliente e alterar os dados | 🔲 Pendente |
| CA05 | Transferir o veículo para outro cliente mantém o histórico de OS com o dono anterior ⚠️ | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| GET | `/clientes/:id/veiculos` | Atendente | Veículos do cliente |
| POST | `/clientes/:id/veiculos` | Atendente | Cadastra |
| GET | `/veiculos` | Atendente | Busca por placa |
| GET | `/veiculos/:id` | Atendente | Detalha |
| PATCH | `/veiculos/:id` | Atendente | Altera |
| POST | `/veiculos/:id/transferir` | Atendente | Muda o dono |
| POST | `/veiculos/:id/inativar` | Atendente | Inativa |

Contrato completo em [[Endpoints]].

## Telas

- **T07 Veículos do cliente e formulário** — `/clientes/:id/veiculos · /clientes/:id/veiculos/novo` (Atendente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[002 - Gerir clientes]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.
