---
data: 2026-11-10
---

# Fundamentação no livro *Engenharia de Software Moderna*

Para cada elemento do projeto, o capítulo do livro (Marco Túlio Valente) que o justifica. Os slides usam este mapa ([[Linha do tempo de slides]]). Só se cita seção onde o capítulo foi lido por inteiro; nos demais, vale o capítulo.

| Elemento do projeto | Onde vive | No livro |
|---|---|---|
| Requisitos, casos de uso e critérios de aceitação testáveis | [[Requisitos]], [[Casos de uso]], `features/` | Cap. 3 |
| Diagrama de classes (serviço, repositório e domínio) | Seção Diagrama de cada nota em `features/` | Cap. 4.3 |
| Diagrama de pacotes (módulos do backend) | [[Diagramas]] e `features/000` | Cap. 4.4 |
| Diagrama de sequência (uma por funcionalidade) | `features/` | Cap. 4.5 |
| Diagrama de atividades (fluxo de sessão do login) | `features/001` | Cap. 4.6 |
| Módulo só se abre pelo `index.ts` (ocultamento de informação); coesão e baixo acoplamento | `backend/src/modules`, teste de arquitetura | Cap. 5, seções 5.3 a 5.5 |
| Serviço depende de interfaces (`RepositorioPerfis`, `AdminAuth`), uma razão para mudar por classe | `backend/src/modules/usuarios` | Cap. 5 (princípios de projeto) |
| Arquitetura em camadas (app, API, Supabase; rotas, serviço e repositório) | [[Arquitetura]] | Cap. 7 |
| Testes automáticos e prova de ponta a ponta no app e no banco reais | `backend/test`, `mobile/test`, `smoke.sh` | Cap. 8 |
| Refatoração (listas paginadas, formulários, unicidade compartilhada) | [[2026-11-09 - Diagramas, S3 e design system]] | Cap. 9 |
| Integração contínua, monorepo, container | `backend/Dockerfile`, [[012 - Estrutura do repositório]], [[014 - Hospedagem da API no Render]] | Cap. 10 |

O diagrama de cada funcionalidade nasce **antes** do código (decisão registrada em [[011 - Diagramas em Mermaid e UML formal]], ainda aberta quanto ao rigor da UML).
