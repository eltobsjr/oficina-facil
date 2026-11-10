---
data: 2026-11-10
---

# S3 · Diagrama de sequência de veículos

Feature [[003 - Gerir veículos]]. Tipo: **sequência**. Cenário: o atendente transfere um veículo para outro cliente.

```mermaid
sequenceDiagram
  autonumber
  actor A as Atendente
  box rgb(239,246,255) App
    participant F as VeiculoFormPage
  end
  box rgb(255,249,235) Backend
    participant API as veiculosRouter
    participant S as ServicoVeiculos
    participant C as módulo clientes
  end
  box rgb(236,253,243) Supabase
    participant DB as Postgres
  end
  A->>F: escolhe o novo dono
  F->>API: POST /veiculos/:id/transferir
  API->>S: transferir(id, novoDono)
  S->>C: o novo cliente existe?
  C-->>S: sim
  S->>DB: troca o dono do veículo
  S-->>F: 200, veículo atualizado
  F-->>A: mostra o novo dono
  Note over S,DB: o histórico de OS fica com o dono anterior
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa no topo | Um objeto (ou a pessoa) |
| Fundo azul, âmbar, verde | O objeto está no app, no backend ou no Supabase |
| Número | A ordem dos passos |
| Seta cheia / tracejada | Chamada / retorno |
| `Note` | Observação sobre uma regra |

## O que o diagrama diz

- Para transferir, o serviço confirma que o **novo cliente existe** perguntando ao módulo `clientes` pela porta dele.
- Só o dono do veículo muda. As ordens de serviço antigas continuam ligadas ao dono anterior.

## O que **não** aparece

O cadastro de veículo com placa repetida: a placa é única e o erro 409 traz o veículo existente, no mesmo molde do cliente.
