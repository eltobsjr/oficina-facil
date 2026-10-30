---
data: 2026-10-30
tipo: revisão
origem: agente Opus independente, somente leitura
---

# Revisão Opus de tudo (2026-10-30)

Revisão de coerência, eficiência e qualidade de toda a documentação, do `CLAUDE.md`, do README e do código. Notas dadas pelo revisor: coerência 5, eficiência 6, completude 6, segurança 5, executabilidade 5 (de 10), **antes** das correções.

Status: ✅ aplicado · 🟡 proposto ao usuário (aguarda aprovação) · 🔲 aberto.

## Problemas e o que foi feito

| # | Gravidade | Problema | Status |
|---|---|---|---|
| 1 | Crítico | Gerador destrutivo e vault sem versão | ✅ gerador aborta se há progresso (`--force`, `--dry-run`), data real, sem pós-processamento global, `Convenções` e `prioridade` deixaram de ser gerados. 🟡 backup/versionamento do vault |
| 2 | Crítico | RLS de leitura e Realtime expunham OS e peças a qualquer autenticado | ✅ tabela `avisos`; SELECT só nela; ver [[Modelo de dados]] §6 |
| 3 | Alto | UC10 com senha do gerente passando pelo backend | ✅ autorização assíncrona ([[007 - Autorização de desconto assíncrona pelo gerente]]) |
| 4 | Alto | Dependências circulares e CAs fora do MVP travando a definição de pronto | ✅ CAs movidos (002→007, 009↔010), 011/012 marcados ❌ Descartado, 017 depende só da 013 |
| 5 | Alto | Modelo de dados não cobria o que as features usam | ✅ `finalizado`, `devolvida`, `motivo_nao_devolucao`, autorizações, `avisos`, `perfis.email UK`, CHECK do desconto, índices, nota da sequence |
| 6 | Alto | Pagamento com estado parcial e sem estorno | ✅ pagamentos só no ato da entrega ([[009 - Regras de pagamento]]) |
| 7 | Alto | Sem onde rodar testes de integração e migrations | ✅ projeto Supabase de teste e `shadowDatabaseUrl` na [[000 - Fundação técnica]]. ✅ exceção na R19 |
| 8 | Alto | `policies.sql` contra "só migration do Prisma" | ✅ RLS, gatilhos e índices dentro das migrations (`--create-only`). ✅ R19 reescrita |
| 9 | Médio-alto | README duplica especificação e afirma o que não existe | ✅ README ajustado (ver devtrack) |
| 10 | Médio | Regras do CLAUDE.md ambíguas ou impossíveis (R7 a R26) | ✅ aplicadas a pedido do usuário |
| 11 | Médio | Estoque com Prisma e transação entre módulos | ✅ `UPDATE ... WHERE saldo >= q`; `baixar(tx)`/`estornar(tx)` no `index.ts` de `pecas`; CA de concorrência na 013 |
| 12 | Médio | Violações no código | ✅ ver devtrack |
| 13 | Médio | Lacunas de LGPD | ✅ DTO do mecânico, busca sem PII em query, seed fictício, `sa-east-1`. 🟡 anonimização (novo UC) |
| 14 | Médio | Perfis incoerentes entre matriz, endpoints, telas e diagramas | ✅ mecânico com UC13 e UC16, leituras auxiliares na matriz, histórico para o mecânico, ⚠️ em US19, US20, 018 e 019 |
| 15 | Baixo-médio | Resíduos e duplicações | ✅ `docs/` removido, glossário e diagramas deduplicados, títulos e contagens corrigidos |

## Mudanças no CLAUDE.md

O `CLAUDE.md` (§0) só muda por pedido do usuário. O revisor propôs as 11 mudanças abaixo; o usuário mandou aplicá-las em 2026-10-30 (✅). Mudanças feitas **além** das propostas, por decisão do usuário: commit liberado por fase ou feature, push só sob pedido, e RLS e gatilhos dentro das migrations.

1. **R7:** trocar "arquivo versionado" por "linha de atribuição ou autoria em commit, PR, comentário ou arquivo" (hoje o próprio `CLAUDE.md` e o README citam "Claude").
2. **R8:** lista fechada de gatilhos ("commit", "commita", "push", "envia ao GitHub"; tirar "sobe", que é ambíguo) e dizer que commit não autoriza push.
3. **R9:** o histórico usa "Adiciona/Gera" (presente do indicativo), não imperativo; "por caminho" pode ser diretório depois de conferir `git status`.
4. **R10:** incluir `gerar-vault.py --force`, `prisma migrate reset`, `prisma db push` e `supabase db reset`.
5. **R11:** comandos por tipo de mudança (o `smoke.sh` só antes de fechar a feature; `flutter run` não é verificação).
6. **R13:** `data` existe em toda feature que chama a API; `usecases` só com regra de UI reutilizada.
7. **R19:** RLS e gatilhos dentro das migrations do Prisma; exceção para o projeto Supabase de teste e o CI.
8. **R20:** segredos também em *secrets* do CI e do provedor; `.env.example` e `env.example.json` versionados; "nenhuma senha em log".
9. **R22, R23, R26, R1:** CA ❌ não conta para "pronto"; trocar a lista fixa de decisões abertas por "as marcadas aberta no índice"; cor da marca num só lugar do Dart; permitir `openapi.json`, `LICENSE` e `.env.example`.
10. **R2:** lista de notas geradas atualizada (ver [[Gerar notas e PDFs]]).
11. **Regras novas sugeridas:** política de branches, dados de teste fictícios (LGPD), fuso horário, backup do vault, não expor tabelas de negócio pelo PostgREST.

## Aguardam decisão do usuário (nada disso foi inventado)

- **Anonimização LGPD** (RNF09): exige UC, RF e endpoint novos.
- **Plano de testes** e **Wireframes**: o revisor recomenda criá-los.
- **Versionar o vault** com `git init` próprio e remoto privado (ação externa). O usuário resolve as pendências manuais.

## Verificado pelo revisor

`flutter analyze` sem problemas, 5 testes passando, `dart format` sem alterações; os 9 PDFs batem com as notas e nenhum diagrama tem erro de sintaxe. Não rodou os builds nem testou no Android.
