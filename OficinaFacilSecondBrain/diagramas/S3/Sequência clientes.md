---
data: 2026-11-10
---

# S3 · Diagrama de sequência de clientes

Feature [[002 - Gerir clientes]]. Tipo: **sequência**. Cenário: o atendente cadastra um cliente, e o documento pode já existir.

```mermaid
sequenceDiagram
  autonumber
  actor A as Atendente
  box rgb(239,246,255) App
    participant F as ClienteFormPage
  end
  box rgb(255,249,235) Backend
    participant API as clientesRouter
    participant S as ServicoClientes
  end
  box rgb(236,253,243) Supabase
    participant DB as Postgres
  end
  A->>F: dados do cliente
  F->>API: POST /clientes
  API->>S: criar(dados)
  S->>DB: grava o cliente
  alt documento já existe
    DB-->>S: documento repetido
    S-->>F: 409 com o cadastro existente
    F-->>A: mostra o cadastro existente
  else documento novo
    DB-->>S: cliente gravado
    S-->>F: 201, cliente criado
    F-->>A: volta para a lista
  end
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa no topo | Um objeto (ou a pessoa) |
| Fundo azul, âmbar, verde | O objeto está no app, no backend ou no Supabase |
| Número | A ordem dos passos |
| Seta cheia / tracejada | Chamada / retorno |
| `alt` | Dois caminhos possíveis |

## O que o diagrama diz

A unicidade do documento é garantida **pelo banco**. Se o documento já existe, o backend devolve 409 junto com o cadastro existente, e a tela o mostra para o atendente não duplicar.

## O que **não** aparece

Inativar: o cliente com OS ativa é recusado (409), regra que só passa a valer com as ordens de serviço da fase 5.
