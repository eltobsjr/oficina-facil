---
data: 2026-11-10
---

# S2 · Diagrama de atividades do login

Feature [[001 - Autenticar]]. Tipo: **atividades**. Mostra o caminho completo que a pessoa percorre, com as decisões.

```mermaid
flowchart LR
  INICIO(("início")) --> ABRIR["Abrir o app"]
  ABRIR --> TEM{"Há sessão<br/>salva?"}
  TEM -->|sim| MENU["Abrir o menu<br/>do perfil"]
  TEM -->|não| LOGIN["Digitar e-mail<br/>e senha"]
  LOGIN --> OK{"Credenciais e<br/>conta válidas?"}
  OK -->|sim| MENU
  OK -->|não| MSG["Mostrar a<br/>mensagem"]
  MSG --> LOGIN
  MENU --> FIM(("fim"))

  classDef acao fill:#F8FAFC,stroke:#1E40AF,color:#0F172A
  classDef decisao fill:#FEF3C7,stroke:#B45309,color:#7C2D12
  class ABRIR,LOGIN,MENU,MSG acao
  class TEM,OK decisao
```

## Legenda

| Elemento | Significa |
|---|---|
| Círculo | Início do fluxo |
| Retângulo | Uma ação |
| Losango | Uma decisão, com os caminhos nomeados |

## O que o diagrama diz

Quem já tem sessão vai direto ao menu. Quem não tem passa pelo login. Se a senha estiver errada, a mensagem é genérica (não diz se foi o e-mail ou a senha); conta inativa ou sem perfil é recusada com o motivo.
