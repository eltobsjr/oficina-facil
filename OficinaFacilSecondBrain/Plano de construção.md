---
data: 2026-10-30
---

# Plano de construção (F2 a F9)

Detalhamento, por fase, do que construir no **backend** e no **app**: módulos, regras, telas, componentes, providers e testes. A especificação de cada item continua nas features (`features/`), em [[Casos de uso]], [[Modelo de dados]], [[Endpoints]] e [[Mapa de telas]]; esta nota só organiza a **ordem e a forma de construir**. Datas e durações em [[Roadmap]].

Proposta de construção: nomes de arquivos e componentes são o plano, não contrato. Se algo aqui contradisser as features, valem as features.

## Padrão de toda feature

**Backend** (`backend/src/modules/<módulo>/`): `schemas.ts` (Zod + OpenAPI), `repository.ts` (único lugar com Prisma), `service.ts` (regra e transação), `routes.ts` (`registrarRota` com `exigirPerfis`), `index.ts` (porta pública). Testes: unitário do serviço, HTTP por perfil (matriz de permissões) e integração no projeto de teste. Se mexe em tabela, migration nova do Prisma.

**App** (`mobile/lib/features/<feature>/`): `domain/` (entidades, contratos), `data/` (models JSON, repositório com `dio`), `presentation/` (páginas, widgets, providers Riverpod). Rota nova no `go_router` com o guarda de perfil. Cada tela trata os 4 estados: carregando, vazio, erro e sucesso. Testes: domínio, repositório com adaptador falso de `dio` e widget de cada página.

**Componentes compartilhados** (criados na primeira fase que precisa, reaproveitados depois):

| Componente | Primeira fase | Para quê |
|---|---|---|
| `AppShell` (menu por perfil, responsivo) | F2 | Layout: barra lateral no web largo, menu inferior no celular |
| `SessaoNotifier` e guarda de rotas | F2 | Quem está logado, qual perfil, redirecionamentos |
| `EstadoVazio`, `EstadoErro`, `Carregando` | F2 | Os 3 estados não felizes de toda tela |
| `ConfirmarDialog` | F2 | Ações que não se desfazem |
| `ListaPaginada` + busca | F2 | Listas com busca, filtro e rolagem infinita |
| Mapeador de erro da API para texto pt-BR | F2 | Traduz `codigo` do erro em mensagem humana |
| Máscaras e validadores (CPF/CNPJ, telefone, placa) | F3 | Campos de formulário |
| `SeletorCliente` | F3 | Buscar cliente (transferir veículo, abrir OS) |
| `CampoDinheiro` (digita em reais, guarda centavos) | F4 | Preços, custos, desconto, pagamento |
| `ChipStatusOs`, `CardOs`, regra `AcoesDaOs` (estado × perfil) | F5 | Mostrar estado e decidir quais botões aparecem |
| `SeletorPeca` / seletor de serviço | F5 | Orçamento e peças usadas |
| `LinhaDoTempo`, `SeletorPeriodo`, `CartaoMetrica` | F8 | Histórico e faturamento |

**Utilitários do backend** (criados quando a primeira feature precisa): `shared/validadores` (CPF/CNPJ com dígito verificador, placa), `shared/paginacao`, `shared/transacao`, `shared/supabase/admin` (chave de serviço), e `transicoes.ts` do módulo `ordens` (máquina de estados espelho de `StatusOrdemServico`).

## F2: Acesso e usuários (features 001 e 006)

**Backend**
- Cliente administrativo do Supabase (`shared/supabase/admin.ts`), só com a chave de serviço do `backend/.env`.
- Módulo `usuarios` (já tem `GET /me`) ganha: listar, criar, detalhar, alterar nome e perfil, redefinir senha, inativar, ativar.
- Criar usuário: cria a conta no Supabase Auth e o perfil; se o perfil falhar, desfaz a conta (compensação).
- Inativar: `perfis.ativo = false` **e** banir a conta no Auth. Nunca o último gerente ativo (409).
- Senha só trafega aqui e nunca é logada. Regras de senha mínimas no Zod.
- Seed do gerente inicial passa a rodar.
- Testes: serviço com cliente falso, permissões (atendente, mecânico e almoxarife recebem 403), e-mail duplicado (409), último gerente (409), integração com o projeto de teste.

**App**
- `SessaoNotifier` escuta `onAuthStateChange`, chama `GET /me` e guarda usuário e perfil. Credencial inválida mostra mensagem genérica; usuário desativado mostra "desativado".
- `go_router` com `redirect`: sem sessão vai ao login; cada rota só abre para os perfis do [[Mapa de telas]].
- **T01 Login:** e-mail, senha, "Entrar"; estados carregando, erro genérico e usuário desativado.
- **T02 Início:** substitui a tela atual; saudação com nome e perfil, atalhos conforme o perfil, "Sair" (US22).
- **T03 Lista de usuários:** busca, filtro por perfil e situação, chip "inativo", botão "Novo", pull-to-refresh.
- **T04 Formulário de usuário:** nome, e-mail, perfil, senha inicial (só ao criar); ações redefinir senha, inativar e reativar, cada uma com confirmação; erros "e-mail já existe" e "último gerente".

**Pronto quando (M1):** o gerente entra no web e no Android, cria um usuário de cada perfil, cada um entra vendo só o seu menu, e um usuário inativado não consegue entrar.

## F3: Clientes e veículos (002 e 003)

**Backend**
- `shared/validadores`: CPF e CNPJ com dígito verificador, placa (padrão antigo e Mercosul) e normalização. Testados com valores fictícios.
- O log da API passa a registrar só o **caminho**, sem a query string, para a busca por documento não vazar dado pessoal.
- Módulo `clientes`: listar com busca por nome ou documento, criar, detalhar, alterar, inativar. Documento duplicado devolve 409 com o id do cadastro existente. Inativar com OS ativa devolve 409.
- Módulo `veiculos`: listar do cliente, criar, buscar por placa, detalhar, alterar, transferir de dono e inativar. Placa duplicada devolve 409 com o veículo existente. Importa `clientes` só pelo `index.ts`.
- Testes: vetores de CPF/CNPJ/placa, duplicidade, validações de campo, permissões, integração.

**App**
- Campos com máscara e validação local: `CampoDocumento`, `CampoTelefone`, `CampoPlaca`. `SeletorCliente`.
- **T05 Lista de clientes:** busca por nome ou documento, nome, documento e telefone por linha.
- **T06 Formulário de cliente:** nome, documento, telefone, e-mail, endereço; erro de duplicado oferece "abrir o existente"; inativar com confirmação.
- **T07 Veículos do cliente e formulário:** lista por cliente; formulário com placa, marca, modelo, ano, cor, quilometragem; transferir de dono; inativar.

**Pronto quando:** o atendente cadastra cliente e veículo, o duplicado é recusado mostrando o existente, e o histórico fica com o dono anterior numa transferência.

## F4: Catálogos e estoque (005, 004 e 018)

**Backend**
- Módulo `servicos`: listar (ativos para o orçamento), criar, alterar, inativar. Valor maior que zero. Mudar o preço não afeta orçamentos já montados.
- Módulo `pecas`: listar (com `abaixoDoMinimo`), criar com saldo zero, alterar sem tocar o saldo, inativar.
- Entrada no estoque: numa transação, soma o saldo e grava a movimentação `ENTRADA` com custo e nota; `GET` do razão por peça.
- O `index.ts` de `pecas` já exporta `baixar(tx, …)` e `estornar(tx, …)` (usados nas fases F6 e F7), com `UPDATE … WHERE saldo >= q`.
- Testes: concorrência (duas baixas simultâneas nunca deixam saldo negativo), saldo após entradas, quantidade inválida, alerta de estoque baixo.

**App**
- `CampoDinheiro`: o usuário digita em reais, o app guarda centavos.
- **T08 Lista de serviços** e **T09 Formulário de serviço:** descrição, valor, tempo estimado; inativar e reativar.
- **T10 Lista de peças:** destaque e filtro "estoque baixo".
- **T11 Formulário de peça:** código, descrição, preço, estoque mínimo; saldo só para leitura.
- **T12 Entrada no estoque:** quantidade, custo unitário, nota; mostra saldo atual e novo; histórico de movimentações abaixo.

**Pronto quando (M2):** o gerente mantém os serviços, o almoxarife mantém as peças e dá entrada, e o saldo bate com o razão.

## F5: Abrir, diagnosticar e orçar (007, 008, 009 e 010)

**Backend**
- Migration: valor `DESCONTO_DECIDIDO` no enum de avisos.
- Módulo `ordens`: `transicoes.ts` (máquina de estados, grava `historico_transicoes` e só muda se o estado de origem ainda for o esperado, o que barra dois cliques simultâneos).
- **007:** criar OS (cliente e veículo ativos, veículo sem OS ativa, queixa obrigatória, histórico `null → ABERTA`); lista simples e detalhe composto; o mecânico recebe a fila da etapa e o detalhe **sem documento e telefone do cliente**.
- **008:** rascunho do diagnóstico (`finalizado = false`) e diagnóstico final (`ABERTA → DIAGNOSTICADA`, grava o mecânico).
- **009:** gravar itens e desconto só em `DIAGNOSTICADA` (copia o preço atual para o item), recalcular subtotal e total, confirmar (`→ AGUARDANDO_APROVACAO`). Acima de 10% (`desconto*100 > subtotal*10`) só confirma com autorização aprovada e válida.
- **010:** solicitação de desconto, lista para o gerente e decisão com o **JWT do próprio gerente** (aprova valor igual ou menor, ou recusa); a autorização perde a validade se subtotal ou desconto mudarem.
- Módulo `avisos`: `GET /avisos`, marcar como lido, e função `criarAviso` exportada pelo `index.ts`. A solicitação avisa os gerentes; a decisão avisa o atendente.
- Testes: máquina de estados (toda a tabela), fronteira de 10% (exatamente 10% passa, 10,01% não), dois diagnósticos simultâneos (só um vale), matriz de permissões por endpoint, invalidação da autorização.

**App**
- `ChipStatusOs`, `CardOs`, regra `AcoesDaOs` (estado × perfil → botões), `SeletorPeca` e seletor de serviço.
- **T13 Abrir OS:** escolher cliente, escolher ou cadastrar veículo, queixa, quilometragem (vem do veículo); veículo com OS ativa mostra o erro com link para ela.
- **T14 Lista de OS:** atendente e gerente veem tudo com filtro de estado; o mecânico vê abas "Para diagnosticar", "Para executar" e "Em execução".
- **T15 Detalhe da OS:** cabeçalho com número, estado, cliente e veículo; seções queixa, diagnóstico, orçamento; barra de ações que muda por estado e perfil.
- **T16 Diagnóstico:** texto, "salvar rascunho", "finalizar diagnóstico".
- **T17 Orçamento:** adicionar serviços e peças com quantidade, desconto em reais com o percentual calculado ao vivo, totais, aviso de peça sem saldo; acima de 10% mostra "Pedir autorização" e o estado do pedido; "Confirmar" só habilita quando válido.
- **T18 Solicitações de desconto (Gerente):** abas pendentes e decididas; cada cartão com OS, cliente, subtotal, desconto e percentual; aprovar (com valor) ou recusar.
- **T24 Notificações:** lista de avisos com ícone por tipo e lido ou não, contador no menu, atualização por Realtime (canal da tabela `avisos`) e toque que abre a OS ou a solicitação.

**Pronto quando (M3):** atendente abre OS, mecânico diagnostica, atendente orça; desconto acima de 10% passa pelo gerente com avisos nos dois sentidos.

## F6: Aprovação e execução (011, 012 e 013)

**Backend**
- **011:** `POST /os/:id/aprovacao` com resultado, canal (balcão ou telefone) e motivo. Aprovar leva a `APROVADA`; recusar exige motivo e leva a `CANCELADA`. O orçamento fica imutável em `AGUARDANDO_APROVACAO` (alterar devolve 409).
- **012:** iniciar execução (`APROVADA → EM_EXECUCAO`, grava início) e observações de andamento.
- **013:** lançar peça usada (só `EM_EXECUCAO`): usa `pecas.baixar(tx)`; sem saldo devolve 409 e **grava o aviso** `SALDO_INSUFICIENTE` para o almoxarife fora da transação desfeita; peça fora do orçamento pede confirmação explícita. Remover lançamento faz o estorno (`ESTORNO` no razão).
- Fora do MVP, por decisão aberta: ajuste do orçamento e serviço extra (decisão 003).
- Testes: aprovar e recusar, orçamento imutável, baixa e estorno de estoque, **concorrência** na mesma peça, aviso de saldo.

**App**
- **T19 Aprovação:** resumo do orçamento, "Cliente aprovou" e "Cliente recusou", canal, motivo obrigatório na recusa, confirmação.
- **T20 Execução e peças usadas:** botão "Iniciar execução"; lista de peças usadas com valor; "Lançar peça" (busca com saldo visível, quantidade; fora do orçamento abre confirmação); remover lançamento com confirmação; observações em ordem cronológica.
- **T15:** passa a mostrar peças usadas e observações.

**Pronto quando:** o cliente decide, o mecânico executa e lança peças, e o saldo cai e volta corretamente.

## F7: Concluir, entregar e cancelar (014, 015 e 017)

**Backend**
- **014:** concluir (`EM_EXECUCAO → CONCLUIDA`, grava a hora e cria o aviso `OS_CONCLUIDA` para quem abriu a OS).
- **015:** `POST /os/:id/entregar` com `pagamentos[]` (forma e valor). Exige OS `CONCLUIDA` e **soma igual ao total** (a menos ou a mais é recusada); grava os pagamentos, leva a `ENTREGUE`, grava data e quem entregou, tudo numa transação.
- **017:** cancelar com motivo obrigatório, em qualquer estado antes da entrega, só atendente e gerente. Estorna as peças lançadas na **mesma transação** (`pecas.estornar(tx)`), exceto as marcadas "não devolver" com motivo. `ENTREGUE` e `CANCELADA` recusam (409).
- Testes: soma menor, igual e maior; várias formas; cancelar a partir de cada um dos 6 estados; estorno e "não devolver".

**App**
- **T20:** botão "Concluir OS" com confirmação.
- **T21 Pagamento e entrega:** total em destaque; linhas de pagamento (forma e valor, adicionar e remover); "faltam R$ X" ou "sobram R$ X" ao vivo; "Entregar" só habilita com a soma igual ao total.
- **T22 Cancelar OS (diálogo):** motivo, lista das peças lançadas com "não devolver" e motivo, confirmação; só aparece para atendente e gerente.

**Pronto quando (M4):** uma OS percorre de `ABERTA` a `ENTREGUE` pelo app, e outra é cancelada devolvendo as peças. O `smoke.sh` passa a cobrir o ciclo completo.

## F8: Consulta, histórico e faturamento (016 e 019)

**Backend**
- **016:** filtros em `GET /os` (número, estado, cliente, placa, período) com paginação e ordenação; o mecânico continua só na fila da etapa. `GET /os/:id/historico`.
- **019:** `GET /faturamento?de&ate`, agregado **no servidor**: soma dos pagamentos das OS entregues no período pela data de entrega, em America/Sao_Paulo; quantidade de OS; ticket médio; detalhamento por forma de pagamento. Período vazio devolve zeros.
- Testes: filtros combinados, período sem OS, fronteiras de data e fuso, ticket médio.

**App**
- **T14 completa:** barra de filtros (número, estados, placa, cliente, período), chips dos filtros ativos, "limpar filtros", rolagem infinita.
- **T15:** seção "Histórico" com a linha do tempo (estado, usuário, data e hora, motivo).
- **T23 Faturamento:** período (hoje, 7 dias, mês, personalizado); cartões de total, quantidade de OS e ticket médio; detalhe por forma de pagamento; lista das OS do período; estado vazio com zero.

**Pronto quando:** consultar achar qualquer OS por qualquer filtro, e o faturamento bater com os pagamentos.

## F9: Acabamento e entrega final (020)

- **Android real:** testar todas as telas no celular (360 dp), teclado e rotação; assinatura de release com chave própria.
- **Web:** layout responsivo (barra lateral em telas largas); `--base-href` conforme a hospedagem.
- **Acessibilidade e idioma:** contraste AA, rótulos semânticos, datas e moeda em pt-BR.
- **Backend no ar:** publicar a imagem Docker; API de demonstração com a string do **pooler**; projeto Supabase de produção separado com as migrations; CORS com a origem do web.
- **Distribuição:** web hospedado e APK gerado.
- **Teste de ponta a ponta:** `smoke.sh` do ciclo completo com usuários de cada perfil.
- **Fechamento:** documentos e PDFs regenerados, changelog no vault, versão e tag.
