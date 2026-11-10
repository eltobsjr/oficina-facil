---
data: 2026-11-10
---

# Artefatos do projeto

Os artefatos publicados no Claude (design das telas, design system, páginas e slides) têm aqui a **cópia de trabalho** versionada com o código. O link publicado é a vitrine; **esta pasta é a fonte**: quando algo mudar, edita-se aqui e republica-se no mesmo link. Os slides em ordem cronológica estão em [[Linha do tempo de slides]].

Os links são privados (só o dono abre; compartilhar é pelo menu Share do artefato).

## Mapa

| Artefato | Link | Fonte neste vault | Atualizar quando |
|---|---|---|---|
| Design das telas (canvas com T01 a T26) | https://claude.ai/artifact/Rex4DaKEukimei8rmLSfLR | `artefatos/design/telas/` | Mudar o [[Mapa de telas]] ou o design system |
| Design system OficinaFácil | https://claude.ai/artifact/5eHASyyNSZeUqBQpSApv5X | `artefatos/design/design-system/` | Mudar token, componente ou regra visual ([[013 - Design system da interface]]) |
| Diagramas e andamento (página navegável) | https://claude.ai/artifact/RXcjyfraEcBajjTH29EXRw | gerada por `metodos/gerar-diagramas.py` | A cada feature ou fase fechada |
| Identidade visual (logo e cor da marca) | https://claude.ai/artifact/3CYpv85NYJk2pAgktuJzjk | [[00 - Identidade visual]] | Mudar o logo ou a cor da marca |
| Slides: semana 1 e semana 2 | https://claude.ai/artifact/Ktxh4bk6rxeJggvM1bpdnw | `artefatos/slides/semana-1-e-2/` | Retrato de 2026-11-10; só muda se o plano mudar, e então regerar o roteiro |
| Slides: funcionalidades e o livro | https://claude.ai/artifact/5jb6B33UDoHsTpXGG7SAhw | `artefatos/slides/funcionalidades-e-o-livro/` | Ao fechar cada feature, acrescentar o slide dela |
| **Apresentação ao professor** (17 slides: projeto, plano, processo, arquitetura, telas e diagramas por semana) | https://claude.ai/artifact/UsDXKHoeGbjtHZzrzDvjdH | `artefatos/slides/telas-e-diagramas-por-semana/`; roteiro em `Roteiro da apresentação.md` (gerado das notas) | Ao fechar cada semana: nova pasta em `diagramas/`, novos prints e um slide. Substitui os dois decks abaixo para apresentar |

## Material de apresentação

- Roteiro de fala do deck principal: `artefatos/slides/semana-1-e-2/Roteiro de fala.md`, gerado das notas dos slides (não editar à mão; editar a nota do slide e regerar). Cada pessoa fala em dois slides: Elto, Evillyn, Roberto e Pedro.
- PDFs para enviar ao grupo: gerados dos slides e do roteiro, sem versão no repositório (ver [[Rodar o projeto]], seção Gerar os PDFs dos slides). Em 2026-11-10 foram para `~/Downloads` do usuário.
- Fundamentação de cada diagrama no livro: [[Fundamentação no livro de Engenharia de Software]].

## Como editar e republicar

- **Slides:** editar `project/slides/<id>.html` (e `project/deck.json` se mudar a ordem) e publicar no mesmo link, com `root` apontando para a pasta do deck. Cada slide é um `<section>` de 1920×1080 com estilo em linha; as notas de fala ficam no `<aside>` do próprio slide. As imagens dos diagramas já estão enviadas ao artefato (`/_blob/...`); a cópia em `diagramas/` serve para reenviar se for preciso.
- **Design das telas:** cada tela é um `T**.dc.html` com `oficina.css`; o arranjo do canvas está em `canvas.json`. O arquivo `support.js` citado nas telas é do tempo de execução do artefato e não é versionado.
- **Design system:** `tokens.json` e `README.md` são a fonte das cores e regras; `components/*` têm guia e prévia. O app em código tem o espelho em `mobile/lib/core/theme/app_theme.dart` e `mobile/lib/core/widgets/`.
- **Página de diagramas:** não se edita à mão: `python3 OficinaFacilSecondBrain/metodos/gerar-diagramas.py SAIDA.html` e republicar ([[Gerar notas e PDFs]]).

## Regras que valem aqui

- Só dado fictício e nenhum segredo: o repositório é público (R30). Os nomes nas telas e nos slides são de exemplo ou os primeiros nomes da equipe.
- Fonte única (R2): texto de requisito, regra ou critério **não se copia** para os artefatos como verdade; eles apontam para as notas do vault, e os números vêm da página gerada.
- Os artefatos não substituem as entregas ao professor: essas são PDFs em `entregas/` (R6).
- A cor da marca no logo é `#1F4E79`; a interface usa o design system ([[013 - Design system da interface]], exceção à R26 pedida pelo usuário).
