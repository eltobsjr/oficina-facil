---
data: 2026-11-10
---

# S1 · Diagrama de pacotes do sistema

Semana 1 (02/11 a 08/11): fundação e backend de usuários. Features: [[000 - Fundação técnica]] e [[006 - Gerir usuários]]. Tipo: **pacotes** (*Engenharia de Software Moderna*, cap. 4).

**Para que serve:** mostrar **onde cada coisa mora** e **quem pode depender de quem**, no sistema inteiro.

## Notação

O Mermaid não tem diagrama de pacotes nativo. Convenção: `flowchart` com `subgraph` no papel do pacote, seta tracejada para dependência (a origem **usa** o destino) e seta grossa para a fronteira de rede.

```mermaid
flowchart TD
  subgraph APP["app/ · Flutter (web e Android)"]
    direction TB
    PRES["features/*/presentation<br/>telas e providers"]
    DOMA["features/*/domain<br/>entidades e contratos"]
    DATAA["features/*/data<br/>ÚNICA camada que fala com a rede"]
    CORE["core<br/>tema, rotas, cliente HTTP, widgets"]
  end

  subgraph API["backend/ · Node + Express (Render)"]
    direction TB
    ROUTES["modules/*/routes<br/>recebe e valida o pedido"]
    SERV["modules/*/service<br/>REGRAS DE NEGÓCIO"]
    REPO["modules/*/repository<br/>acesso ao banco"]
    SHARED["shared<br/>JWT, erros, http, db"]
  end

  subgraph SUPA["Supabase"]
    direction TB
    AUTH["Auth<br/>login e JWT"]
    PG[("Postgres<br/>com RLS")]
  end

  PRES -.-> DATAA
  PRES -.-> DOMA
  PRES -.-> CORE
  DATAA -.-> DOMA
  DATAA -.-> CORE
  DATAA ==>|"HTTPS + JWT"| ROUTES
  DATAA ==>|login| AUTH

  ROUTES -.-> SERV
  ROUTES -.-> SHARED
  SERV -.-> REPO
  SERV -.-> SHARED
  REPO -.-> PG
  SHARED -.->|valida o JWT| AUTH

  classDef app fill:#DBEAFE,stroke:#1E40AF,color:#0F172A
  classDef api fill:#FEF3C7,stroke:#B45309,color:#7C2D12
  classDef sup fill:#DCFCE7,stroke:#047857,color:#064E3B
  class PRES,DOMA,DATAA,CORE app
  class ROUTES,SERV,REPO,SHARED api
  class AUTH,PG sup
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa grande (`subgraph`) | Um pacote: grupo de código com uma responsabilidade |
| Seta tracejada | Dependência: a origem **usa** o destino |
| Seta grossa | Fronteira de processo: atravessa a rede |
| Azul, âmbar, verde | App no dispositivo, backend no servidor, Supabase |

## O que o diagrama diz

- O app só fala com o mundo por **uma** camada, `data`. A tela nunca chama a API direto.
- Toda regra de negócio está em `service`, no backend. O app só ajuda a pessoa.
- Só o backend escreve no banco. O login é a única conversa direta do app com o Supabase.

## O que **não** aparece (de propósito)

| Seta ausente | Por quê |
|---|---|
| `presentation` → rede | Tela nunca chama HTTP. Sempre via `data` |
| app → Postgres | O app não lê nem escreve no banco (RLS barra) |
| `repository` → `service` | Dependência de mão única: persistência não chama regra |
| `routes` → `repository` | A rota não pula o serviço |

Seta fora deste desenho é erro de arquitetura, não liberdade de implementação.
