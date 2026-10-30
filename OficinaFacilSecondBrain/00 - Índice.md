---
data: 2026-10-30
---

# OficinaFácil — Índice do vault

- [[OficinaFácil — Visão Geral]]
- [[Convenções]]
- [[CHECKLIST]] — lista mestra marcável
- [[Mapa de telas]]
- [[Roadmap]]
- [[Plano de construção]] — telas, componentes e módulos por fase
- [[Rodar o projeto]] — backend, app, Docker e problemas conhecidos
- [[00 - Índice de decisões]]
- [[atual|Prioridades atuais]]

## Especificação

- [[Requisitos]] · [[Casos de uso]] · [[Histórias de usuário]] · [[Rastreabilidade]]
- [[Arquitetura]] · [[Modelo de dados]] · [[Diagramas]] · [[Endpoints]]

## Features (numeração = número do caso de uso)

| Feature | Fase | UC | RF | Histórias |
|---|---|---|---|---|
| [[000 - Fundação técnica]] | F1 | — | — | — |
| [[001 - Autenticar]] | F2 | UC01 | RF01, RF23 | US01, US22 |
| [[002 - Gerir clientes]] | F3 | UC02 | RF02 | US02 |
| [[003 - Gerir veículos]] | F3 | UC03 | RF03 | US03 |
| [[004 - Gerir peças]] | F4 | UC04 | RF04, RF22 | US04, US21 |
| [[005 - Gerir serviços]] | F4 | UC05 | RF05 | US05 |
| [[006 - Gerir usuários]] | F2 | UC06 | RF06 | US06 |
| [[007 - Abrir OS]] | F5 | UC07 | RF07 | US07 |
| [[008 - Registrar diagnóstico]] | F5 | UC08 | RF08 | US08 |
| [[009 - Montar orçamento]] | F5 | UC09 | RF09 | US09 |
| [[010 - Autorizar desconto]] | F5 | UC10 | RF10 | US10 |
| [[011 - Registrar aprovação do cliente]] | F6 | UC11 | RF11 | US11, US12 |
| [[012 - Executar serviço]] | F6 | UC12 | RF12 | US13 |
| [[013 - Registrar peças usadas]] | F6 | UC13 | RF13, RF20 | US14 |
| [[014 - Concluir OS]] | F7 | UC14 | RF14, RF20 | US15 |
| [[015 - Entregar e registrar pagamento]] | F7 | UC15 | RF15 | US16 |
| [[016 - Consultar OS]] | F8 | UC16 | RF16, RF21 | US17, US23 |
| [[017 - Cancelar OS]] | F7 | UC17 | RF17 | US18 |
| [[018 - Dar entrada no estoque]] | F4 | UC18 | RF18 | US19 |
| [[019 - Ver faturamento]] | F8 | UC19 | RF19 | US20 |
| [[020 - Acabamento e entrega final]] | F9 | — | — | — |

## Pastas

- `features/`: uma spec por feature, com critérios de aceitação e API
- `requisitos/`: requisitos, casos de uso, histórias, rastreabilidade
- `arquitetura/`: arquitetura, modelo de dados, diagramas
- `api/`: contrato dos endpoints (gerado)
- `telas/`: mapa de telas e rotas
- `decisions/`: uma decisão por arquivo
- `auditorias/`: auditorias e revisões
- `entregas/`: PDFs gerados
- `identidade-visual/`: kit do logo
- `metodos/`: como gerar as notas e os PDFs
- `devtrack/`: log de cada sessão
- `commits/`: um arquivo por commit importante
- `prioridade/`: o que fazer agora
