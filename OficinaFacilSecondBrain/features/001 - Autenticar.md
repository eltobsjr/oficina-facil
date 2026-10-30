---
data: 2026-10-30
status: planejada
fase: F2
uc: "UC01"
us: "US01, US22"
rf: "RF01, RF23"
---

# 001 — Autenticar

## Objetivo

Entregar **UC01 — Autenticar** para o ator **Todos**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção UC01.

## Referências

| Item | Valor |
|---|---|
| Fase | F2 — Acesso e usuários |
| Caso de uso | UC01 |
| Histórias | US01, US22 |
| Requisitos | RF01, RF23 |
| Ator | Todos |
| Regras de negócio | RN09 |
| Tabelas | perfis |
| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |

## Critérios de aceitação

| # | Critério | Status |
|---|---|---|
| CA01 | Login e senha corretos (Supabase Auth) abrem a sessão; `GET /me` devolve nome e perfil e o app monta o menu do perfil | 🔲 Pendente |
| CA02 | Credenciais inválidas negam o acesso com mensagem genérica (sem dizer se o erro foi no login ou na senha) | 🔲 Pendente |
| CA03 | Token expirado é renovado pelo app; refresh inválido volta ao login | 🔲 Pendente |
| CA04 | Usuário inativo vê a mensagem de que está desativado | 🔲 Pendente |
| CA05 | Rota protegida sem sessão redireciona ao login | 🔲 Pendente |
| CA06 | O menu mostra só o que o perfil permite (RN09) | 🔲 Pendente |
| CA07 | "Sair" encerra a sessão e volta ao login (US22) ⚠️ | 🔲 Pendente |
| CA08 | Rotas do app protegidas por perfil: sem sessão vai ao login; perfil sem permissão não abre a rota | 🔲 Pendente |

Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.

## API

| Método | Caminho (`/api/v1`) | Perfis | O que faz |
|---|---|---|---|
| GET | `/me` | Todos | Nome, perfil e situação do usuário autenticado |

Contrato completo em [[Endpoints]].

## Telas

- **T01 Login** — `/login` (Todos (sem sessão))
- **T02 Início (menu por perfil)** — `/` (Todos)

Catálogo completo em [[Mapa de telas]].

## Dependências

- [[000 - Fundação técnica]]

## Tarefas

As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.
