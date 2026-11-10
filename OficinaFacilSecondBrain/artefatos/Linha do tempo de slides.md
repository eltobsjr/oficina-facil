---
data: 2026-11-10
---

# Linha do tempo de slides

Cada apresentação do projeto, em ordem cronológica, com a sequência de slides, quem fala e onde está a fonte. Acrescentar uma linha por apresentação nova. Mapa geral dos artefatos em [[00 - Índice de artefatos]].

Equipe que apresenta: Elto, Evillyn, Roberto e Pedro.

| # | Data | Apresentação | Link | Fonte |
|---|---|---|---|---|
| 1 | 2026-11-10 | Semana 1 e semana 2 | https://claude.ai/artifact/Ktxh4bk6rxeJggvM1bpdnw | `artefatos/slides/semana-1-e-2/` |
| 2 | 2026-11-10 | Funcionalidades e o livro | https://claude.ai/artifact/5jb6B33UDoHsTpXGG7SAhw | `artefatos/slides/funcionalidades-e-o-livro/` |

## 1. Semana 1 e semana 2 (8 slides)

Objetivo: o que foi feito na semana passada e nesta, a linha do tempo de 15 semanas e onde estamos. A justificativa das fases pelo peso das funcionalidades está no [[Roadmap]].

| Slide | Conteúdo | Fala |
|---|---|---|
| `cover` | Abertura | Elto |
| `tempo` | Linha do tempo e onde estamos, com o peso de cada fase | Elto |
| `semana-passada` | Base técnica e login (F0 e F1) | Evillyn |
| `es-feito` | Fase 3 e a prova da fase 2 no app real | Roberto |
| `es-numeros` | Antes e depois em números, Kanban atualizado | Evillyn |
| `es-design` | Design system e código testado | Pedro |
| `roadmap` | Por que as próximas fases vêm nesta ordem | Roberto |
| `fim` | Próximos passos e perguntas | Pedro |

## 2. Funcionalidades e o livro (7 slides)

Objetivo: para cada funcionalidade pronta, os diagramas lado a lado e o capítulo de *Engenharia de Software Moderna* (Marco Túlio Valente) que justifica cada elemento. Os diagramas de origem estão nas seções Diagrama de cada nota em `features/`.

| Slide | Conteúdo | Capítulos do livro | Fala |
|---|---|---|---|
| `cover` | Abertura | | Elto |
| `mapa` | Do livro ao projeto | 3, 4.3 a 4.6, 5, 7, 8, 9 | Elto |
| `f000` | Fundação: pacotes e arquitetura em camadas | 4.4, 7, 5, 10 | Evillyn |
| `f001` | Login e perfil: sequência e atividades | 4.5, 4.6, 3, 8 | Roberto |
| `f006` | Gestão de usuários: sequência e classes | 4.5, 4.3, 5, 7 | Pedro |
| `f002` | Clientes: sequência e classes | 4.5, 4.3, 7, 8 | Evillyn |
| `f003` | Veículos: sequência e classes | 4.5, 4.3 | Roberto |

Seções do livro só são citadas onde o capítulo foi lido por inteiro; nos demais casos vale o capítulo. A tabela cobre as funcionalidades concluídas até a F3; as próximas entram aqui quando fecharem ([[CHECKLIST]]).

## 3. Apresentação ao professor (20 slides, 2026-11-10)

Deck único que substitui os dois anteriores para apresentar: https://claude.ai/artifact/UsDXKHoeGbjtHZzrzDvjdH, fonte em `artefatos/slides/telas-e-diagramas-por-semana/`, roteiro em `Roteiro da apresentação.md` (gerado das notas dos slides).

| Slides | Conteúdo | Fala |
|---|---|---|
| 1 a 4 | Capa, o projeto, linha do tempo, Scrum e Kanban | Elto |
| 5 e 6 | Arquitetura e telas reais | Evillyn |
| 7 | Design e código | Pedro |
| 8 a 18 | Diagramas por semana ([[00 - Índice de diagramas]]): pacotes, sequência com a tela real em miniatura, atividades e classes | Roberto |
| 19 e 20 | Ordem das próximas fases e próximos passos | Elto |

Diagramas de sequência no padrão dos slides: até 6 participantes, um cenário por diagrama, faixas por camada (azul app, âmbar backend, verde Supabase), linhas de vida tracejadas e texto com auréola branca. PDFs do deck e do roteiro em `~/Downloads/OficinaFácil/` (fora do repositório).

