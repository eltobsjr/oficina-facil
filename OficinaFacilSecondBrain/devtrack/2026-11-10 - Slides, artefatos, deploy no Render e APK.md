---
data: 2026-11-10
---

# 2026-11-10 — Slides, artefatos, deploy no Render e APK

Continuação de [[2026-11-09 - Diagramas, S3 e design system]] (que cobre diagramas por funcionalidade, S3, design system, refatorações, fechamento da F2 e F3 e o defeito do token vencido). Este registro cobre o que veio depois, no mesmo dia.

## Feito

- **Slides, deck 1 "semana 1 e semana 2"** (8 slides): reduzido de 16 para 8 a pedido, com linha do tempo e onde estamos. Depois reescrito para apresentar a um professor: sem defeitos nem pendências internas (saíram o token vencido, as notas do revisor e a menção às senhas), com mais texto por slide e roteiro completo nas notas. Falas redistribuídas: **cada pessoa em dois slides** (Elto: capa e linha do tempo; Evillyn: semana passada e números; Roberto: esta semana e ordem das fases; Pedro: design e código, e próximos passos).
- **Linha do tempo justificada pelo peso das funcionalidades** (peso = CAs + endpoints + telas + tabelas): tabela no [[Roadmap]], seção 8 (total 254, 73 feitos).
- **Slides, deck 2 "funcionalidades e o livro"** (7 slides): funcionalidades 000, 001, 006, 002 e 003 com os diagramas lado a lado e o capítulo do livro que justifica cada elemento. Diagramas de classes refeitos na horizontal (`direction LR`) e imagens cortadas no conteúdo. Mapa em [[Fundamentação no livro de Engenharia de Software]]. Falas: Elto 2, Evillyn 2, Roberto 2, Pedro 1.
- **Arquivo de artefatos** em `artefatos/`: telas (26), design system, os dois decks e os diagramas, mais [[00 - Índice de artefatos]], [[Linha do tempo de slides]] e o roteiro de fala. A linha foi acrescentada à [[Convenções]].
- **Deploy da API no Render** pelo usuário, com a minha orientação: https://oficina-facil.onrender.com. Conferido: `/health` com `banco: ok` e `/api/v1/me` sem token com 401. Decisão [[014 - Hospedagem da API no Render]] (Root Directory `backend/` resolve o monorepo); [[Arquitetura]], CHECKLIST, CA04 da feature 020 e [[Rodar o projeto]] atualizados.
- **APK de debug** compilado com `API_URL` da API publicada, por arquivo temporário (o `mobile/env.json` não foi alterado); confirmado dentro do APK que aponta para a URL do Render. Entregue em `~/Downloads/oficina-facil.apk` (187 MB); não instalado em aparelho por mim.
- **PDFs** dos dois decks e do roteiro em `~/Downloads` (8, 7 e 4 páginas); conferidas duas páginas visualmente.
- **Git:** commits `57c95da` (R19 no `CLAUDE.md`, edição do usuário), `3be41d9` (artefatos, Roadmap, Convenções) e `064b354` (redistribuição das falas), todos enviados ao `main` a pedido explícito do usuário ("commite e pushe tudo" e "SIM"). Sem linhas de atribuição (R7).

## Incidente de segredos

O usuário colou no chat, ao configurar o Render, a chave `service_role` e a senha do banco, sem mascarar (a senha do banco já tinha sido colada em 2026-10-30). Os valores **não** foram repetidos nem gravados no vault. **Pendente do usuário:** rotacionar a senha do banco e a `service_role` no Supabase, atualizar `backend/.env` e o painel do Render. O APK não precisa ser recompilado.

## Armadilhas

- Gmail bloqueia anexo `.apk` e o limite é 25 MB: enviar por link.
- O plano gratuito do Render dorme: a primeira chamada leva cerca de um minuto.
- A API publicada usa o único projeto Supabase de desenvolvimento (consequência registrada na decisão 014).
- Arquivos de artefato publicados (Slides) pedem `root` e os caminhos `project/...`; as cópias no vault não têm a pasta `project/`.

## Pendências

- Rotacionar segredos (acima).
- As quatro decisões da S3 (R3): rota de edição de veículo no Mapa de telas, transferir veículo com OS ativa, veículo para cliente inativo, reativar cliente e veículo.
- Conferir no app real as telas de usuários, clientes e veículos; testar o APK num Android.
- Commitar e enviar este devtrack e as notas desta documentação (ainda sem commit).
- `00 - Índice` gerado ainda não lista `artefatos/`; decidir no próximo `--dry-run`.
- A R26 do `CLAUDE.md` mantém o texto antigo até o usuário pedir a reescrita.
- Regerar `entregas/` antes da próxima entrega ao professor (R6); exportar o `.pptx` dos slides só se o usuário pedir.
- Próximo: F4 (005, 004, 018).

## Gerente real e barra preta (fim do dia)

- **Troca de gerente:** novo script `backend/prisma/trocar-gerente.ts` (`npm run db:trocar-gerente`), com a conta e a senha só no `backend/.env`. Antes de rodar, o estado do banco foi conferido (1 usuário fictício, nenhum cliente, veículo ou OS, R19). Rodou a pedido do usuário: gerente real criado e usuário antigo apagado; login conferido na API do Render (perfil GERENTE). Senha gerada aleatória, guardada só no `.env`. Procedimento em [[Rodar o projeto]].
- **Pergunta do usuário sobre cadastro:** não há botão de criar conta de propósito (sistema interno; só o gerente cria usuários). Auto-cadastro seria requisito novo e exige aprovação (R3).
- **Barra preta mantida e embelezada** (o usuário pediu para remover, depois voltou atrás): 52 px, símbolo da marca em branco ao lado do nome em negrito e a conta numa pílula translúcida com o menu Sair. O canvas em `artefatos/design/telas/` ainda mostra a barra antiga de 44 px; atualizar o canvas quando for conveniente. Verificação: analyze limpo, 351 testes do app e 179 do backend (31 de integração pulados) passando; APK de debug refeito com a API do Render e entregue em `~/Downloads/oficina-facil.apk`.
- **Conferência do rebranding:** as 10 telas que existem no app (T01, T25, T26, T02, T03, T04, T05, T06, T07, T07b) usam só os componentes do design system; nenhuma usa `AppBar`, botão flutuante, `ListTile` ou `Card` do Material. As outras 16 telas do canvas ainda não existem no app e nascem no visual novo.
- **Pendência:** a barra renderizada ainda não foi vista por mim; olhar no celular.
