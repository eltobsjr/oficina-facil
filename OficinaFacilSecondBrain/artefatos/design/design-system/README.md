# OficinaFácil

Interface quieta, ação em azul. Sistema de design do app de ordens de serviço da oficina: o conteúdo é o protagonista e a interface some ao redor dele.

## Fundamentos de conteúdo

- Português do Brasil, em sentence-case. Botões dizem o que acontece: "Salvar cliente", "Abrir OS", "Entregar veículo". A ação mantém o mesmo nome no fluxo inteiro.
- Erro explica o que houve e como corrigir, sem código interno e sem pedir desculpas: "Este documento já está cadastrado."
- Vazio é um convite a agir, não um enfeite.
- Dinheiro em reais com vírgula (R$ 1.234,50), números tabulares nas colunas. Datas como 03/11 às 09:12.
- Sem emoji. Sem pontos de exclamação.

## Fundamentos visuais

- **Uma cor de ação.** `primary` (#0066cc) é a única cor interativa. Não existe segunda cor de destaque.
- **Superfícies que se alternam.** Fundo `canvas-parchment`, cartões `canvas`, e tiles escuros `surface-tile-1` para o resumo que importa (total, valor a receber). A troca de cor faz o papel de divisor, não uma linha.
- **Tipografia.** Fonte do sistema (SF Pro onde existir; Inter fora dele). Corpo em 17px. Títulos em peso 600 com espaçamento negativo. A escala é 300, 400, 600 e 700; o 500 não existe.
- **Formas.** Pílula (`radius-pill`) para tudo que é ação; 18px (`radius-lg`) para cartões; 8px (`radius-sm`) para campos e botão utilitário. Nada no meio.
- **Sem sombra, sem degradê.** A elevação vem da troca de superfície e do desfoque da barra fixa. A única sombra do sistema é a de fotografia de produto.
- **Toque.** Alvos de 44 x 44px no mínimo. Pressionar encolhe o botão para 95%.
- **Barras.** Barra global preta de 44px no topo; abaixo, a sub-barra fosca com o nome da seção e a ação principal; na base, a barra de abas fosca.

## Iconografia

Ícones de traço fino (1,8px), cantos arredondados, `currentColor`. Nunca emoji. Ícones só de ícone levam `aria-label`.

## Regras de uso

- Interativo é `primary`. Sobre tile escuro, links usam `primary-on-dark`, nunca o azul de ação.
- Texto secundário sobre claro é `ink-muted-80`. `ink-muted-48` só para desabilitado: não passa AA.
- Cartão é `canvas` com filete `hairline` e `radius-lg`. Sem sombra.
- Botão de ação principal é `radius-pill` em `primary` com `on-primary`. Um por tela.
- Tile escuro leva `body-on-dark` e `body-muted`; o botão azul continua valendo sobre ele.
- Erro usa `danger` e `danger-surface`. Esses dois são acréscimos nossos: a referência não define erro.

## Onde isto difere do app hoje

O app em código usa Material 3 com semente #1F4E79 (regra R26 do projeto). Este sistema usa o azul de ação #0066cc e outra gramática de componentes. O logo continua na cor da marca #1F4E79. Antes de levar isto ao código é preciso decidir o que vale para a interface: a cor de ação, o tema e a regra R26.

## Componentes

Botão, Tile, Cartão e item de lista, Navegação, Campo e Chip. Cada um tem guia e prévia viva.
