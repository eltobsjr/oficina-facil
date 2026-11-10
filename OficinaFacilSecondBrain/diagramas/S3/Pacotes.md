---
data: 2026-11-10
---

# S3 · Diagrama de pacotes de clientes e veículos

Semana 3 (16/11 a 22/11): clientes e veículos, do banco à tela. Features: [[002 - Gerir clientes]] e [[003 - Gerir veículos]]. Tipo: **pacotes**.

**Para que serve:** mostrar como as duas features se ligam no backend e no app.

```mermaid
flowchart TD
  subgraph BK["backend/src/modules"]
    direction TB
    subgraph BC["clientes"]
      direction TB
      CI["index.ts<br/>a única porta"]
      CS["routes, service,<br/>repository"]
    end
    subgraph BV["veiculos"]
      direction TB
      VI["index.ts<br/>a única porta"]
      VS["routes, service,<br/>repository"]
    end
  end

  subgraph AP["mobile/lib/features"]
    direction TB
    AC["clientes<br/>presentation, domain, data"]
    AV["veiculos<br/>presentation, domain, data"]
  end

  CI -.-> CS
  VI -.-> VS
  VS -.->|"exige que o cliente exista"| CI
  AV -.->|"seletor de cliente"| AC
  AC ==>|"HTTPS + JWT"| CI
  AV ==>|"HTTPS + JWT"| VI

  classDef app fill:#DBEAFE,stroke:#1E40AF,color:#0F172A
  classDef api fill:#FEF3C7,stroke:#B45309,color:#7C2D12
  class AC,AV app
  class CI,CS,VI,VS api
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa grande | Um pacote |
| Seta tracejada | A origem **usa** o destino |
| Seta grossa | Chamada pela rede |
| Azul / âmbar | App / backend |

## O que o diagrama diz

- No backend, `veiculos` precisa saber se o cliente existe. Ele pergunta ao módulo `clientes` **pela porta `index.ts`**, nunca pelo interior.
- No app, a lista de veículos aparece dentro do cliente, e a transferência de veículo usa o seletor de clientes.

## O que **não** aparece

`veiculos` não importa o `repository` de `clientes`. Um teste de arquitetura quebra o build se isso acontecer.
