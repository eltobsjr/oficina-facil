---
data: 2026-10-30
tipo: auditoria
origem: agente independente, sem contexto da conversa, somente leitura
---

# Auditoria externa neutra (2026-10-30)

Feita por um agente que nunca viu o projeto, antes da definição da stack e da mudança da documentação para o vault. Rodou `flutter analyze` (limpo) e `flutter test` (5 passando); não rodou os builds.

**Status de cada achado** foi conferido depois: ✅ resolvido, 🟡 parcial, 🔲 aberto.

## Estado real na época

Código: cerca de 200 linhas (tela inicial, tema, uma rota, enum `StatusOrdemServico`, 5 testes). Documentação: muito maior que o código. **0 dos 19 casos de uso implementados.**

## Lacunas de documentação

| Lacuna | Gravidade | Status |
|---|---|---|
| Sem requisitos funcionais e não funcionais numerados, nem LGPD | Grave | ✅ [[Requisitos]] |
| Sem modelo de dados (classes, ER, dicionário) | Grave | ✅ [[Modelo de dados]] |
| Persistência, autenticação e segurança indefinidas | Grave | ✅ [[001 - Persistência no Supabase Postgres via backend]], [[002 - Autenticação pelo Supabase Auth]] |
| Enunciado oficial do professor fora do repositório | Grave | 🔲 [[004 - Conferência com o enunciado oficial]] |
| Sem wireframes (o mapa de telas é só uma tabela de rotas) | Grave | 🔲 |
| Sem plano de testes | Grave | 🔲 |
| Documentação fora do git, invisível a quem clona | Grave | 🟡 por decisão do usuário a documentação vive só no vault; README resume e aponta |
| Critérios de aceitação pouco mensuráveis | Média | 🔲 |
| Sem CI, licença, CONTRIBUTING, política de branches | Média | 🟡 CI entra na [[000 - Fundação técnica]] |
| Glossário com 4 termos | Média | ✅ [[Requisitos]] |
| Sem diagrama de atividades nem sequência por UC | Média | 🔲 |
| Sem documento de implantação/ambientes | Média | ✅ [[Arquitetura]] seção 8 |

## Contradições e duplicações

| # | Achado | Status |
|---|---|---|
| 1 | README dizia que 19 UCs vêm do professor e que UC18/UC19 são derivados | ✅ corrigido: 17 oficiais, 2 deduzidos |
| 2 | Mecânico precisa listar OS (UC08, UC12) mas UC16 e a matriz não o incluíam | ✅ fila restrita em [[Casos de uso]] UC16 |
| 3 | D3 recomendava "só recusar" mas UC11/FA2 e UC12/FA1 descrevem ajuste e serviço extra | 🟡 marcados "fora do MVP" até [[003 - Ajuste do orçamento e serviço extra]] |
| 4 | Gantt com 10 e 14 dias dizendo "1 semana" | ✅ [[Roadmap]] com durações explícitas |
| 5 | "OS em aberto", "OS ativa" e `ABERTA` sem definição | ✅ "OS ativa" no glossário |
| 6 | Percentual do desconto sem base | ✅ sobre o subtotal, vale para o orçamento inteiro |
| 7 | Pagamento parcial, troco e excedente indefinidos | ✅ [[009 - Regras de pagamento]] |
| 8 | Avisos sem canal | ✅ [[010 - Avisos dentro do app]] |
| 9 | Reautenticação do gerente no UC10 | ✅ [[007 - Autorização de desconto assíncrona pelo gerente]] |
| 10 | UC17 devolve ao estoque peça já usada | 🟡 [[008 - Estoque no cancelamento da OS]] com opção "não devolver" |
| 11 | UC19 sem definir data do período | ✅ data de entrega |
| 12 | README citava 3 PDFs (eram 4) | ✅ |
| 13 | CLAUDE.md dizia "tudo no vault", a Convenções dizia o contrário | ✅ tudo no vault |
| 14 | Atores, RNs, estados e UCs duplicados entre README, docs e vault | ✅ cada coisa em um lugar |
| 15 | Duas pastas de memória do Claude | 🟡 ver devtrack de 2026-10-30 |
| 17 | README afirmava que o APK compila | ✅ conferido em 2026-10-30 (`flutter build apk --debug`) |
| 18 | Checklist genérico mal aplicado à 000 e à 020 | ✅ tarefas próprias |
| 20 | Nome do estado no Dart difere do documentado | ✅ mapeamento explícito em [[Modelo de dados]] |

## Riscos

1. **Premissa não validada (maior risco):** UC18, UC19 e as histórias deduzidos; specs, telas e checklist nascem deles.
2. **Persistência local não serve para multiusuário** → ✅ Supabase via backend.
3. Segurança só no cliente seria decorativa → ✅ RLS sem política de escrita e regras no backend.
4. Prazo e escopo: 9 fases, Android e web; recorte de entrega aberto ([[005 - Recorte de entrega]]).
5. Diagramas em Mermaid não são UML formal → [[011 - Diagramas em Mermaid e UML formal]].
6. Regras de domínio abertas (serviço extra, pagamento, estorno, reautenticação) → 🟡 em decisão.
7. Peça sem saldo orçável mas não usável → 🔲 sem fluxo de compra ou reserva.
8. Concorrência no estoque → ✅ transação com bloqueio de linha ([[Arquitetura]] seção 6).
9. Conhecimento só em arquivos privados (vault, `~/.claude`) → 🔲 fazer backup do vault.
10. Versões Riverpod 3 e go_router 18 (APIs mudaram) → 🔲 conferir ao implementar.

## Código e testes (estado na época)

- Domínio promete mais do que entrega (um enum). Coerente com "criar só quando necessário".
- `StatusOrdemServico`: `terminal` e `podeCancelar` redundantes; não sabe quem pode transitar; sem serialização; `proximo` mistura aprovação e cancelamento.
- Home duplica a cor `0xFF1F4E79`; `Image.asset` sem `errorBuilder`; sem localização pt-BR.
- `pubspec.yaml` e `analysis_options.yaml` com comentários do template; release assinado com chave de debug.
- Sem CI.
- Testes: faltam a tabela 8×8 de transições, `entregue → cancelada`, `cancelada → cancelada` e medição de cobertura.

## Stack (sugestão do auditor)

Persistência compartilhada em servidor. Supabase como backend foi a recomendação dele; backend próprio (Spring, Node ou Go) como alternativa, com o custo de dois projetos. Dica **não adotada**: começar a F1 com repositórios em memória. A regra de negócio mora no backend, então o app não ganha nada simulando-a. Evitar `riverpod_generator`, `freezed` e `build_runner`.

## Top 10 do auditor

1. Conferir o enunciado oficial (P) · 2. Decidir backend e senhas (P) · 3. Documentação visível ao professor (M) · 4. Requisitos e matriz (M) · 5. Modelo de dados (M) · 6. Fechar regras abertas (M) · 7. CI, licença, branches (P) · 8. Eliminar duplicações (P) · 9. Reforçar testes de domínio (P) · 10. Testar no Android, wireframes e pt-BR (M).
