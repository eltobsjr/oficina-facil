---
data: 2026-10-30
status: planejada
fase: F3
uc: "UC02"
us: "US02"
rf: "RF02"
---

# 002 — Gerir clientes

## Objetivo

Entregar **UC02 — Gerir clientes** para o ator **Atendente**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC02.

## Referências

| Item | Valor |
|---|---|
| Fase | F3 — Clientes e veículos |
| Caso de uso | UC02 |
| Histórias | US02 |
| Requisitos | RF02 |
| Ator | Atendente |
| Regras de negócio | — |
| Tabelas | clientes |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Cadastrar cliente com nome, documento, telefone, e-mail e endereço ⚠️ | 🔲 Pendente |
| CA02 | Documento duplicado é recusado e mostra o cadastro existente | 🔲 Pendente |
| CA03 | Campos obrigatórios ausentes são destacados e o cadastro não é salvo | 🔲 Pendente |
| CA04 | Buscar por nome ou documento e alterar os dados | 🔲 Pendente |
| CA05 | Inativar cliente mantém o histórico de OS | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| GET | `/clientes` | Atendente | Busca por nome ou documento |
| POST | `/clientes` | Atendente | Cadastra |
| GET | `/clientes/:id` | Atendente | Detalha |
| PATCH | `/clientes/:id` | Atendente | Altera |
| POST | `/clientes/:id/inativar` | Atendente | Inativa (sem OS ativa) |

Contrato completo em [[Endpoints]].

## Telas

- **T05 Lista de clientes** — `/clientes` (Atendente)
- **T06 Formulário de cliente** — `/clientes/novo · /clientes/:id` (Atendente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[001 - Autenticar]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

A regra "cliente com OS ativa não pode ser inativado" é testada na feature 007, quando a OS existe.
