---
data: 2026-10-30
---

# Prioridades atuais

Editada à mão a cada sessão. Estado em [[CHECKLIST]]. Resumo do que já foi feito e como retomar: [[2026-10-30 - ZZ Resumo do dia e como retomar]].

## Atualização de 2026-11-10 (leia primeiro)

Detalhes em [[2026-11-09 - Diagramas, S3 e design system]]. **F1, F2 e F3 concluídas.** 001 provada no app real (inclui a correção da renovação do token); S3 provada com o banco real; design system aplicado ([[013 - Design system da interface]]); refatoração de backend e app feita. Banco: `DATABASE_URL` usa o pooler IPv4.

Próximos passos, na ordem:
1. **Usuário:** decidir os pontos de especificação deixados pela S3 (R3): rota de edição de veículo no Mapa de telas, transferir veículo com OS ativa, cadastrar ou transferir veículo para cliente inativo, reativar cliente e veículo. Antes de codar a F4.
2. **Usuário:** rotacionar a senha do banco e a chave anon coladas no chat em 30/10.
3. **F4 (S4 e S5):** features [[005 - Gerir serviços]], [[004 - Gerir peças]] e [[018 - Dar entrada no estoque]] (marco M2). As telas já estão desenhadas (T08 a T12) no design system.
4. Conferir no app real, com sessão, as telas de usuários, clientes e veículos já redesenhadas.
5. Regerar `entregas/` antes da próxima entrega ao professor (R6); a R26 do `CLAUDE.md` continua com o texto antigo até o usuário pedir a reescrita.
6. Confirmar as propostas de decisão 007 a 010 até a S5; a 003 até o fim da S9.

## Semana que vem (a partir de 02/11/2026): próximos passos

O usuário decidiu em 2026-10-30 que os próximos passos ficam para a semana que vem. Estado hoje: F1 concluída, feature 006 com os 6 CAs ✅, 001 com a API provada e o app por provar; Trello, README, PDFs e vault em dia; tudo enviado ao GitHub (a edição da R19 no `CLAUDE.md` e esta atualização ainda estão sem commit).

1. **Usuário:** rotacionar a senha do banco e a chave anon coladas no chat (única pendência da F1).
2. **Fechar a [[001 - Autenticar]]:** rodar o **app** (web) com a conta do gerente do seed (e-mail e senha em `backend/.env`) e marcar os CAs 01 a 03.
3. **Fechar a F2:** verificações que faltam nas features 001 e 006 (`flutter build web`, `flutter build apk --debug`, `scripts/smoke.sh`), marcar as tarefas no CHECKLIST e commitar a fase (R8).
4. **S3:** features [[002 - Gerir clientes]] e [[003 - Gerir veículos]]. Antes de codar: ler a feature, os UCs e as decisões que ela cita (R22 e seção 1 do `CLAUDE.md`).
5. **Antes de qualquer entrega ao professor:** regerar os PDFs de `entregas/` (R6) e atualizar o `gerar-vault.py`, que está defasado em `Endpoints`, `Rastreabilidade` e `Índice` (regenerar só em cópia, nunca no vault real com progresso).
6. **Opcionais:** criar as etiquetas do Trello pela interface; subir as versões das ações do CI (aviso de Node 20); enviar os PDFs ao grupo "Trabalho semanal de Anthony", se o usuário quiser.

Feito em 2026-10-30 e sem pendência: quadro do Trello montado e sincronizado (ver [[Quadro do Trello]]), CI passando, mensagens de planejamento enviadas aos grupos "documentos" e "Trabalho semanal de Anthony", PDFs enviados ao grupo "documentos".

## Semana atual: S1 (02/11 a 08/11), ver [[Roadmap]]

### Depende do usuário (bloqueia o fechamento da F1)
1. Rotacionar a senha do banco e a chave anon coladas no chat.
2. Para o CI e a produção: conferir se a `DATABASE_URL` é a string do pooler (a conexão direta é só IPv6).

Resolvido em 2026-10-30: a chave de serviço e as strings de conexão já estão no `.env`. **Não haverá projeto de teste** (a branch do Supabase é recurso pago): por decisão do usuário, os testes de integração rodam no projeto único enquanto ele não tiver dados reais; exceção à R19 autorizada no chat, e a regra pode precisar ser reescrita antes de haver dados reais.

### Meu trabalho, na ordem
1. ✅ Backend da feature [[006 - Gerir usuários]] (commit `ac54610`).
2. ✅ [[000 - Fundação técnica]] fechada em 2026-10-30: 26 testes de integração e o seed do gerente (criado pelo próprio Claude, com e-mail fictício e senha aleatória só no `backend/.env`). Os 14 CAs e as 12 tarefas estão ✅; a F1 está marcada no CHECKLIST.
2b. ✅ [[006 - Gerir usuários]] com os 6 CAs provados com conta real (22 verificações ponta a ponta). Falta só rodar o **app** com essa conta, que fecha também a [[001 - Autenticar]].
3. ✅ App da F2 feito (login, sessão, menu, T03 e T04), 216 testes. Falta só a prova com conta real.
4. ✅ **Trello:** quadro montado pelo MCP (ver [[Quadro do Trello]]).

## Em seguida
- S3: F3 ([[002 - Gerir clientes]] e [[003 - Gerir veículos]]).

## Decisões pendentes
- Confirmar as propostas 007 a 010 até a S5; **decidir a 003 até o fim da S9**; 005 e 011 conforme o professor pedir.
- Aprovar (ou não) anonimização LGPD, Plano de testes e Wireframes.
- `GET /avisos` para o Mecânico (Endpoints diz "Todos"; Mapa de telas T24 exclui o Mecânico). **Resolvido:** o usuário deixou a escolha comigo; Endpoints, feature 010 e gerador agora dizem `Atendente, Almoxarife, Gerente` (RF20), e o Mecânico recebe 403.
- Decidido: os nomes "Anthony" e "Roberto" **ficam** no vault.

## Outras pendências
- Teste no Android real (celular não detectado pelo `adb`).
- Visão Board do GitHub Projects (manual) e atualizar o quadro com as fases novas.
- `CLAUDE.md` (R19) reescrito em 2026-10-30, com a aprovação do usuário, para refletir o projeto Supabase único. A R10 ainda cita "projeto de teste" para o `prisma migrate reset`; como esse projeto não existe, o comando fica, na prática, proibido.
