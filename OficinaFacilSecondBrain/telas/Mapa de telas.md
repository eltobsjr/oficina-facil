---
data: 2026-10-30
---

# Mapa de telas

Telas derivadas dos casos de uso, sem inventar nada além deles. Cada tela pertence a uma ou mais features.
Rotas definidas aqui valem para o `go_router`; se uma rota mudar, muda aqui primeiro.

| ID | Tela | Rota | Perfis | Features |
|---|---|---|---|---|
| T01 | Login | `/login` | Todos (sem sessão) | [[001 - Autenticar]] |
| T02 | Início (menu por perfil) | `/` | Todos | [[001 - Autenticar]] |
| T03 | Lista de usuários | `/usuarios` | Gerente | [[006 - Gerir usuários]] |
| T04 | Formulário de usuário | `/usuarios/novo · /usuarios/:id` | Gerente | [[006 - Gerir usuários]] |
| T05 | Lista de clientes | `/clientes` | Atendente | [[002 - Gerir clientes]] |
| T06 | Formulário de cliente | `/clientes/novo · /clientes/:id` | Atendente | [[002 - Gerir clientes]] |
| T07 | Veículos do cliente e formulário | `/clientes/:id/veiculos · /clientes/:id/veiculos/novo` | Atendente | [[003 - Gerir veículos]] |
| T08 | Lista de serviços | `/servicos` | Gerente | [[005 - Gerir serviços]] |
| T09 | Formulário de serviço | `/servicos/novo · /servicos/:id` | Gerente | [[005 - Gerir serviços]] |
| T10 | Lista de peças (com alerta de estoque baixo) | `/pecas` | Almoxarife | [[004 - Gerir peças]] |
| T11 | Formulário de peça | `/pecas/novo · /pecas/:id` | Almoxarife | [[004 - Gerir peças]] |
| T12 | Entrada no estoque | `/pecas/:id/entrada` | Almoxarife | [[018 - Dar entrada no estoque]] |
| T13 | Abrir OS | `/os/nova` | Atendente | [[007 - Abrir OS]] |
| T14 | Lista e busca de OS | `/os` | Atendente, Gerente, Mecânico (fila restrita) | [[007 - Abrir OS]], [[016 - Consultar OS]], [[008 - Registrar diagnóstico]], [[012 - Executar serviço]] |
| T15 | Detalhe da OS (dados, orçamento, peças, histórico, ações por estado) | `/os/:id` | Atendente, Gerente, Mecânico (sem documento e telefone do cliente) | [[007 - Abrir OS]], [[016 - Consultar OS]], [[014 - Concluir OS]] |
| T16 | Diagnóstico | `/os/:id/diagnostico` | Mecânico | [[008 - Registrar diagnóstico]] |
| T17 | Orçamento (inclui pedir autorização de desconto) | `/os/:id/orcamento` | Atendente | [[009 - Montar orçamento]], [[010 - Autorizar desconto]] |
| T18 | Solicitações de desconto (pendentes e decididas) | `/descontos` | Gerente | [[010 - Autorizar desconto]] |
| T19 | Aprovação ou recusa do cliente | `/os/:id/aprovacao` | Atendente | [[011 - Registrar aprovação do cliente]] |
| T20 | Execução e peças usadas | `/os/:id/execucao` | Mecânico | [[012 - Executar serviço]], [[013 - Registrar peças usadas]] |
| T21 | Pagamento e entrega | `/os/:id/entrega` | Atendente | [[015 - Entregar e registrar pagamento]] |
| T22 | Cancelar OS (diálogo com motivo) | `diálogo sobre T15` | Atendente, Gerente | [[017 - Cancelar OS]] |
| T23 | Faturamento | `/faturamento` | Gerente | [[019 - Ver faturamento]] |
| T24 | Notificações no app (OS concluída, saldo insuficiente) | `/notificacoes` | Atendente, Almoxarife | [[013 - Registrar peças usadas]], [[014 - Concluir OS]] |

## Acesso por perfil (RN09)

| Perfil | Telas |
|---|---|
| Atendente | T01, T02, T05, T06, T07, T13, T14, T15, T17, T19, T21, T22, T24 |
| Mecânico | T01, T02, T14, T15, T16, T20 |
| Almoxarife | T01, T02, T10, T11, T12, T24 |
| Gerente | T01, T02, T03, T04, T08, T09, T14, T15, T18, T22, T23 |
