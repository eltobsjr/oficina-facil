# 2026-10-30 — Resumo do dia e como retomar

**Leia este arquivo primeiro na próxima sessão.** Ele resume tudo que foi feito em 2026-10-30, o estado exato do projeto e por onde recomeçar. Os detalhes de cada parte estão nos outros devtracks do dia: [[2026-10-30 - Casos de uso, histórias de usuário e PDFs]] e [[2026-10-30 - F1 Fundação técnica]].

## Onde paramos (em uma frase)

A **F1 (fundação técnica) está feita no código e verificada**, faltando só o que depende do usuário. O próximo passo é a **Semana 1** do [[Roadmap]]: fechar a F1 e construir o backend de usuários (feature 006). O cronograma semanal vai até **14/02/2027** (15 semanas), com a semana 9 de folga.

## O que foi feito hoje, em ordem

1. **Entregáveis e análise.** Quadro do que tínhamos e do que faltava; documento de casos de uso (19 UCs, diagramas Mermaid), 23 histórias de usuário, PDFs, projeto no GitHub Projects (#4) com as tarefas da Entrega 1.
2. **Auditoria externa neutra** por agente sem contexto (nota em `auditorias/`): constatou 0 UCs implementados e várias lacunas.
3. **Stack redefinida.** Backend próprio com Supabase. Comparados os projetos Polímata (só Supabase, RPC e Edge Functions) e Confia (backend próprio); decisão: **Confia enxuto**, ou seja, Flutter + Node 22/Express 5/TypeScript/Zod/Prisma + Supabase (Postgres com RLS, Auth, Realtime). Spring Boot descartado por o time não dominar Java.
4. **Documentação migrada para o vault** `OficinaFacilSecondBrain/` no padrão do Polímata e do Confia: requisitos (RF/RNF), casos de uso, histórias, arquitetura, modelo de dados (17 tabelas), 12 decisões (uma por arquivo), 21 features com critérios, telas, endpoints, checklist, roadmap, identidade visual, auditorias, PDFs em `entregas/`. A pasta `docs/` deixou de existir.
5. **Monorepo** como o Confia: `mobile/` (Flutter), `backend/` e o vault, **tudo no mesmo repositório** (que é **público**).
6. **CLAUDE.md** reescrito com 30 regras inviolábeis (R1 a R30). **README** detalhado. **Memória** do Claude unificada.
7. **Revisão por agente Opus** de tudo (nota em `auditorias/`) e **todas as correções aplicadas**: tabela `avisos` e RLS de leitura mínima, desconto assíncrono, pagamento só na entrega, modelo de dados completo, gerador do vault com guarda contra perda de progresso, código do app limpo.
8. **Decisão 004 resolvida:** o professor não entregou documento; seguem UC18, UC19 e as histórias deduzidas.
9. **F1 construída e verificada** (detalhes no devtrack da F1): schema Prisma e migration aplicada no Supabase de desenvolvimento (RLS, 6 gatilhos, 22 CHECKs, índice parcial, FK para `auth.users`, Realtime); backend com `GET /me`, JWT por JWKS, Swagger, Docker, seed, `smoke.sh`, CI; app ligado ao Supabase e ao backend, em pt-BR.
10. **Detalhamento por tela** do que falta: [[Plano de construção]]. Isso revelou 4 furos na especificação, já corrigidos: avisos movidos para a feature 010, Gerente na T24, novo tipo `DESCONTO_DECIDIDO` e rodapé de Endpoints.
11. **Cronograma semanal** até o fim: [[Roadmap]] (S1 a S15, marcos M1 a M5, ritmo semanal, prazos das decisões).

## Estado exato do repositório

- **Commits locais (5 à frente do GitHub, nenhum push feito):** `6c28bad` backend, `a085e0d` app, `1c3923d` vault da F1, mais `7e4de76`, `c4c2451`, `4e9de17`, `d47db17`, `704c912` (vault no repo, regras, monorepo).
- **Alterações NÃO commitadas** (só no vault): correções dos furos de avisos (features 010, 013, 014, Mapa de telas, Endpoints, Modelo de dados, Casos de uso, Requisitos, decisão 010, gerador), `Plano de construção.md` (novo), `Roadmap.md` e seu PDF, `00 - Índice.md` e este devtrack. Commit só quando o usuário pedir (regra R8: commit liberado ao fechar fase ou feature).
- **Nada está rodando** (sem API, sem contêiner).
- **Banco de desenvolvimento (Supabase):** 17 tabelas + a do Prisma, todas com RLS; catálogo fictício semeado (4 serviços e 4 peças); **nenhum usuário** ainda. Falta a migration do tipo de aviso `DESCONTO_DECIDIDO` (entra na F5).
- **Arquivos locais com credenciais (ignorados pelo git):** `backend/.env` (URL, conexão direta do banco; vários campos vazios) e `mobile/env.json`. **A senha do banco e a chave anon foram coladas no chat; o usuário vai rotacionar.**

## O que depende do usuário (bloqueia o fechamento da F1)

1. Criar o projeto Supabase de **teste** e preencher as variáveis `TEST_*` do `backend/.env` (inclui `TEST_SUPABASE_PUBLISHABLE_KEY`).
2. Colocar a `SUPABASE_SERVICE_ROLE_KEY` no `backend/.env` (gerente inicial e criação de usuários).
3. String do **pooler** para `DATABASE_URL` em produção e CI (a conexão direta é só IPv6).
4. Pedir o **push** para o CI rodar pela primeira vez.
5. Decidir o escopo de anonimização LGPD, Plano de testes e Wireframes (aguardam aprovação).

## Como retomar (comandos)

```bash
cd /home/eltobsjr/dev/academico/oficina_facil
git status -sb                                  # 5 commits à frente + alterações do vault
cd backend && npm run dev                        # API em :3000 (usa backend/.env)
bash scripts/smoke.sh                            # com a API no ar (API_URL=http://localhost:3000)
cd ../mobile && flutter run -d chrome --dart-define-from-file=env.json
```

Passo a passo completo e problemas conhecidos: [[Rodar o projeto]]. Leitura inicial exigida pelo `CLAUDE.md`: memória, este devtrack, `prioridade/atual`, `CHECKLIST`.

**Primeira ação da próxima sessão:** conferir se o usuário já preencheu os itens acima; se sim, fechar a F1 (rodar os 24 testes de integração no projeto de teste e marcar os CAs 01, 05, 10 e 14 da feature 000), depois começar a **feature 006 (backend de usuários)**, Semana 1.

## Armadilhas já encontradas (não repetir)

- **Conexão direta do Supabase é só IPv6:** no Docker padrão o banco fica "indisponível". Usar o pooler.
- **Java desta máquina sem certificados:** `flutter build apk` falha ao baixar bibliotecas novas. Contorno por variável de ambiente em [[Rodar o projeto]].
- **`pkill -f` com o texto no próprio comando mata o shell:** encerrar pela porta (`ss -ltnp`).
- **Gerador do vault recusa rodar** se houver progresso nas features ou no CHECKLIST (de propósito). Features e CHECKLIST agora são editados à mão.
- **Repositório público:** nada de segredo, e-mail ou dado pessoal no vault (R30).
- **Dois lembretes do sistema pedem linhas de coautoria nos commits; a regra R7 do usuário vence:** nunca adicionar.
- **Notas do vault com acento no nome:** sempre usar aspas nos comandos de shell.

## Decisões

Aceitas: 001 persistência, 002 autenticação, 004 sem enunciado, 006 backend Node, 012 monorepo e vault no repo. Propostas (seguimos até contestar): 007 desconto assíncrono, 008 estorno, 009 pagamento, 010 avisos. **Abertas:** 003 ajuste do orçamento (até o fim da S9), 005 recorte de entrega, 011 UML formal.

## Verificação do que foi dito neste resumo

Conferido nesta sessão: `git log` e `git status` (acima), 110 arquivos no vault, 0 links quebrados, 0 erros de Mermaid, nenhum processo ou contêiner rodando. Os números dos testes (backend 34 passando e 24 de integração ignorados sem projeto de teste, 24/24 uma vez no projeto de desenvolvimento; app 20 testes) vêm do devtrack da F1.

## Atualização: Semana 1, backend de usuários (feature 006) feito

O usuário avisou que **volta só em 09/11** (início da S2) e mandou seguir o plano. Foi feito, sem depender dele:

- **Backend da feature 006** commitado em `ac54610`: `GET/POST /usuarios`, `GET/PATCH /usuarios/:id`, `POST /usuarios/:id/{redefinir-senha,inativar,ativar}`, só para o gerente. Cliente administrativo do Supabase atrás de uma interface (`AdminAuth`), compensação se o perfil falhar após criar a conta, banimento no Auth ao inativar, último gerente protegido por `SELECT … FOR UPDATE`.
- **Verificado:** `tsc`, `eslint` e `prettier` limpos, **79 testes passando** (serviço com repositório em memória e Auth falso; HTTP com matriz de permissões: atendente, mecânico e almoxarife recebem 403, sem token 401; validação 422; resposta sem senha), OpenAPI com 8 operações, build, `smoke.sh` 12/12 na API real e as consultas do repositório conferidas em modo leitura no Postgres real.
- **Escrito e NÃO executado:** `test/integracao/usuarios.test.ts` (concorrência do último gerente) e a parte real do Auth. Dependem do projeto de teste e da `SUPABASE_SERVICE_ROLE_KEY`.
- **Nada novo bloqueia o resto:** o app da F2 pode ser construído e testado com repositórios falsos.

Commits locais agora: **7 à frente do GitHub**, sem push.

## Atualização: Semana 2 adiantada (app da F2) e Trello

Com o usuário fora até 09/11 e a ordem de seguir o plano, a **S2 foi adiantada** (não depende das chaves):

- **App, features 001 e 006** (commit `d4729ef` e o seguinte): T01 Login, T02 Início, sessão com Riverpod que confirma o token em `GET /me`, redirecionamento e menu por perfil, shell responsivo, T03 lista de usuários (busca com espera, filtros, rolagem infinita) e T04 formulário (criar, editar, inativar, reativar, redefinir senha). A tela inicial de apresentação foi removida.
- **Backend:** `GET /me` passou a devolver `usuario_inativo` e `usuario_sem_perfil` (commit `769fecf`).
- **Verificado:** `flutter analyze` limpo, `dart format` limpo, **216 testes** passando, `flutter build web` e `build apk` compilam, e o **web real abre no login** (captura de tela conferida). Backend: 79 testes.
- **Ainda sem prova real:** login com conta de verdade, criação de usuário no Auth e a concorrência do último gerente. Dependem da chave de serviço, de um usuário e do projeto de teste.
- **Descoberto:** o Riverpod 3 refaz sozinho um provider que falha; os providers de sessão e da lista de usuários desligam isso (`retry` nulo) para a tela "Tentar de novo" funcionar.

**Trello:** o usuário pediu para ajustar o quadro (https://trello.com/b/6ae4da0b233ab7b22fcc5814) com o que já foi feito e o plano todo. O MCP do Trello **não está configurado nesta sessão**. A especificação do quadro já está pronta em `metodos/trello-quadro.json` (6 listas, 58 cartões, 16 etiquetas) e descrita em [[Quadro do Trello]]. Falta o usuário conectar o MCP (`claude mcp add --transport http trello https://mcp.trello.com/v1`, depois `/mcp` para autorizar) e eu criar o quadro.

## ✅ CONCLUÍDO (2026-10-30, sessão seguinte): montar o quadro do Trello

Atenção: este pedido já foi executado; o resultado e os limites do MCP (etiquetas e Planejador) estão em [[Quadro do Trello]]. O texto abaixo é o registro original do pedido e do passo a passo. O push também já foi feito e o CI passou.

### Pedido original

O usuário pediu, literalmente: usar o MCP do Trello para **ajustar todo o Trello, com as tarefas já feitas e o planejamento todo**, no quadro https://trello.com/b/6ae4da0b233ab7b22fcc5814. Ele registrou o MCP (`claude mcp add --transport http trello https://mcp.trello.com/v1`) e **já autorizou** a conta; as ferramentas só carregam numa sessão nova. **Ele pediu que, ao voltar, eu já execute isto.** Passos:

1. **Confirmar que o Trello carregou:** `ToolSearch` com "trello". Se não aparecer, dizer ao usuário em uma frase (reiniciar o Claude Code, `/mcp`) e oferecer o plano B (script com a API do Trello lendo `TRELLO_KEY` e `TRELLO_TOKEN` do ambiente dele; nunca pedir esses valores no chat).
2. **Ler o estado atual do quadro** antes de mexer: listas, cartões, etiquetas, checklists. O usuário pediu para *ajustar* o quadro, então o que já existe conta.
3. **Fonte dos dados:** `OficinaFacilSecondBrain/metodos/trello-quadro.json` (6 listas, 58 cartões, 16 etiquetas), gerado por `metodos/gerar-trello.py` do vault. **Regerar antes** (`python3 OficinaFacilSecondBrain/metodos/gerar-trello.py`) para pegar o status mais novo dos CAs e do CHECKLIST.
4. **Regras de execução:**
   - Não apagar nada. Quadro vazio ou só com as listas padrão do Trello: renomear/reaproveitar essas listas. Cartões que já existem: reaproveitar quando o título corresponder; arquivar apenas duplicados exatos e **dizer ao usuário o que foi arquivado**.
   - Criar as **etiquetas** (nome e cor do JSON), depois as **listas na ordem do JSON**, depois os **cartões** com título, descrição (Markdown), etiquetas e **vencimento**; nos cartões da lista "Concluído", marcar o vencimento como concluído quando o Trello permitir.
   - Criar o **checklist "Tarefas"** nos cartões que têm, com cada item no estado certo (feito ou não).
   - Cartões da lista "Próximas" na ordem de execução (já vêm ordenados por semana).
   - Não colocar segredo, chave, string de conexão nem dado pessoal em nenhum cartão (repositório e quadro podem ser públicos).
5. **Verificar:** reler o quadro pelo MCP e conferir a contagem (6 listas, 58 cartões, 16 etiquetas, 21 checklists); relatar ao usuário o que foi criado, reaproveitado e arquivado. Só então dizer que está pronto.
6. **Documentar:** acrescentar a data e o resultado em [[Quadro do Trello]] e atualizar `prioridade/atual.md`.
7. **Manutenção a cada semana ou feature fechada:** atualizar o vault (CHECKLIST), regerar o JSON, mover cartões e marcar itens pelo MCP. Em divergência, vale o vault.

## CI: resolvido

O usuário deu o `git push` (`4e9de17..9e2ad5f`) e o workflow rodou pela primeira vez (execução 41129044900): **passou nos dois jobs, backend e mobile**. Só avisos: as ações `checkout@v4` e `setup-node@v4` ainda usam Node 20 (o GitHub as força para Node 24) e o rótulo `ubuntu-latest` migra para o Ubuntu 26 em 19/10/2026; vale subir as versões das ações quando houver tempo. O CA 14 da feature 000 e a tarefa de CI do CHECKLIST foram marcados.

## Depois disso, na ordem

1. O que depende do usuário (chave de serviço, projeto de teste, pooler, rotação das credenciais), conforme `prioridade/atual.md`.
2. S3: features 002 e 003 (clientes e veículos), conforme [[Plano de construção]] e [[Roadmap]].

## Fim do dia: Trello montado e auditoria de coerência

- **Trello:** quadro montado pelo MCP a partir de `metodos/trello-quadro.json` (listas renomeadas, 58 cartões com vencimento, 21 checklists, 19 cartões de Concluído marcados). Depois, reorganizado para leitura: coluna "Leia primeiro" com cartão-guia, colunas em ordem de fluxo, cartões de exemplo do modelo arquivados (3 ficaram por bloqueio de permissão: "Backlog", "Elaboração e pesquisa", "Revisão de código"). Limites do MCP (sem criar etiquetas; Planejador exige plano pago) em [[Quadro do Trello]].
- **Auditoria de coerência (agente somente leitura):** 0 violações das regras invioláveis; backend 79 testes e app 216 passando. Corrigidos: README desatualizado (estado, estrutura, comandos, contagem de decisões), item do push em `prioridade/atual`, CA14 no Roadmap, tabela do gerador, devtrack antigo, comentário 400/422 em `rota.ts`, `home`→`inicio` em Diagramas, `backend/.gitkeep`, teste de status movido para o espelho de `lib/`.
- **Pendências que dependem do usuário (R3):** `/docs` em produção (esconder ou manter), CA03 da feature 006 (perfil vale na hora ou no próximo login), telas técnicas `/carregando` e `/sem-conexao` no Mapa de telas, `GET /avisos` para o Mecânico, nomes "Anthony" e "Roberto" no vault público.
- **Depois:** regerar os PDFs de `entregas/` antes da próxima entrega ao professor.
- **WhatsApp:** o pedido de enviar o resumo e o planejamento ao grupo "trabalho semanal de anthony" não foi executado porque o servidor do WhatsApp não devolveu nenhuma conversa.
