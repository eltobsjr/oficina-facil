---
data: 2026-10-30
---

# Prioridades atuais

Editada à mão a cada sessão. Estado em [[CHECKLIST]]. Resumo do que já foi feito e como retomar: [[2026-10-30 - ZZ Resumo do dia e como retomar]].

## Primeira coisa ao reabrir (2026-10-30, fim do dia)

1. ✅ **Quadro do Trello montado** (2026-10-30): 6 listas, 58 cartões, 21 checklists; limites do MCP (etiquetas e Planejador) em [[Quadro do Trello]]. Cartão do push removido (57 cartões agora). Cartões de exemplo do modelo todos arquivados. Resta, se o usuário quiser, criar as etiquetas na interface.
2. ✅ **CI resolvido:** passou nos dois jobs na primeira execução (41129044900). Opcional: subir as versões das ações do workflow (aviso de Node 20).
3. Depois, o que depende do usuário (abaixo) e a S3.

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
- Alterações do vault ainda não commitadas (ver o resumo do dia).
