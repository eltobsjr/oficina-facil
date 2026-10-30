---
data: 2026-10-30
---

# Convenções do projeto

Regras para que toda feature, tela, teste e documento sigam o mesmo padrão.

## Onde cada coisa vive

Toda a documentação do projeto vive neste vault. O vault fica **dentro do repositório** (junto com `mobile/` e `backend/`) e é versionado. Além dele, o repositório tem só o código, o `README.md` e o `CLAUDE.md`. **Não existe pasta `docs/`.**

| O quê | Onde |
|---|---|
| Visão geral e estado do projeto | [[OficinaFácil — Visão Geral]] |
| O que construir, marcável | [[CHECKLIST]] |
| Fases, marcos e riscos | [[Roadmap]] |
| Requisitos RF/RNF e glossário | [[Requisitos]] |
| Casos de uso, regras RN01 a RN09 e fluxos | [[Casos de uso]] |
| Histórias de usuário | [[Histórias de usuário]] |
| Rastreabilidade (gerada) | [[Rastreabilidade]] |
| Arquitetura, stack, ambientes, segurança | [[Arquitetura]] |
| Modelo de dados (ER, enums, restrições) | [[Modelo de dados]] |
| Diagramas do app (camadas, pastas) | [[Diagramas]] |
| Contrato da API (gerado) e OpenAPI do backend | [[Endpoints]] |
| Decisões (uma por arquivo) | `decisions/`, índice em [[00 - Índice de decisões]] |
| Critérios de aceitação de cada feature | `features/NNN - Nome.md` |
| Telas e rotas | [[Mapa de telas]] |
| Auditorias e revisões | `auditorias/` |
| Logo e identidade visual | [[00 - Identidade visual]] |
| Como gerar notas e PDFs | `metodos/` |
| PDFs para entrega ao professor (gerados) | `entregas/` |
| Log de cada sessão | `devtrack/YYYY-MM-DD - Título.md` |
| Prioridades | `prioridade/atual.md` (à mão) |

**Regra de ouro:** cada informação existe em um só lugar. Os outros arquivos apontam para ela. **Notas geradas** (não se editam à mão; regera-se pelo gerador, ver [[Gerar notas e PDFs]]): `api/Endpoints`, `requisitos/Rastreabilidade`, `telas/Mapa de telas`, `00 - Índice` e `entregas/`. `features/*.md` e `CHECKLIST.md` são **criados** pelo gerador e **depois editados à mão** (status dos CAs e tarefas marcadas); o gerador recusa sobrescrevê-los se houver progresso. `Convenções` e `prioridade/atual` são sempre à mão.

## Numeração

- Features: `NNN`; `001` a `019` coincidem com `UC01` a `UC19`. `000` é a fundação e `020` o acabamento.
- Requisitos: `RF01`... e `RNF01`...; RF01 a RF19 coincidem com UC01 a UC19.
- Telas: `T01`...; critérios: `CA01`... dentro de cada feature; regras: `RN01` a `RN09`; decisões: o número do arquivo em `decisions/` (D1 = 001).

## Status

- Feature: `planejada` → `em andamento` → `concluida` (campo `status` no cabeçalho).
- CA: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado.
- ⚠️: fluxo deduzido por nós, a conferir com o documento oficial.
- Decisão (campo `status`): aceita · proposta · aberta.

## Definição de pronto de uma feature

1. Todos os CAs ✅ e as tarefas do CHECKLIST marcadas.
2. Backend: `npm run lint && npm run format:check && npm run typecheck && npm test` e `bash scripts/smoke.sh`.
3. App (dentro de `mobile/`): `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.
4. Camada `domain` do app sem imports de Flutter, `data` ou `presentation`; módulos do backend só se falam por `index.ts`.
5. Devtrack atualizado e quadro do GitHub movido para Done.
6. Se mudou comportamento: notas do vault atualizadas e PDFs de `entregas/` regerados.

## Código

- **App:** `mobile/lib/features/<feature>/{domain,data,presentation}`; `data` só cria o que a regra exigir; textos em português na apresentação; datas pelo relógio injetável.
- **Backend:** `src/modules/<modulo>/{index,routes,service,repository,schemas}.ts`; Zod em toda rota; regra de negócio no `service`; transação por caso de uso.
- **Dinheiro** em centavos (inteiro) em todo lugar. **Estado da OS** em `UPPER_SNAKE` na API e no banco, `camelCase` no Dart, com conversão num só lugar.
- **Segredos** só em `backend/.env` e `mobile/env.json` (ignorados). Chave de serviço do Supabase só no backend.
- **Banco:** nunca container; só o Supabase. RLS em toda tabela; o app não escreve.
- **Commits** em português, no presente do indicativo, 3ª pessoa ("Adiciona…"), **sem nenhuma linha de coautoria ou atribuição** (R7). Um commit por feature concluída ou fase de construção, direto na `main`, sem pedir a cada vez (R8). **Push só quando o usuário pedir**, e vale só para aquele pedido.
