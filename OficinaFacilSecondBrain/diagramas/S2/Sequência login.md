---
data: 2026-11-10
---

# S2 · Diagrama de sequência do login

Feature [[001 - Autenticar]]. Tipo: **sequência**. Cenário: uma pessoa entra com e-mail e senha. Os participantes são os objetos reais do código.

**Para que serve:** mostrar a ordem das chamadas entre os objetos em **um** cenário.

```mermaid
sequenceDiagram
  autonumber
  actor P as Pessoa
  box rgb(239,246,255) App
    participant L as LoginPage
    participant S as SessaoNotifier
  end
  box rgb(255,249,235) Backend
    participant API as API /me
  end
  box rgb(236,253,243) Supabase
    participant AU as Auth
    participant DB as Postgres
  end
  P->>L: e-mail e senha
  L->>S: entrar(email, senha)
  S->>AU: signInWithPassword
  AU-->>S: JWT
  S->>API: GET /me com o JWT
  API->>AU: confere o JWT
  API->>DB: busca o perfil
  alt conta ativa
    API-->>S: nome e perfil
    S-->>P: abre o menu do perfil
  else inativa ou sem perfil
    API-->>S: 403
    S-->>P: mensagem e sessão encerrada
  end
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa no topo | Um objeto (ou a pessoa) |
| Fundo azul, âmbar, verde | O objeto está no app, no backend ou no Supabase |
| Número | A ordem dos passos |
| Linha vertical | A vida do objeto |
| Seta cheia | Chamada |
| Seta tracejada | Retorno |
| `alt` | Dois caminhos possíveis |

## O que o diagrama diz

O Supabase confere a senha e devolve um token. A API confere o token, busca o perfil e só então o app abre o menu. Conta inativa ou sem perfil é negada e a sessão é desfeita.

## O que **não** aparece

A renovação do token e as outras features (o fluxo completo está em [[Atividades login]]).
