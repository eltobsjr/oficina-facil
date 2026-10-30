# 37f5333 — Estrutura inicial Flutter (web e Android) com Clean Architecture

**Data:** 2026-10-29
**Autor:** eltobsjr
**Hash completo:** 37f5333f735e7e406786509bfe4cbad21e1dc3c5

## O que este commit fez

Criou o projeto Flutter com alvos web e Android e a estrutura de Clean Architecture por feature, com Riverpod e go_router. Entrou o `StatusOrdemServico`, que modela os 8 estados da OS, com testes. Também trouxe `docs/diagramas.md` com os diagramas Mermaid e o primeiro conjunto de conceitos de logo.

## Arquivos alterados

| Arquivo | Tipo de mudança | Linhas |
|---------|-----------------|--------|
| `lib/main.dart`, `lib/app.dart` | adicionado | +28 |
| `lib/core/router/app_router.dart`, `lib/core/theme/app_theme.dart` | adicionado | +39 |
| `lib/features/ordem_servico/domain/entities/status_ordem_servico.dart` | adicionado | +33 |
| `lib/features/home/presentation/pages/home_page.dart` | adicionado | +13 |
| `test/status_ordem_servico_test.dart`, `test/app_test.dart` | adicionado | +61 |
| `docs/diagramas.md` | adicionado | +118 |
| `docs/branding/conceitos-logo.png` | adicionado | binário |
| `README.md`, `pubspec.yaml` e arquivos gerados de `android/` e `web/` | adicionado | gerado pelo `flutter create` |
