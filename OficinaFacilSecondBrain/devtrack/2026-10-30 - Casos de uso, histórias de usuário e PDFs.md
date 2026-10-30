# 2026-10-30 — Análise completa, nova stack e vault como fonte única

## O que foi feito

1. **Casos de uso e histórias.** 19 UCs especificados, 23 histórias derivadas, diagramas Mermaid (geral, por módulo, estados, 3 sequências).
2. **GitHub Projects.** Projeto "OficinaFácil" (#4, privado) ligado ao repositório, com as tarefas da Entrega 1 em Done e as pendências em Todo/In Progress. A visão Board precisa ser criada pela interface (o `gh` não cria visões e a automação do Chrome falhou duas vezes).
3. **Auditoria externa neutra** por agente sem contexto (nota em `auditorias/`). Achados principais: nenhum UC implementado; faltavam requisitos numerados, modelo de dados e decisões de stack; persistência local não serve para quatro perfis em aparelhos diferentes; várias contradições entre arquivos.
4. **Stack redefinida.** Comparados os projetos Polímata (Supabase com RPC e Edge Functions, sem backend) e Confia (backend próprio + Supabase). Decisão: **Confia enxuto**: Flutter + Node 22/Express 5/TypeScript/Zod/Prisma + Supabase (Postgres com RLS, Auth, Realtime, Storage). Sem BullMQ, Asaas, mapas, painel admin ou Edge Functions. Spring Boot descartado: o time não domina Java.
5. **Documentação migrada para o vault**, seguindo o padrão do Polímata e do Confia: `requisitos/`, `arquitetura/`, `api/`, `decisions/` (12 decisões, uma por arquivo), `features/` (21 specs com CAs), `telas/`, `auditorias/`, `entregas/` (PDFs), `identidade-visual/`, `metodos/`. A pasta `docs/` deixou de existir; o kit do logo foi para o vault.
6. **Notas novas:** Requisitos (23 RF, 20 RNF, glossário), Modelo de dados (ER em 3 diagramas, 16 tabelas, enums, restrições, RLS), Arquitetura, Roadmap (F1 a F9), Endpoints e Rastreabilidade (geradas).
7. **Correção das contradições** do auditor: UC16 inclui o mecânico (fila restrita); "OS ativa" definida; desconto sobre o subtotal; pagamento sem excedente; avisos dentro do app; UC19 pela data de entrega; D3 marcada "fora do MVP".
8. **Monorepo como o Confia:** o app Flutter foi para `mobile/`, `backend/` criado vazio, `.gitignore` dividido. Conferido: `flutter pub get`, `flutter analyze` (sem problemas) e `flutter test` (5 passando) rodam dentro de `mobile/`.
9. **CLAUDE.md reescrito** com 26 regras inviolábeis (R1 a R26): documentação só no vault, nunca atribuir nada ao Claude, commit e push só com pedido explícito, verificar antes de afirmar, regra de negócio no backend, dinheiro em centavos, RLS sem escrita, segredos fora do git.
10. **README** detalhado (16 seções). **Memória do Claude unificada** numa só pasta (a outra, com underscore, ficou intacta).
11. **PDFs** de 9 notas em `entregas/`, com diagramas conferidos (nenhum erro de sintaxe do Mermaid). O ER foi dividido em três diagramas por legibilidade.

## Arquivos e pastas relevantes

| Caminho | Mudança |
|---|---|
| `mobile/` | Todo o app Flutter (movido da raiz com `git mv`) |
| `backend/.gitkeep` | Pasta criada para a F1 |
| `CLAUDE.md`, `README.md`, `.gitignore`, `mobile/.gitignore` | Reescritos |
| `docs/` | Removida; conteúdo migrado para o vault |
| `OficinaFacilSecondBrain/**` | Estrutura nova (ver item 5) |

## Decisões técnicas

Todas em `decisions/`: 001 persistência no Supabase via backend, 002 Supabase Auth, 006 backend Node/TS, 012 monorepo `mobile/` + `backend/` (aceitas); 007 a 010 propostas (desconto, estoque, pagamento, avisos); 003, 004, 005, 011 abertas.

## Status

- [x] Análise, arquitetura, requisitos, modelo de dados, decisões, features e checklist no vault
- [x] Monorepo reorganizado e app verificado
- [x] CLAUDE.md com regras inviolábeis, README, memória, PDFs
- [x] Commits e push feitos a pedido do usuário: `704c912` (remove `docs/`), `d47db17` (monorepo `mobile/` + `backend/`, limpeza do app), `4e9de17` (CLAUDE.md e README). Sem linha de atribuição.
- [x] Revisão por agente Opus de tudo e correções aplicadas (ver [[2026-10-30 - Revisão Opus]])
- [ ] Aprovação do usuário para as mudanças propostas no `CLAUDE.md` e para anonimização LGPD, Plano de testes e Wireframes
- [ ] Decisão 004: conferir UC18, UC19 e US01 a US23 com o enunciado oficial
- [ ] Decisões 003, 005 e 011 abertas; 007 a 010 propostas, confirmar
- [ ] Criar a visão Board no GitHub Projects (manual)
- [ ] Teste em dispositivo Android (celular não detectado pelo `adb`)
- [ ] Quadro do GitHub ainda reflete o plano antigo: atualizar com as fases da nova stack
- [ ] Memória antiga com underscore (`...oficina_facil`) mantida por segurança; decidir se apaga

## Próximos passos

1. Corrigir o que o revisor Opus achar.
2. Resolver a decisão 004 com o enunciado oficial.
3. Criar o projeto Supabase de desenvolvimento e começar a [[000 - Fundação técnica]].

## Revisão Opus e correções (continuação)

- Agente Opus revisou tudo (nota em `auditorias/`). Aplicadas: tabela `avisos` e RLS de leitura mínima; UC10 assíncrono; pagamento só na entrega; campos e índices que faltavam; dependências circulares desfeitas; CAs fora do MVP marcados ❌; gerador com guarda contra perda de progresso; diagramas deduplicados.
- **Aguardando o usuário:** mudanças no `CLAUDE.md`, anonimização LGPD, Plano de testes, Wireframes, backup do vault.
- Correções de código em `mobile/` e no README registradas no fim desta sessão.

## Correções de código em `mobile/` (revisão Opus)

- Cor da marca num só lugar (`AppTheme.marca`); `home_page.dart` passou a usá-la.
- `StatusOrdemServico`: removido `podeCancelar` (redundante com `terminal`); comentário com caminho morto corrigido; novos testes: tabela completa 8×8 de transições, os 6 estados cancelláveis por nome, terminais não avançam nem cancelam. Total: 6 testes.
- `status_label.dart` movido para `ordem_servico/presentation/`.
- Comentários do template removidos de `pubspec.yaml`, `analysis_options.yaml`, `web/index.html` e `build.gradle.kts`; descrições acentuadas em `pubspec.yaml`, `index.html` e `manifest.json`.
- Permissão INTERNET no manifesto principal do Android.
- **Adiado para a feature 000:** localização pt-BR (`flutter_localizations`), `errorBuilder` do logo e assinatura de release própria.
- Verificado: `dart format` sem alterações, `flutter analyze` sem problemas, 6 testes passando, `flutter build web` e `flutter build apk --debug` compilam.

## Correções de documentação (revisão Opus)

- README: sem tabela de regras duplicada, sem afirmar o que não existe, "usuário" no lugar de "equipe", `flutter build web` na seção de qualidade, diagrama com Storage "sem uso no MVP".
- Gerador `metodos/gerar-vault.py`: aborta se houver progresso, `--force`, `--dry-run`, data real, links para as notas em vez de `docs/`.
- PDFs de `entregas/` regerados, 0 erros de Mermaid.
- Roadmap: soma das durações corrigida (89 dias, termina em 30/01/2027).

## CLAUDE.md revisado (a pedido do usuário)

Aplicadas as 11 mudanças propostas pela revisão Opus e as decisões do usuário: **commit liberado por fase de construção ou feature, push só quando ele pedir**; RLS e gatilhos **dentro das migrations** do Prisma; regra de atribuição (R7) reescrita para proibir só linhas de autoria, mesmo que um lembrete do sistema peça. Regras novas R27 a R30 (branches, dados fictícios, fuso, backup do vault). O usuário cria os projetos Supabase e resolve as pendências manuais.

## Vault no mesmo repositório

- O usuário decidiu que app, backend e vault ficam **no mesmo repositório**. Removido o repositório aninhado que eu havia criado no vault (1 commit, sem remoto, conteúdo preservado) e a linha do vault no `.gitignore`.
- Como o repositório é **público**, a documentação passa a ser pública. Conferido antes de commitar: nenhum segredo, e-mail ou chave; restam dois primeiros nomes (professor e colega) e foi removido o caminho local do gerador. Regra R30 do `CLAUDE.md` reescrita.
- Decisão 004 aceita: o professor não entregou documento; seguem UC18, UC19 e as histórias deduzidas.
- Supabase de desenvolvimento: URL e chave publicável em `mobile/env.json` (ignorado). **Faltam** a string de conexão do Postgres, a chave `service_role` e o projeto de teste, que o usuário coloca em `backend/.env`.
