---
data: 2026-11-10
---

# S2 · Pacotes do app

Semana 2 (09/11 a 15/11): login, sessão e usuários no app. Features: [[001 - Autenticar]] e [[006 - Gerir usuários]]. Camadas gerais em [[Diagramas]].

```mermaid
flowchart TB
  subgraph autenticacao[features/autenticacao]
    a1[presentation<br/>login e sessão]
    a2[domain<br/>UsuarioSessao e contrato]
    a3[data<br/>fala com a API]
  end
  subgraph usuarios[features/usuarios]
    u1[presentation<br/>lista e formulário]
    u2[domain<br/>Usuario e contrato]
    u3[data<br/>fala com a API]
  end
  core[core<br/>tema, rotas, rede, widgets]

  a1 --> a2
  a3 --> a2
  u1 --> u2
  u3 --> u2
  a1 --> core
  u1 --> core
  a3 --> core
  u3 --> core
```

## Como ler

- Cada feature tem três pastas: **presentation** (telas), **domain** (as coisas e os contratos) e **data** (quem conversa com a API).
- As setas apontam para `domain`: ele não conhece telas nem rede.
- `core` é o que todas usam: tema, rotas por perfil, cliente da API e componentes.

## Por que é assim

O `domain` ficando limpo deixa trocar a tela ou a API sem mexer nas regras. A regra de negócio mesmo fica no backend; o app só ajuda a pessoa.
