---
data: 2026-11-10
status: proposta
---

# 015 — Scrum e Kanban no projeto

## Contexto

O usuário pediu que o backlog, o quadro do Trello e as regras de "pronto" sigam o Scrum, como descrito em *Engenharia de Software Moderna* (Marco Tulio Valente): Cap. 2 (processos: Scrum e Kanban) e Cap. 3 (requisitos e histórias de usuário). Referência de organização: o repositório ToolRent.

## Decisão

Adotar o Scrum no ritmo **semanal** que o [[Roadmap]] já usa (cada semana é uma sprint), com o quadro do Trello como Kanban. As regras estão em [[Scrum e Kanban no projeto]]: product backlog, sprint backlog, definição de pronto (DoR), definição de feito (DoD) e limite de trabalho em andamento.

## Consequências

- O quadro do Trello ganha as colunas Product Backlog, Sprint Backlog, Em andamento, Impedimentos e Concluído.
- Cada card é uma história de usuário com critérios de aceitação, ligada ao UC e à feature.
- Não muda numeração (R5), nem o CHECKLIST, que continua sendo a lista mestra.
- Os papéis de Product Owner e Scrum Master ficam **a definir pela equipe** (⚠️); não foram atribuídos a ninguém.
- A regra "diagrama antes do código" do ToolRent **não** foi adotada: aqui o esboço do diagrama já mora no arquivo da feature.
