---
data: 2026-10-30
status: aceita
---

# 002 — Autenticação pelo Supabase Auth

## Contexto

Quatro perfis precisam de login seguro, e queremos evitar guardar senha no nosso código.

## Alternativas consideradas

- Auth próprio no backend com hash
- Firebase Auth

## Decisão

O app faz login no Supabase Auth. O backend não emite token: valida o JWT por JWKS e lê o perfil na tabela `perfis`. Criação de usuário (UC06) usa a API admin do Supabase com a chave de serviço, que existe só no backend.

## Consequências

- Nenhuma senha é **guardada** no nosso banco. Senhas trafegam pelo backend só em UC06 (criar e redefinir usuário) e nunca são logadas.
- O JWT é validado por JWKS: aceitar só os algoritmos do JWKS do projeto, conferir `iss`, `aud` (`authenticated`) e `exp`. O fallback HS256 do Confia **não** é adotado (exigiria o segredo JWT no backend e abre confusão de algoritmo).
- Usuário inativado é banido no Auth (`ban_duration`) além de `perfis.ativo = false`.
