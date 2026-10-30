---
data: 2026-10-30
---

# Quadro do Trello

Quadro: https://trello.com/b/6ae4da0b233ab7b22fcc5814

O quadro espelha o vault: nada é inventado nele. A especificação completa está em `metodos/trello-quadro.json`, gerada por `metodos/gerar-trello.py` a partir de `features/`, do [[CHECKLIST]] e do [[Roadmap]].

## Estrutura

| Lista | O que tem |
|---|---|
| ✅ Concluído | O que já foi feito: análise, documentação, F1, backend e app de usuários |
| 🔄 Em andamento | Features 000, 001 e 006, com as tarefas e os critérios de aceitação |
| ⛔ Bloqueado (depende do usuário) | Projeto Supabase de teste, chave de serviço, pooler, push, rotação de credenciais, Android real |
| ❓ Decisões | 003, 005, 011, propostas 007 a 010 e o escopo de LGPD, plano de testes e wireframes |
| ⏭️ Próximas, em ordem de execução | As demais features, uma por cartão, com a semana no título, vencimento no fim da semana e as 9 tarefas |
| 🏁 Marcos e folga | M1 a M5 e a semana 9 de folga |

Cada cartão de feature tem a descrição com os critérios de aceitação e o status de cada um, o caminho da especificação no repositório e um checklist "Tarefas" com as 9 tarefas padrão (ou as da fundação). Etiquetas por fase (F1 a F9), por área (Backend, App, Documentação) e as especiais Marco, Decisão e "Bloqueado pelo usuário".

## Como ligar o Trello ao Claude Code

O Trello oferece um servidor MCP oficial. Num terminal (ou no prompt com `!` na frente):

```bash
claude mcp add --transport http trello https://mcp.trello.com/v1
```

Depois, dentro do Claude Code, `/mcp`, escolher o Trello e autorizar no navegador. Se as ferramentas do Trello não aparecerem na mesma sessão, reiniciar o Claude Code. A autorização é feita pelo usuário; nenhuma chave vai para o repositório.

## Como manter o quadro atualizado

1. Ao fechar uma feature ou uma semana: atualizar o CHECKLIST e os critérios no vault (fonte única).
2. Regerar a especificação: `python3 OficinaFacilSecondBrain/metodos/gerar-trello.py`.
3. Mover os cartões entre as listas e marcar os itens dos checklists pelo MCP do Trello.

O Trello é uma **vista** do vault; em caso de divergência, vale o vault.
