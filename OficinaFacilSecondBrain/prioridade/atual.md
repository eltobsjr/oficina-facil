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
1. Criar o projeto Supabase de **teste** e preencher `TEST_*` no `backend/.env`.
2. Colocar a `SUPABASE_SERVICE_ROLE_KEY` no `backend/.env`.
3. String do **pooler** para `DATABASE_URL` (produção e CI).
4. Rotacionar a senha do banco e a chave anon coladas no chat.

### Meu trabalho, na ordem
1. ✅ Backend da feature [[006 - Gerir usuários]] (commit `ac54610`).
2. ⏳ Fechar a [[000 - Fundação técnica]]: rodar os testes de integração e o do último gerente no projeto de teste; seed do gerente; marcar os CAs 01, 05, 10 e 14. **Bloqueado pelo usuário.**
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
