---
data: 2026-11-10
---

# S2 · Diagrama de pacotes do app

Semana 2 (09/11 a 15/11): login, sessão e usuários no app. Features: [[001 - Autenticar]] e [[006 - Gerir usuários]]. Tipo: **pacotes**. Camadas gerais em [[Diagramas]].

**Para que serve:** mostrar como as duas features do app se organizam e do que dependem.

```mermaid
flowchart TD
  subgraph AUT["features/autenticacao"]
    direction TB
    AP["presentation<br/>LoginPage, SessaoNotifier"]
    AD["domain<br/>UsuarioSessao,<br/>AutenticacaoRepository"]
    AT["data<br/>AutenticacaoRepositoryApi,<br/>ProvedorDeSessao"]
  end

  subgraph USU["features/usuarios"]
    direction TB
    UP["presentation<br/>UsuariosPage, UsuarioFormPage"]
    UD["domain<br/>Usuario,<br/>UsuariosRepository"]
    UT["data<br/>UsuariosRepositoryApi"]
  end

  subgraph CORE["core"]
    direction TB
    NET["network<br/>ApiClient"]
    ROT["router<br/>acesso por perfil"]
    WID["widgets e theme"]
  end

  AP -.-> AD
  AT -.-> AD
  UP -.-> UD
  UT -.-> UD
  AT -.-> NET
  UT -.-> NET
  AP -.-> ROT
  AP -.-> WID
  UP -.-> WID

  classDef feat fill:#DBEAFE,stroke:#1E40AF,color:#0F172A
  classDef core fill:#F1F5F9,stroke:#475569,color:#0F172A
  class AP,AD,AT,UP,UD,UT feat
  class NET,ROT,WID core
```

## Legenda

| Elemento | Significa |
|---|---|
| Caixa grande | Um pacote |
| Seta tracejada | A origem **usa** o destino |
| Azul / cinza | Código da feature / código compartilhado (`core`) |

## O que o diagrama diz

- Cada feature tem três pastas com papéis diferentes: **presentation** (telas), **domain** (as coisas e os contratos) e **data** (a conversa com a API).
- As setas apontam para `domain`, que não conhece tela nem rede.
- Só `data` usa o `ApiClient`.

## O que **não** aparece

`domain` não depende de nada. `presentation` não usa `ApiClient`. Uma feature não usa a pasta `data` da outra.
