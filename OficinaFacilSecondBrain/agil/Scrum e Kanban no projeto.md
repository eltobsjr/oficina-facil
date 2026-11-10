---
data: 2026-11-10
---

# Scrum e Kanban no projeto

Como o projeto usa o Scrum, em linguagem simples. Base: *Engenharia de Software Moderna*, Cap. 2 (Scrum e Kanban) e Cap. 3 (histórias de usuário). Decisão: [[015 - Scrum e Kanban no projeto]].

## Os três artefatos

| Artefato do Scrum | No projeto |
|---|---|
| **Product backlog** | Todas as histórias que faltam, em ordem de prioridade: [[Histórias de usuário]] e [[CHECKLIST]]. No Trello, a coluna **Product Backlog**. |
| **Sprint backlog** | As histórias escolhidas para a semana, vindas do [[Roadmap]]. No Trello, a coluna **Sprint Backlog**. |
| **Incremento** | O que ficou pronto e funcionando ao fim da semana: app e API, provados, com a documentação em dia. |

## Os eventos (semanais)

| Evento | Quando | Para quê |
|---|---|---|
| **Planejamento** | Início da semana | Escolher no product backlog as histórias da semana (só as que cumprem a DoR) |
| **Reunião diária** | Todo dia de trabalho, curta | O que fiz, o que farei, o que me trava |
| **Revisão** | Fim da semana | Mostrar o que ficou pronto (slides e app) |
| **Retrospectiva** | Fim da semana | O que manter e o que mudar |

Papéis (Product Owner, Scrum Master e time): ⚠️ **a equipe define**; nada foi atribuído.

## Definição de pronto para entrar na sprint (DoR)

Uma história só vai para o **Sprint Backlog** se tudo isto for verdade:

- [ ] Tem identificação estável: história (US), caso de uso (UC) e feature
- [ ] Está no formato "Como…, quero…, para…"
- [ ] Tem critérios de aceitação objetivos, com resposta sim ou não
- [ ] Cita o caso de uso e as regras de negócio (RN) envolvidas
- [ ] Tem o esboço do diagrama no arquivo da feature
- [ ] Não depende de decisão aberta (R23) nem de feature ainda não concluída (R22)
- [ ] Cabe numa semana; se não couber, é dividida por **comportamento**, nunca por camada técnica

## Definição de feito (DoD)

Uma história só vai para **Concluído** se tudo isto for verdade (vem do `CLAUDE.md`):

- [ ] Todos os critérios de aceitação estão ✅, provados (R11)
- [ ] Os comandos de verificação da parte alterada rodaram e passaram
- [ ] A regra de negócio está no backend, em transação (R14)
- [ ] Tem teste, e bug corrigido tem teste de regressão (R12)
- [ ] Vault atualizado na ordem: critérios, notas afetadas, CHECKLIST, devtrack (R4)
- [ ] Sem segredo, `.env` ou dado pessoal real no que foi commitado (R20, R30)
- [ ] Commit feito (R8); o card foi para **Concluído**

## Regras do quadro (Kanban)

- Colunas, da esquerda para a direita: **Product Backlog → Sprint Backlog → Em andamento → Concluído**; **Impedimentos** e **Decisões** ficam à parte.
- **Limite de trabalho em andamento: 2 histórias.** Terminar antes de começar outra.
- Um card é **uma história** (Cap. 3 do livro), com os critérios de aceitação na descrição.
- O Trello é uma vista deste vault; em divergência, vale o vault ([[Quadro do Trello]]).

## Peso das histórias (tag no título do card)

Todo card de história leva `[Peso N]` no título. **Peso = critérios de aceitação + endpoints + telas + tabelas** da feature (a mesma régua da seção 8 do [[Roadmap]]). É uma régua para comparar tamanho, não horas. Se uma história passar de 19, vale dividi-la por comportamento.

| Feature | Peso | Feature | Peso | Feature | Peso |
|---|---|---|---|---|---|
| 000 | 33 | 007 | 15 | 013 | 13 |
| 001 | 14 | 008 | 11 | 014 | 9 |
| 002 | 13 | 009 | 13 | 015 | 11 |
| 003 | 14 | 010 | 19 | 016 | 12 |
| 004 | 14 | 011 | 9 | 017 | 12 |
| 005 | 11 | 012 | 11 | 018 | 9 |
| 006 | 16 | 019 | 8 | 020 | 6 |

Calculado em 2026-11-10 dos arquivos de `features/`. A soma por fase bate com o Roadmap em F3, F4, F5, F7, F8 e F9; difere em F1 e F2 (63 contra 46) e em F6 (33 contra 31), por critério de contagem das tabelas da 000. O Roadmap não foi alterado. O Trello não cria etiquetas pelo MCP, por isso o peso vai no título.
