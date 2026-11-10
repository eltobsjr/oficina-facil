---
data: 2026-11-09
status: aceita
---

# 013 — Design system da interface

## Contexto

O app nasceu em Material 3 com semente `#1F4E79` (regra R26 do `CLAUDE.md`). O usuário pediu um design system próprio, com telas tipo "tiles", ação em azul único e botões em pílula, e mandou aplicá-lo às telas.

## Alternativas consideradas

- Manter o Material 3 com a semente `#1F4E79`.
- Adotar o design system novo só nos desenhos e deixar o código como está.
- Adotar o design system novo também no código das telas que já existem.

## Decisão

Adotar o design system novo na interface, no código das 10 telas que já existem e nas futuras. Em 2026-11-09 o usuário escreveu no chat para subverter a regra R26 nesta mudança. Vale para este pedido; o texto da R26 no `CLAUDE.md` não foi alterado, e só o usuário decide se ela é reescrita.

- Azul de ação `#0066cc` é a única cor interativa da interface.
- O logo e o ícone do app continuam na cor da marca `#1F4E79` (`AppTheme.marca`).
- Superfícies claras `#ffffff` e `#f5f5f7`, tile escuro `#272729`, barra global preta.
- Botão de ação em pílula; cartões de 18 px com filete; campos de 8 px; sem sombra.
- Erro usa `danger` (`#b3261e`) sobre `danger-surface`: acréscimo nosso, a referência não define erro.
- Texto secundário usa `#333333`. O cinza `#7a7a7a` fica só para desabilitado, porque não passa AA.
- Fonte do sistema, sem dependência nova.

Tokens, componentes e guia: design system "OficinaFácil" (artifact). Telas desenhadas: canvas "Telas OficinaFácil".

## Consequências

- `AppTheme` deixa de usar `ColorScheme.fromSeed`; os testes de tema e de telas são ajustados, sem enfraquecer.
- O menu inferior vira barra de abas própria do design system; o vault define as telas por perfil (RN09), não a barra.
- Não há tema escuro no design system: o app passa a ser só claro até alguém definir um.
- Se a R26 for reescrita, o `CLAUDE.md` precisa ser alterado pelo usuário.
