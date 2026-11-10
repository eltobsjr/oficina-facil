---
data: 2026-11-10
---

# S2 · Diagrama de sequência de usuários

Feature [[006 - Gerir usuários]]. Tipo: **sequência**. Cenário: o gerente cria um usuário. Os participantes são os objetos reais do código.

```mermaid
sequenceDiagram
  autonumber
  actor G as Gerente
  box rgb(239,246,255) App
    participant F as UsuarioFormPage
  end
  box rgb(255,249,235) Backend
    participant API as usuariosRouter
    participant S as ServicoUsuarios
  end
  box rgb(236,253,243) Supabase
    participant AU as Auth
    participant DB as Postgres
  end
  G->>F: nome, e-mail, perfil e senha
  F->>API: POST /usuarios
  API->>S: criar(dados)
  S->>DB: e-mail já existe?
  S->>AU: cria a conta
  S->>DB: grava o perfil
  opt gravar o perfil falhou
    S->>AU: remove a conta criada
  end
  S-->>F: 201, usuário criado
  F-->>G: volta para a lista
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa no topo | Um objeto (ou a pessoa) |
| Fundo azul, âmbar, verde | O objeto está no app, no backend ou no Supabase |
| Número | A ordem dos passos |
| Seta cheia / tracejada | Chamada / retorno |
| `opt` | Passo que só acontece em caso de falha |

## O que o diagrama diz

- Criar tem uma **compensação**: se gravar o perfil falhar, a conta criada no Supabase é removida, para não ficar uma conta pela metade.
- O e-mail repetido é recusado logo no começo.

## O que **não** aparece

Inativar, alterar perfil e redefinir senha seguem o mesmo molde. Ao inativar, o serviço confere antes que sobra pelo menos um gerente ativo.
