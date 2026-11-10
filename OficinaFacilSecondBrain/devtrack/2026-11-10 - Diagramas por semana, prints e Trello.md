---
data: 2026-11-10
---

# 2026-11-10 — Diagramas por semana, prints reais, README e Trello

Continuação de [[2026-11-10 - Slides, artefatos, deploy no Render e APK]].

## Feito

- **Prints reais das telas.** O app web foi compilado com URLs fictícias (arquivo de configuração temporário, `mobile/env.json` intacto) e dirigido pelo Chrome, com a API e o login simulados no navegador e dados fictícios. Nenhuma chamada ao banco nem ao Supabase. Saíram 11 prints (login, início, usuários, clientes e veículos). Clientes e veículos só abrem com o perfil de atendente (RN09).
- **Diagramas por semana no vault**, em Mermaid, cada um com a explicação logo abaixo: `diagramas/S1` (pacotes do backend, implementação), `S2` (pacotes e classes do app) e `S3` (pacotes e classes). Índice em [[00 - Índice de diagramas]]. Os de sequência continuam dentro de cada feature. Diagrama de implementação é novo (decisão do usuário: pode).
- **Deck novo** "telas e diagramas por semana" (8 slides: capa, S1, S2 com três, S3 com três), tela real ao lado do diagrama e explicação curta. Fonte em `artefatos/slides/telas-e-diagramas-por-semana/`; link no [[00 - Índice de artefatos]]. Não revisei os slides visualmente.
- **README** atualizado: estado (F1 a F3), selos, fluxo de trabalho, Claude no projeto, equipe, testes (351 e 179 mais 31 de integração).
- **Trello:** card "Como ler" reescrito de forma simples; criados os cards 002 e 003 (faltavam) em Concluído; card das decisões corrigido.
- Referência: estrutura de documentação do repositório ToolRent (pasta de diagramas por sprint, glossário, DoD e DoR, ADRs). Só adotei `diagramas/` por semana.

## Scrum e quadro reformulado (fim da sessão)

- Decisão [[015 - Scrum e Kanban no projeto]] (proposta) e nota [[Scrum e Kanban no projeto]] em `agil/`: artefatos, eventos, DoR, DoD, limite de 2 em andamento e a regra de peso.
- Trello: colunas Product Backlog, Sprint Backlog (S4), Em andamento (máx. 2), Impedimentos e Concluído; 004 e 005 no Sprint Backlog; todos os 15 cards do backlog reescritos como história (Como… quero… para…) com critérios e `[Peso N]` no título; cards concluídos com peso também.
- Limites: o MCP não cria etiquetas (o peso foi para o título); os itens da lista "Tarefas" continuam com texto técnico; os cards antigos de documentação em Concluído não têm peso.
- README reformulado com links e glossário.

## Pendências

- **Trello:** o MCP não muda a visibilidade; o usuário precisa deixar o quadro público pelo menu do quadro e renomeá-lo ("Kanban Quadro Modelo"). Depois, acrescentar o link no README. Os itens das listas "Tarefas" ainda têm texto técnico longo (144 itens); a pasta "Em andamento" está vazia, o que é esperado entre features.
- Glossário, DoD e DoR (inspirados no ToolRent) **não** foram criados: são regras novas e dependem de aprovação (R3).
- Commit do README, de `diagramas/`, dos artefatos e deste devtrack (R8: o usuário não pediu).
- Regerar `entregas/` antes da próxima entrega ao professor (R6).
