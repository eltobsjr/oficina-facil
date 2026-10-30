---
data: 2026-10-30
---

> Nota GERADA por script a partir das features. Não editar à mão.

# Endpoints — API do OficinaFácil

Contrato resumido por caso de uso. O contrato completo e sempre atual é o OpenAPI do backend (`backend/openapi.json`, Swagger em `/docs`). Arquitetura em [[Arquitetura]].

- **Base:** `/api/v1`. **Formato:** JSON. **Dinheiro:** centavos inteiros. **Datas:** ISO 8601.
- **Autenticação:** `Authorization: Bearer <JWT do Supabase>` em todas as rotas, exceto `/health`.
- **Autorização:** o perfil vem da tabela `perfis`; perfil sem permissão recebe `403`, sem token `401`.
- **Erros:** formato único `{ "erro": { "codigo": "...", "mensagem": "..." } }`; validação com Zod devolve `422`; transição de estado inválida devolve `409`.
- **Estados da OS:** `ABERTA`, `DIAGNOSTICADA`, `AGUARDANDO_APROVACAO`, `APROVADA`, `EM_EXECUCAO`, `CONCLUIDA`, `ENTREGUE`, `CANCELADA`.

| Feature | UC | Método | Caminho | Perfis | O que faz |
|---|---|---|---|---|---|
| [[000 - Fundação técnica]] | — | GET | `/health` | Público | Estado do serviço |
| [[000 - Fundação técnica]] | — | GET | `/docs` | Público (dev) | Swagger a partir do OpenAPI |
| [[001 - Autenticar]] | UC01 | GET | `/me` | Todos | Nome, perfil e situação do usuário autenticado |
| [[002 - Gerir clientes]] | UC02 | GET | `/clientes` | Atendente | Busca por nome ou documento |
| [[002 - Gerir clientes]] | UC02 | POST | `/clientes` | Atendente | Cadastra |
| [[002 - Gerir clientes]] | UC02 | GET | `/clientes/:id` | Atendente | Detalha |
| [[002 - Gerir clientes]] | UC02 | PATCH | `/clientes/:id` | Atendente | Altera |
| [[002 - Gerir clientes]] | UC02 | POST | `/clientes/:id/inativar` | Atendente | Inativa (sem OS ativa) |
| [[003 - Gerir veículos]] | UC03 | GET | `/clientes/:id/veiculos` | Atendente | Veículos do cliente |
| [[003 - Gerir veículos]] | UC03 | POST | `/clientes/:id/veiculos` | Atendente | Cadastra |
| [[003 - Gerir veículos]] | UC03 | GET | `/veiculos` | Atendente | Busca por placa |
| [[003 - Gerir veículos]] | UC03 | GET | `/veiculos/:id` | Atendente | Detalha |
| [[003 - Gerir veículos]] | UC03 | PATCH | `/veiculos/:id` | Atendente | Altera |
| [[003 - Gerir veículos]] | UC03 | POST | `/veiculos/:id/transferir` | Atendente | Muda o dono |
| [[003 - Gerir veículos]] | UC03 | POST | `/veiculos/:id/inativar` | Atendente | Inativa |
| [[004 - Gerir peças]] | UC04 | GET | `/pecas` | Atendente, Mecânico, Almoxarife | Lista; `?abaixoDoMinimo=true` para o alerta |
| [[004 - Gerir peças]] | UC04 | POST | `/pecas` | Almoxarife | Cadastra (saldo 0) |
| [[004 - Gerir peças]] | UC04 | GET | `/pecas/:id` | Almoxarife | Detalha |
| [[004 - Gerir peças]] | UC04 | PATCH | `/pecas/:id` | Almoxarife | Altera (sem tocar o saldo) |
| [[004 - Gerir peças]] | UC04 | POST | `/pecas/:id/inativar` | Almoxarife | Inativa |
| [[005 - Gerir serviços]] | UC05 | GET | `/servicos` | Atendente, Gerente | Lista (ativos para orçamento) |
| [[005 - Gerir serviços]] | UC05 | POST | `/servicos` | Gerente | Cadastra |
| [[005 - Gerir serviços]] | UC05 | PATCH | `/servicos/:id` | Gerente | Altera |
| [[005 - Gerir serviços]] | UC05 | POST | `/servicos/:id/inativar` | Gerente | Inativa |
| [[006 - Gerir usuários]] | UC06 | GET | `/usuarios` | Gerente | Lista usuários |
| [[006 - Gerir usuários]] | UC06 | POST | `/usuarios` | Gerente | Cria usuário (Auth + perfil) |
| [[006 - Gerir usuários]] | UC06 | GET | `/usuarios/:id` | Gerente | Detalha |
| [[006 - Gerir usuários]] | UC06 | PATCH | `/usuarios/:id` | Gerente | Altera nome e perfil |
| [[006 - Gerir usuários]] | UC06 | POST | `/usuarios/:id/redefinir-senha` | Gerente | Nova senha |
| [[006 - Gerir usuários]] | UC06 | POST | `/usuarios/:id/inativar` | Gerente | Inativa (não o último gerente) |
| [[006 - Gerir usuários]] | UC06 | POST | `/usuarios/:id/ativar` | Gerente | Reativa |
| [[007 - Abrir OS]] | UC07 | POST | `/os` | Atendente | Abre a OS em `ABERTA` |
| [[007 - Abrir OS]] | UC07 | GET | `/os` | Atendente, Gerente, Mecânico | Lista simples (número, estado, cliente, veículo); o mecânico vê só a fila da sua etapa |
| [[007 - Abrir OS]] | UC07 | GET | `/os/:id` | Atendente, Gerente, Mecânico | Detalhe; para o mecânico, sem documento e telefone do cliente |
| [[008 - Registrar diagnóstico]] | UC08 | POST | `/os/:id/diagnostico` | Mecânico | Registra e leva a `DIAGNOSTICADA` |
| [[008 - Registrar diagnóstico]] | UC08 | PUT | `/os/:id/diagnostico/rascunho` | Mecânico | Guarda rascunho (`finalizado = false`) |
| [[009 - Montar orçamento]] | UC09 | PUT | `/os/:id/orcamento` | Atendente | Grava itens e desconto (rascunho) |
| [[009 - Montar orçamento]] | UC09 | POST | `/os/:id/orcamento/confirmar` | Atendente | Confirma e leva a `AGUARDANDO_APROVACAO` |
| [[010 - Autorizar desconto]] | UC10 | POST | `/os/:id/orcamento/solicitacao-desconto` | Atendente | Pede autorização de desconto acima de 10% (nasce `PENDENTE`, avisa o gerente) |
| [[010 - Autorizar desconto]] | UC10 | GET | `/solicitacoes-desconto` | Gerente | Lista pendentes e decididas |
| [[010 - Autorizar desconto]] | UC10 | POST | `/solicitacoes-desconto/:id/decisao` | Gerente | Aprova (valor igual ou menor) ou recusa, com o próprio JWT; avisa o atendente |
| [[010 - Autorizar desconto]] | UC10 | GET | `/avisos` | Todos | Avisos do próprio usuário (T24); a primeira feature a produzir avisos é esta |
| [[010 - Autorizar desconto]] | UC10 | POST | `/avisos/:id/lido` | Todos | Marca aviso como lido |
| [[011 - Registrar aprovação do cliente]] | UC11 | POST | `/os/:id/aprovacao` | Atendente | Aprova (`APROVADA`) ou recusa (`CANCELADA`) |
| [[012 - Executar serviço]] | UC12 | POST | `/os/:id/execucao` | Mecânico | Inicia e leva a `EM_EXECUCAO` |
| [[012 - Executar serviço]] | UC12 | POST | `/os/:id/observacoes` | Mecânico | Anota andamento |
| [[013 - Registrar peças usadas]] | UC13 | POST | `/os/:id/pecas-usadas` | Mecânico | Lança peça e baixa o saldo |
| [[013 - Registrar peças usadas]] | UC13 | DELETE | `/os/:id/pecas-usadas/:pecaUsadaId` | Mecânico | Estorna lançamento |
| [[014 - Concluir OS]] | UC14 | POST | `/os/:id/concluir` | Mecânico | Leva a `CONCLUIDA` e cria aviso para o atendente |
| [[015 - Entregar e registrar pagamento]] | UC15 | POST | `/os/:id/entregar` | Atendente | Corpo com `pagamentos[]` (forma, valor); exige soma igual ao total e leva a `ENTREGUE` numa transação |
| [[016 - Consultar OS]] | UC16 | GET | `/os` | Atendente, Gerente, Mecânico | Estende a lista da 007 com filtros: numero, cliente, placa, estado, de, ate (cliente e placa vão no corpo de busca ou em parâmetro sem PII nos logs) |
| [[016 - Consultar OS]] | UC16 | GET | `/os/:id/historico` | Atendente, Gerente, Mecânico | Transições |
| [[017 - Cancelar OS]] | UC17 | POST | `/os/:id/cancelar` | Atendente, Gerente | Cancela com motivo e estorna as peças na mesma transação (decisão 008) |
| [[018 - Dar entrada no estoque]] | UC18 | POST | `/pecas/:id/entradas` | Almoxarife | Entrada: quantidade, custo e nota |
| [[018 - Dar entrada no estoque]] | UC18 | GET | `/pecas/:id/movimentacoes` | Almoxarife | Razão do estoque |
| [[019 - Ver faturamento]] | UC19 | GET | `/faturamento` | Gerente | Total, quantidade e ticket médio no período (`de`, `ate`) |

Login e logout não têm endpoint: são do Supabase Auth, chamados direto pelo app.
Avisos entre perfis (RF20): o app lê pela API (`GET /avisos`) e o Supabase Realtime só avisa que chegou um novo.
