---
data: 2026-10-30
---

> Nota GERADA por script a partir das features. Não editar à mão.

# Rastreabilidade

RF → UC → história → feature → endpoints → telas → tabelas. Requisitos em [[Requisitos]].

| RF | UC | Histórias | Feature | Endpoints | Telas | Tabelas |
|---|---|---|---|---|---|---|
| — | — | — | [[000 - Fundação técnica]] | GET `/health`<br>GET `/docs` | — | todas (RLS) |
| RF01, RF23 | UC01 | US01, US22 | [[001 - Autenticar]] | GET `/me` | T01, T02, T25, T26 | perfis |
| RF02 | UC02 | US02 | [[002 - Gerir clientes]] | GET `/clientes`<br>POST `/clientes`<br>GET `/clientes/:id`<br>PATCH `/clientes/:id`<br>POST `/clientes/:id/inativar` | T05, T06 | clientes |
| RF03 | UC03 | US03 | [[003 - Gerir veículos]] | GET `/clientes/:id/veiculos`<br>POST `/clientes/:id/veiculos`<br>GET `/veiculos`<br>GET `/veiculos/:id`<br>PATCH `/veiculos/:id`<br>POST `/veiculos/:id/transferir`<br>POST `/veiculos/:id/inativar` | T07 | veiculos |
| RF04, RF22 | UC04 | US04, US21 | [[004 - Gerir peças]] | GET `/pecas`<br>POST `/pecas`<br>GET `/pecas/:id`<br>PATCH `/pecas/:id`<br>POST `/pecas/:id/inativar` | T10, T11 | pecas |
| RF05 | UC05 | US05 | [[005 - Gerir serviços]] | GET `/servicos`<br>POST `/servicos`<br>PATCH `/servicos/:id`<br>POST `/servicos/:id/inativar` | T08, T09 | servicos |
| RF06 | UC06 | US06 | [[006 - Gerir usuários]] | GET `/usuarios`<br>POST `/usuarios`<br>GET `/usuarios/:id`<br>PATCH `/usuarios/:id`<br>POST `/usuarios/:id/redefinir-senha`<br>POST `/usuarios/:id/inativar`<br>POST `/usuarios/:id/ativar` | T03, T04 | perfis |
| RF07 | UC07 | US07 | [[007 - Abrir OS]] | POST `/os`<br>GET `/os`<br>GET `/os/:id` | T13, T14, T15 | ordens_servico, historico_transicoes |
| RF08 | UC08 | US08 | [[008 - Registrar diagnóstico]] | POST `/os/:id/diagnostico`<br>PUT `/os/:id/diagnostico/rascunho` | T14, T16 | diagnosticos, ordens_servico, historico_transicoes |
| RF09 | UC09 | US09 | [[009 - Montar orçamento]] | PUT `/os/:id/orcamento`<br>POST `/os/:id/orcamento/confirmar` | T17 | orcamentos, itens_orcamento, ordens_servico, historico_transicoes |
| RF10 | UC10 | US10 | [[010 - Autorizar desconto]] | POST `/os/:id/orcamento/solicitacao-desconto`<br>GET `/solicitacoes-desconto`<br>POST `/solicitacoes-desconto/:id/decisao` | T17, T18 | autorizacoes_desconto, avisos |
| RF11 | UC11 | US11, US12 | [[011 - Registrar aprovação do cliente]] | POST `/os/:id/aprovacao` | T19 | aprovacoes, ordens_servico, historico_transicoes |
| RF12 | UC12 | US13 | [[012 - Executar serviço]] | POST `/os/:id/execucao`<br>POST `/os/:id/observacoes` | T14, T20 | ordens_servico, observacoes, historico_transicoes |
| RF13, RF20 | UC13 | US14 | [[013 - Registrar peças usadas]] | POST `/os/:id/pecas-usadas`<br>DELETE `/os/:id/pecas-usadas/:pecaUsadaId` | T20, T24 | pecas_usadas, movimentacoes_estoque, pecas, avisos |
| RF14, RF20 | UC14 | US15 | [[014 - Concluir OS]] | POST `/os/:id/concluir`<br>GET `/avisos`<br>POST `/avisos/:id/lido` | T15, T24 | ordens_servico, historico_transicoes, avisos |
| RF15 | UC15 | US16 | [[015 - Entregar e registrar pagamento]] | POST `/os/:id/entregar` | T21 | pagamentos, ordens_servico, historico_transicoes |
| RF16, RF21 | UC16 | US17, US23 | [[016 - Consultar OS]] | GET `/os`<br>GET `/os/:id/historico` | T14, T15 | ordens_servico, historico_transicoes |
| RF17 | UC17 | US18 | [[017 - Cancelar OS]] | POST `/os/:id/cancelar` | T22 | ordens_servico, historico_transicoes, pecas_usadas, movimentacoes_estoque |
| RF18 | UC18 | US19 | [[018 - Dar entrada no estoque]] | POST `/pecas/:id/entradas`<br>GET `/pecas/:id/movimentacoes` | T12 | pecas, movimentacoes_estoque |
| RF19 | UC19 | US20 | [[019 - Ver faturamento]] | GET `/faturamento` | T23 | pagamentos, ordens_servico |
| — | — | — | [[020 - Acabamento e entrega final]] | — | — | — |

Telas em [[Mapa de telas]].
