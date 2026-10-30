---
data: 2026-10-30
status: planejada
fase: F2
uc: "UC06"
us: "US06"
rf: "RF06"
---

# 006 — Gerir usuários

## Objetivo

Entregar **UC06 — Gerir usuários** para o ator **Gerente**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC06.

## Referências

| Item | Valor |
|---|---|
| Fase | F2 — Acesso e usuários |
| Caso de uso | UC06 |
| Histórias | US06 |
| Requisitos | RF06 |
| Ator | Gerente |
| Regras de negócio | RN09 |
| Tabelas | perfis |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Criar usuário com nome, e-mail, perfil (Atendente, Mecânico, Almoxarife ou Gerente) e senha inicial; o backend cria a conta no Supabase Auth com a chave de serviço | 🔲 Pendente |
| CA02 | E-mail (login) duplicado é recusado | 🔲 Pendente |
| CA03 | Trocar o perfil vale a partir do próximo login | 🔲 Pendente |
| CA04 | Redefinir senha | 🔲 Pendente |
| CA05 | Inativar usuário impede a autenticação e mantém o histórico de ações | 🔲 Pendente |
| CA06 | O sistema impede inativar o último gerente ativo ⚠️ | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| GET | `/usuarios` | Gerente | Lista usuários |
| POST | `/usuarios` | Gerente | Cria usuário (Auth + perfil) |
| GET | `/usuarios/:id` | Gerente | Detalha |
| PATCH | `/usuarios/:id` | Gerente | Altera nome e perfil |
| POST | `/usuarios/:id/redefinir-senha` | Gerente | Nova senha |
| POST | `/usuarios/:id/inativar` | Gerente | Inativa (não o último gerente) |
| POST | `/usuarios/:id/ativar` | Gerente | Reativa |

Contrato completo em [[Endpoints]].

## Telas

- **T03 Lista de usuários** — `/usuarios` (Gerente)
- **T04 Formulário de usuário** — `/usuarios/novo · /usuarios/:id` (Gerente)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[001 - Autenticar]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.

## Notas técnicas

Senha guardada pelo Supabase Auth (D2); nunca passa pelo nosso banco. Chave de serviço só no backend.
