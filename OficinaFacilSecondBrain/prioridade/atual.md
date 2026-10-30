---
data: 2026-10-30
---

# Prioridades atuais

Editada à mão a cada sessão. Estado em [[CHECKLIST]]. Resumo do que já foi feito e como retomar: [[2026-10-30 - ZZ Resumo do dia e como retomar]].

## Semana atual: S1 (02/11 a 08/11), ver [[Roadmap]]

### Depende do usuário (bloqueia o fechamento da F1)
1. Criar o projeto Supabase de **teste** e preencher `TEST_*` no `backend/.env`.
2. Colocar a `SUPABASE_SERVICE_ROLE_KEY` no `backend/.env`.
3. String do **pooler** para `DATABASE_URL` (produção e CI).
4. Pedir o **push** (o CI nunca rodou).
5. Rotacionar a senha do banco e a chave anon coladas no chat.

### Meu trabalho, na ordem
1. ✅ Backend da feature [[006 - Gerir usuários]] (commit `ac54610`).
2. ⏳ Fechar a [[000 - Fundação técnica]]: rodar os testes de integração e o do último gerente no projeto de teste; seed do gerente; marcar os CAs 01, 05, 10 e 14. **Bloqueado pelo usuário.**
3. ✅ App da F2 feito (login, sessão, menu, T03 e T04), 216 testes. Falta só a prova com conta real.
4. ⛔ **Trello:** conectar o MCP (ver [[Quadro do Trello]]) e eu monto o quadro a partir de `metodos/trello-quadro.json`.

## Em seguida
- S3: F3 ([[002 - Gerir clientes]] e [[003 - Gerir veículos]]).

## Decisões pendentes
- Confirmar as propostas 007 a 010 até a S5; **decidir a 003 até o fim da S9**; 005 e 011 conforme o professor pedir.
- Aprovar (ou não) anonimização LGPD, Plano de testes e Wireframes.

## Outras pendências
- Teste no Android real (celular não detectado pelo `adb`).
- Visão Board do GitHub Projects (manual) e atualizar o quadro com as fases novas.
- Alterações do vault ainda não commitadas (ver o resumo do dia).
