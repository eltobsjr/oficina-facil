# CLAUDE.md — OficinaFácil

## 1. Sempre ler a memória antes de começar

Ao iniciar qualquer conversa neste projeto:

1. Leia o índice de memória: `~/.claude/projects/-home-eltobsjr-dev-academico-oficina_facil/memory/MEMORY.md`
   É um índice — siga os links para os arquivos relevantes à tarefa atual.

2. Leia o devtrack mais recente:
   `ls /home/eltobsjr/dev/academico/oficina_facil/OficinaFacilSecondBrain/devtrack/ | sort | tail -1`
   e leia o arquivo retornado. Isso garante continuidade: o que foi feito,
   decisões tomadas e pendências abertas na última sessão.

## 2. Stack e tecnologias

- Flutter 3.44 / Dart 3.12 (web e Android)
- Riverpod (estado) e go_router (navegação)
- Material 3, com cor da marca `#1F4E79`
- Diagramas em Mermaid

## 3. Estrutura do projeto

- `lib/core/`: tema e roteamento
- `lib/features/<feature>/{domain,data,presentation}`: Clean Architecture por feature
- `docs/`: diagramas (Mermaid) e identidade visual (`docs/branding/`)
- `assets/images/`: logo usado pelo app
- `test/`: testes de domínio e de widget

## 4. Documentação

Toda documentação fica no vault: OficinaFacilSecondBrain/
Logs de sessão: OficinaFacilSecondBrain/devtrack/
Formato dos logs: YYYY-MM-DD - Título.md

## 5. Regras de desenvolvimento

- Nunca adicionar `Co-Authored-By` do Claude, nem outra atribuição ao Claude, em commits ou PRs.
- Mensagens de commit em português.
- Código limpo, sem arquivos ou dependências sem uso.
- Camada `domain` nunca importa Flutter nem as camadas `data` e `presentation`.
- Criar as camadas `data` e `usecases` só quando uma regra de negócio exigir.
- Commit e push só quando o usuário pedir.

## 6. Fluxo de trabalho

1. Ler memória e devtrack mais recente
2. Entender o contexto antes de implementar
3. Implementar, rodando `flutter analyze` e `flutter test`
4. Atualizar devtrack ao final da sessão
