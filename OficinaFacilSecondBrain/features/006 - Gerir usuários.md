---
data: 2026-10-30
status: em andamento
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
| CA01 | Criar usuário com nome, e-mail, perfil (Atendente, Mecânico, Almoxarife ou Gerente) e senha inicial; o backend cria a conta no Supabase Auth com a chave de serviço | 🔄 Em progresso — backend e telas T03/T04 testados com dublês; **falta a prova com conta real** (precisa da chave de serviço e de um usuário) |
| CA02 | E-mail (login) duplicado é recusado | 🔄 Em progresso — backend recusa (409) e a tela mostra o erro no campo, ambos testados; falta a conta real |
| CA03 | Trocar o perfil vale a partir do próximo login | 🔄 Em progresso — backend altera o perfil; o efeito "próximo login" vem de `perfis` ser lido a cada requisição; falta o app |
| CA04 | Redefinir senha | 🔄 Em progresso — backend e diálogo de redefinição testados (exige 8 caracteres); falta a conta real |
| CA05 | Inativar usuário impede a autenticação e mantém o histórico de ações | 🔄 Em progresso — inativa o perfil e bane no Auth; `GET /me` já devolve 403 para inativo; confirmação e botão Reativar testados na tela |
| CA06 | O sistema impede inativar o último gerente ativo ⚠️ | 🔄 Em progresso — travado no banco com `FOR UPDATE` e a tela explica o erro; o teste de concorrência está escrito e **não foi executado** (precisa do projeto de teste) |

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
