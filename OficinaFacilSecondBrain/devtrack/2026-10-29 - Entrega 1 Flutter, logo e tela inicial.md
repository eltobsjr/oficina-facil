# 2026-10-29 — Entrega 1 Flutter, logo e tela inicial

## O que foi feito

1. **Entendimento da Entrega 1.** A partir do PDF de conferência, ficou claro o que o professor (Anthony) pede: tela em branco, repositório, anotações e diagrama, nome e ícone. O projeto é um sistema de oficina mecânica com 4 atores, 19 casos de uso e uma OS com 8 estados.
2. **Migração para Flutter.** O time decidiu abandonar Java/JavaFX e web puro em favor de Flutter, já que é um app. Criei o projeto para web e Android, com Clean Architecture por feature, Riverpod e go_router. O `StatusOrdemServico` modela o ciclo de vida da OS no domínio, com testes.
3. **Diagramas.** `docs/diagramas.md` ganhou casos de uso (como `flowchart`, porque o Mermaid não tem diagrama de casos de uso), estados da OS, camadas e pastas. UC18 e UC19 foram assumidos, porque o PDF só descreve até o UC17.
4. **Repositório.** Criado um repositório novo, hoje público, `eltobsjr/oficina-facil`, em vez de usar o `APS_projeto` do Roberto.
5. **Logo.** Instalei a skill `logo-design` e gerei 3 conceitos, depois 4 opções na segunda rodada. O usuário comparou e manteve a primeira escolha, a porca com check em `#1F4E79`. Apliquei o ícone no web (favicon, manifesto) e nos 5 tamanhos do Android, e o nome "OficinaFácil".
6. **Slides.** Apresentação de 6 telas com as entregas do dia, publicada como artefato.
7. **Tela inicial.** Troquei a tela em branco por uma tela centralizada com logo, nome, subtítulo e as 7 etapas da OS.
8. **Histórico limpo.** A pedido do usuário, removi o `Co-Authored-By` do Claude de 4 commits e reescrevi o histórico no GitHub (`--force-with-lease`).
9. **SecondBrain.** Configurei `CLAUDE.md`, este vault e a memória do Claude, e importei os 5 commits em `commits/`.

---

## Arquivos modificados

| Arquivo | Mudança |
|---|---|
| `lib/features/ordem_servico/domain/entities/status_ordem_servico.dart` | Estados da OS e transições, incluindo cancelamento antes da entrega |
| `lib/features/home/presentation/pages/home_page.dart` | Tela inicial centralizada com degradê, logo e etapas |
| `lib/features/home/presentation/widgets/status_chips.dart`, `status_label.dart` | Etiquetas das etapas e rótulos em português na camada de apresentação |
| `lib/core/router/app_router.dart`, `lib/core/theme/app_theme.dart` | Rotas e tema com a cor da marca |
| `docs/diagramas.md` | Quatro diagramas em Mermaid |
| `docs/branding/` | Kit do logo e folhas de conceitos |
| `web/*`, `android/app/src/main/res/mipmap-*` | Ícones e nome do app |
| `CLAUDE.md`, `.gitignore` | Regras do projeto e vault fora do git |

## Bugs corrigidos

### Bug — build web quebrado depois do push

**Problema:** `flutter build web` falhava com `Expected ';' after this`, e o commit já tinha ido para o GitHub.
**Causa:** um `sed` colocou o comentário `// cor da marca` antes do `;` em `app_theme.dart`.
**Correção:** `lib/core/theme/app_theme.dart` — o `;` voltou para antes do comentário (commit `bbe6564`). Lição: rodar `analyze`, `test` e `build web` antes de commitar, e não depois.

## Decisões técnicas

### Flutter em vez de Java
**Contexto:** o professor deixou a linguagem livre, e o time estava só em Java.
**Alternativas consideradas:** manter JavaFX desktop (como no PDF) ou migrar.
**Decisão:** Flutter com web e Android, decidido pelo time. O diagrama, os atores e as regras não dependem da linguagem e foram mantidos.

### Logo: porca com check
**Contexto:** o usuário achou a primeira escolha "fraca" e pediu opções.
**Alternativas consideradas:** boca de chave, F-chave, porca em fluxo e prancheta.
**Decisão:** manter a porca com check. O risco conhecido é lembrar um selo de "verificado" genérico.

### Vault fora do git
**Decisão:** `OficinaFacilSecondBrain/` está no `.gitignore`, como o setup do SecondBrain define. É documentação pessoal local e não vai para o GitHub.

## Status

- [x] Tela inicial, repositório, diagramas, nome e logo (Entrega 1)
- [x] Migração para Flutter, `analyze` limpo e 5 testes passando
- [x] App aberto no navegador e conferido (web)
- [x] Histórico do GitHub sem coautoria do Claude
- [x] SecondBrain configurado
- [ ] Commit e push da tela inicial já feitos; falta commitar `CLAUDE.md` e `.gitignore` (alterados agora)
- [ ] Testar em emulador ou dispositivo Android (só o web foi aberto)
- [ ] Conferir UC18 e UC19 com o documento oficial e trazer histórias de usuário (US01 a US23) para `docs/`
- [ ] Decidir se `docs/branding/opcoes-v2/` sai do repositório

## Próximos passos

1. Commitar `CLAUDE.md` e `.gitignore`, sem linha de coautoria, quando o usuário pedir.
2. Esperar a Entrega 2 do professor. A sugestão natural é autenticação com 4 perfis (UC01) e os cadastros (UC02 a UC06).
3. Ao implementar um caso de uso, criar a camada `data` e os `usecases` na feature correspondente.
