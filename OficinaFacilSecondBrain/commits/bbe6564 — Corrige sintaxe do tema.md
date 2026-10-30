# bbe6564 — Corrige sintaxe do tema

**Data:** 2026-10-29
**Autor:** eltobsjr
**Hash completo:** bbe65648e982650b27bc668fe198d7f7e6aa73ab

## O que este commit fez

Corrigiu um erro de sintaxe que o commit anterior deixou em `app_theme.dart`: um comentário foi parar antes do `;`, e o build web falhava. Foi achado só porque o `flutter build web` rodou depois do push; vale rodar `analyze`, `test` e `build` antes de commitar.

## Arquivos alterados

| Arquivo | Tipo de mudança | Linhas |
|---------|-----------------|--------|
| `lib/core/theme/app_theme.dart` | modificado | +1 -1 |
