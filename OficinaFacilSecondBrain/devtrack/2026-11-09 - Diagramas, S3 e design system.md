# 2026-11-09 — Diagramas, S3 e design system

## O que foi feito

- Pedido do usuário: seguir o livro *Engenharia de Software Moderna* (Marco Túlio Valente) e pôr um diagrama em Mermaid antes de cada feature, mostrando o que já foi feito e o impacto real no sistema.
- Base no capítulo 4 do livro (consultado em engsoftmoderna.info): diagramas como esboço leve para comunicar o design antes de codar; classes e pacotes (estrutura), sequência e atividades (comportamento). Casos de uso ficam no capítulo 3 e já existiam em [[Casos de uso]].
- As 21 features (000 a 020) ganharam a seção **Diagrama** logo antes de **Referências**: diagrama de sequência (000 e 020 usam fluxograma) e o bloco **Impacto no sistema** (o que escreve, qual estado muda, o que destrava, o que protege).
- Os 21 diagramas foram validados com o parser do Mermaid (dois falharam por `;` na mensagem e foram corrigidos).
- Nada novo foi inventado (R3): rota, tabela, estado e regra vêm de [[Casos de uso]], [[Modelo de dados]] e [[Endpoints]]; fluxos deduzidos seguem com ⚠️.

## Arquivos

`features/000` a `features/020` (seção nova). Nenhum código alterado.

## Pendências

- O gerador `metodos/gerar-vault.py` não conhece a seção **Diagrama**: regenerar as features com `--force` apagaria os diagramas. Ensinar o gerador antes de qualquer regeneração.
- Regerar os PDFs de `entregas/` antes da próxima entrega ao professor (R6); as features não entram nos PDFs atuais, então nada a regerar por ora.
- Não houve commit (R8: fora de fase ou feature concluída).


## Depois dos diagramas (mesma sessão)

- **S3 construída por um agente** (features [[002 - Gerir clientes]] e [[003 - Gerir veículos]]): módulos `clientes` e `veiculos` no backend, validadores de CPF, CNPJ e placa, log sem a query string, telas T05 a T07 no app. Verificado por mim: backend 179 testes passando e 31 de integração ignorados; app com analyze limpo. Provas com o banco real (CA02 e CA05 das duas features) continuam 🔄.
- **Design system** "OficinaFácil" (artifact) e canvas "Telas OficinaFácil" com as 26 telas (27 desenhos).
- **Decisão [[013 - Design system da interface]]:** o usuário subverteu a R26 no chat para esta mudança. O `CLAUDE.md` não foi alterado.
- **Rebranding das 10 telas existentes** por um agente: tema à mão sem `fromSeed`, só tema claro, barra global preta, sub-barra, barra de abas, tile escuro, pílulas, 11 widgets novos. Verificado por mim: format e analyze limpos, 343 testes, nenhuma cor solta fora do tema. Só a tela de login foi vista renderizada.
- **Gerador da página navegável** `metodos/gerar-diagramas.py` (ver [[Gerar notas e PDFs]]), publicada como artifact "Diagramas e andamento".
- **Supabase de desenvolvimento inacessível:** o endereço do projeto não resolve no DNS e a API local responde `banco: indisponivel`. Pode ser projeto pausado por inatividade. Nenhum comando foi rodado contra o banco.

## Pendências

- Restaurar o projeto Supabase e só então: provar a 001 no app com a conta do seed, rodar a integração e o `smoke.sh` da S3, fechar a F2 e a F3.
- Decidir as três coisas que o agente da S3 deixou em aberto (R3): rota `/clientes/:id/veiculos/:veiculoId` ausente do Mapa de telas, transferência de veículo com OS ativa, ausência de endpoint para reativar cliente e veículo.
- Textos do vault que descrevem o visual antigo (botão de voltar, ícones em botões).
- A R26 do `CLAUDE.md` continua com o texto antigo, até o usuário pedir para reescrever.
- Regerar os PDFs de `entregas/` antes da próxima entrega ao professor (R6).
- Nada foi commitado nem enviado ao GitHub.


## Retomada em 2026-11-10

- **Supabase restaurado.** O projeto estava pausado e voltou com os dados (18 tabelas, 1 usuário no Auth, catálogo fictício). Estado conferido antes de rodar qualquer teste (R19): 1 perfil, nenhum cliente, veículo ou OS.
- **Integração da S3 provada com o banco real:** 210 testes do backend passaram, 31 de integração entre eles (variáveis `TEST_*` mapeadas só no processo, sem arquivo). Sem resíduo no banco; o gerente do seed continua ativo. CA02 e CA05 das features 002 e 003 passaram a ✅.
- **`smoke.sh`:** 12 de 12, com a sondagem de RLS. Login do gerente do seed pela API e `GET /me` com perfil `GERENTE`: ok.
- **Refatoração do app:** o agente foi interrompido pelo limite de uso no meio; o código parcial formata, passa no analyze e tem 347 testes verdes. Falta terminar os passos 2 e 3 do plano.
- **Refatoração do backend** (unicidade compartilhada, `paginaSchema`, legibilidade): feita e verificada, OpenAPI idêntico.

## Fechamento da F2 e da F3 (2026-11-10)

- **Banco:** o direto (`db.<projeto>.supabase.co`, só IPv6) travava a API. `DATABASE_URL` no `backend/.env` passou para o **pooler IPv4** (`aws-1-sa-east-1`, modo sessão); `DIRECT_URL` segue direta, só para migrations. O painel do Supabase mostra o projeto Healthy.
- **001 provada no app web real** com a conta do seed, dirigindo o navegador (6 de 6): sem sessão cai no login, senha errada mostra a mensagem genérica, o gerente entra e vê o menu, a sessão sobrevive ao recarregar e Sair volta ao login. CA01, CA02 e CA03 passaram a ✅.
- **Defeito achado e corrigido no CA03:** com o token expirado, o app renovava (200) mas o primeiro `GET /me` saía com o token velho, recebia 401 e deslogava o usuário. Correção em `core/network/token_da_sessao.dart` (renova antes de anexar o token), com 4 testes. Provado depois no app real: expirado renova e continua logado; refresh inválido volta ao login.
- **Verificação final:** backend lint, format e typecheck limpos, 210 testes (31 de integração) e `smoke.sh` 12 de 12; app format e analyze limpos, 351 testes, `flutter build web` e `flutter build apk --debug` passando. Sem resíduo no banco.
- **Fases F2 (001 e 006) e F3 (002 e 003) marcadas no CHECKLIST.** Roadmap corrigido (não há projeto de teste).
- **Armadilhas novas:** o build web agora precisa de `--no-web-resources-cdn` onde não há acesso ao CDN do Google; os rebuilds recriam `build/web`, então o servidor estático precisa ser reiniciado; `pgrep -f` com o texto no próprio comando mata o shell (matar sempre pela porta).

## Apresentações e arquivo de artefatos (2026-11-10)

- **Dois conjuntos de slides** (Slides do Claude): semana 1 e semana 2 (8 slides, linha do tempo e onde estamos) e funcionalidades e o livro (7 slides, diagramas lado a lado, cada elemento justificado por um capítulo de *Engenharia de Software Moderna*). Falas para Elto, Evillyn, Roberto e Pedro, nas notas de cada slide.
- **Diagramas de classes redesenhados na horizontal** (`direction LR`) para ficarem legíveis ao lado da sequência; imagens cortadas no conteúdo.
- **Roadmap:** seção com o peso das funcionalidades por fase (total 254, 73 concluídos) justificando o calendário.
- **Pasta `artefatos/` no vault** com a cópia de trabalho do design das telas (26 telas), do design system, dos dois decks e dos diagramas, mais [[00 - Índice de artefatos]] e [[Linha do tempo de slides]]. A [[Convenções]] ganhou a linha correspondente.
- Pendências: o índice gerado (`00 - Índice`) ainda não lista `artefatos/`; ao próximo `--dry-run` do gerador, decidir se entra. Roadmap, Convenções, Quadro do Trello e `artefatos/` ainda não estão commitados.
