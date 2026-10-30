# 108a0af — Logo (porca com check), ícones web/Android e identidade visual

**Data:** 2026-10-29
**Autor:** eltobsjr
**Hash completo:** 108a0afbc0428c40bec8977e9a45a62e20c15341

## O que este commit fez

Aplicou a identidade visual: adicionou o kit do logo em `docs/branding/logo/` (símbolo, variações preta, branca e azul, ícone do app e favicons) e trocou os ícones padrão do Flutter pelos da marca, no web e nos 5 tamanhos do Android. Também ajustou o nome "OficinaFácil" no manifesto, no `index.html` e no Android, e a cor da marca no tema.

## Arquivos alterados

| Arquivo | Tipo de mudança | Linhas |
|---------|-----------------|--------|
| `docs/branding/logo/*` | adicionado | SVGs, PNGs, favicon e manifesto |
| `android/app/src/main/res/mipmap-*/ic_launcher.png` | modificado | binário |
| `web/favicon.png`, `web/icons/*` | modificado | binário |
| `web/index.html`, `web/manifest.json`, `AndroidManifest.xml` | modificado | nome e cor |
| `lib/core/theme/app_theme.dart` | modificado | +1 -1 |
| `README.md` | modificado | +2 |
