# 6a809b9 — Tela inicial com logo, nome e etapas da OS

**Data:** 2026-10-29
**Autor:** eltobsjr
**Hash completo:** 6a809b9e69defcb39305d5d321c543e01b7b95a5

## O que este commit fez

Trocou a tela em branco por uma tela inicial centralizada, com degradê azul da marca, logo, nome, subtítulo e as 7 etapas do fluxo da OS como etiquetas, lidas do `StatusOrdemServico`. O logo entrou como asset PNG, sem dependência nova. O rótulo em português de cada estado fica na camada de apresentação, para o domínio continuar sem texto de interface.

## Arquivos alterados

| Arquivo | Tipo de mudança | Linhas |
|---------|-----------------|--------|
| `lib/features/home/presentation/pages/home_page.dart` | modificado | +58 -2 |
| `lib/features/home/presentation/widgets/status_chips.dart` | adicionado | +46 |
| `lib/features/home/presentation/widgets/status_label.dart` | adicionado | +14 |
| `assets/images/logo.png` | adicionado | binário |
| `pubspec.yaml` | modificado | +3 |
| `test/app_test.dart` | modificado | +1 |
