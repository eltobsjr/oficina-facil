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

## Apresentação consolidada

- Os decks foram reunidos numa **apresentação única ao professor** (17 slides), só com o relevante: projeto, plano, processo (Scrum e Kanban), arquitetura, telas reais, design e código, os diagramas por semana e próximos passos. Saíram o defeito do token, notas de revisor, pendências internas e segredos.
- Falas: Elto 4 slides, Evillyn 2, Pedro 3, Roberto 8 (**só diagramas**, a pedido do usuário). Roteiro completo em `artefatos/slides/telas-e-diagramas-por-semana/Roteiro da apresentação.md`, gerado das notas. Os dois decks antigos ficam arquivados.

## Diagramas refeitos no modelo do ToolRent

- O usuário achou os diagramas dos slides confusos (sequências do esboço das features, com as caixas repetidas no topo e no rodapé). Refiz **todos** no modelo do repositório de referência: cada arquivo tem notação, legenda, explicação e "o que não aparece". Tipos do livro (cap. 4): pacotes, classes, sequência e atividades. Participantes das sequências são objetos reais do código; `mirrorActors` desligado.
- O diagrama de implementação foi **retirado** (fora do conjunto do livro); a fronteira de rede está no diagrama de pacotes do sistema (S1).
- Novos: S2 atividades do login, sequências de login, usuários, clientes e veículos; classes de domínio com atributos e multiplicidade. Deck passou a 20 slides (Roberto: 11, só diagramas). PDFs de `~/Downloads/OficinaFácil` substituídos.

## Sequências legíveis

- Crítica do usuário: os diagramas de sequência ficavam pequenos e confusos. Problemas: até 7 participantes, 21 passos com dois cenários, linhas de vida riscando o texto, tudo no mesmo azul. Refeitos com até 6 participantes, um cenário cada, faixas `box` por camada, linhas tracejadas claras, auréola branca no texto e passos numerados; nos slides, o print virou miniatura no título e o diagrama ocupa a largura (texto de 22 a 26 px em tela cheia).
- A sequência de usuários passou a mostrar só criar; inativar ficou descrito no texto.
- Commit e push a pedido do usuário ("commita pusha documenta").

## Clareza dos slides e Trello público

- A Evillyn achou estranhas frases da parte dela ("só mostra e ajuda: nunca é a única barreira"). Revisei o texto de todos os slides e troquei jargão por português direto: arquitetura, telas, linha do tempo, processo, design, pacotes, ordem das fases e próximos passos ("máquina de estados", "contratos", "porta index.ts" e "73 de 254 de peso"). Roteiro e PDFs regenerados.
- O quadro do Trello ficou público (confirmado pelo MCP).

## Pendências

- **Trello:** o MCP não muda a visibilidade; o usuário precisa deixar o quadro público pelo menu do quadro e renomeá-lo ("Kanban Quadro Modelo"). Depois, acrescentar o link no README. Os itens das listas "Tarefas" ainda têm texto técnico longo (144 itens); a pasta "Em andamento" está vazia, o que é esperado entre features.
- Glossário, DoD e DoR (inspirados no ToolRent) **não** foram criados: são regras novas e dependem de aprovação (R3).
- Regerar `entregas/` antes da próxima entrega ao professor (R6).
- Aplicar o mesmo tratamento visual aos diagramas de pacotes e de classes, se o usuário quiser.
- Atualizar `trello-quadro.json` e `gerar-trello.py` para a estrutura Scrum do quadro.
- Papéis de Product Owner e Scrum Master (decisão 015).
