# Diagramas — OficinaFácil

Diagramas em Mermaid. Evoluem junto com o código, a cada entrega.

> UC18 e UC19 não aparecem no resumo da Entrega 1; foram assumidos a partir dos
> papéis (entrada no estoque e faturamento). Conferir com o documento oficial.

## 1. Casos de uso (Entrega 1)

Mermaid não tem diagrama de casos de uso nativo; usamos `flowchart`.
Linha sólida = associação, tracejada = `include` / `extend`.

```mermaid
flowchart LR
  AT([Atendente])
  ME([Mecânico])
  AL([Almoxarife])
  GE([Gerente])

  subgraph OficinaFacil[Sistema OficinaFácil]
    UC01(UC01 Autenticar)
    UC02(UC02 Gerir clientes)
    UC03(UC03 Gerir veículos)
    UC04(UC04 Gerir peças)
    UC05(UC05 Gerir serviços)
    UC06(UC06 Gerir usuários)
    UC07(UC07 Abrir OS)
    UC08(UC08 Registrar diagnóstico)
    UC09(UC09 Montar orçamento)
    UC10(UC10 Autorizar desconto)
    UC11(UC11 Registrar aprovação do cliente)
    UC12(UC12 Executar serviço)
    UC13(UC13 Registrar peças usadas)
    UC14(UC14 Concluir OS)
    UC15(UC15 Entregar e registrar pagamento)
    UC16(UC16 Consultar OS)
    UC17(UC17 Cancelar OS)
    UC18(UC18 Dar entrada no estoque)
    UC19(UC19 Ver faturamento)
  end

  AT --- UC01 & UC02 & UC03 & UC07 & UC09 & UC11 & UC15 & UC16 & UC17
  ME --- UC01 & UC08 & UC12 & UC14
  AL --- UC01 & UC04 & UC18
  GE --- UC01 & UC05 & UC06 & UC10 & UC16 & UC17 & UC19

  UC12 -. "«include»" .-> UC13
  UC10 -. "«extend»" .-> UC09
  UC17 -. "«extend»" .-> UC16
```

## 2. Ciclo de vida da ordem de serviço

Implementado em `lib/features/ordem_servico/domain/entities/status_ordem_servico.dart`.

```mermaid
stateDiagram-v2
  [*] --> ABERTA: UC07
  ABERTA --> DIAGNOSTICADA: UC08
  DIAGNOSTICADA --> AGUARDANDO_APROVACAO: UC09
  AGUARDANDO_APROVACAO --> APROVADA: UC11 aprova
  AGUARDANDO_APROVACAO --> CANCELADA: UC11 recusa
  APROVADA --> EM_EXECUCAO: UC12
  EM_EXECUCAO --> CONCLUIDA: UC14
  CONCLUIDA --> ENTREGUE: UC15
  ENTREGUE --> [*]
  CANCELADA --> [*]

  note right of AGUARDANDO_APROVACAO
    Desconto acima de 10% exige
    autorização do gerente (UC10)
  end note
  note left of CANCELADA
    UC17: qualquer estado
    antes da entrega
  end note
```

## 3. Arquitetura

Clean Architecture organizada por feature. A dependência aponta sempre para dentro:
`presentation → domain ← data`.

```mermaid
flowchart TB
  subgraph presentation[presentation]
    PG[pages / widgets]
    PV[providers Riverpod]
  end
  subgraph domain[domain]
    EN[entities]
    RP[repositories - contratos]
    US[usecases]
  end
  subgraph data[data]
    RI[repositories - implementações]
    DS[datasources / models]
  end

  PG --> PV --> US --> RP
  US --> EN
  RI -. implementa .-> RP
  RI --> DS
```

## 4. Estrutura de pastas

```mermaid
flowchart LR
  lib --> main.dart & app.dart & core & features
  core --> theme & router
  features --> home & ordem_servico
  home --> h1[presentation/pages]
  ordem_servico --> d1[domain/entities]
```

Novas features seguem `features/<nome>/{domain,data,presentation}`; as camadas
`data` e `usecases` são criadas quando a primeira regra de negócio exigir.
