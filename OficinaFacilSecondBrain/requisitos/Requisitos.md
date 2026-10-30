---
data: 2026-10-30
---

# Requisitos — OficinaFácil

Requisitos funcionais (RF), não funcionais (RNF) e glossário. A rastreabilidade RF → UC → US → feature → API → tela → tabela
está em [[Rastreabilidade]], gerada da mesma fonte das features.

Regras de negócio (RN01 a RN09): [[Casos de uso]], seção 1.2.
Marcação ⚠️: item deduzido, a conferir com o enunciado oficial (decisão D4 em [[00 - Índice de decisões]]).

## 1. Requisitos funcionais

Um RF por caso de uso, com o mesmo número (RF01 = UC01), mais os complementares.

| RF | O sistema deve | UC | Ator |
|---|---|---|---|
| RF01 | Autenticar o usuário e liberar as funções do seu perfil | UC01 | Todos |
| RF02 | Cadastrar, consultar, alterar e inativar clientes | UC02 | Atendente |
| RF03 | Cadastrar, consultar, alterar, transferir e inativar veículos | UC03 | Atendente |
| RF04 | Cadastrar, consultar, alterar e inativar peças | UC04 | Almoxarife |
| RF05 | Cadastrar, consultar, alterar e inativar serviços | UC05 | Gerente |
| RF06 | Criar usuários, definir perfil, redefinir senha e inativar | UC06 | Gerente |
| RF07 | Abrir uma OS para um veículo, com queixa e quilometragem | UC07 | Atendente |
| RF08 | Registrar o diagnóstico e levar a OS a `DIAGNOSTICADA` | UC08 | Mecânico |
| RF09 | Montar o orçamento (serviços, peças, desconto) e levar a OS a `AGUARDANDO_APROVACAO` | UC09 | Atendente |
| RF10 | Receber a solicitação do atendente e registrar a decisão do gerente sobre desconto acima de 10% | UC10 | Atendente, Gerente |
| RF11 | Registrar a aprovação ou a recusa do cliente | UC11 | Atendente |
| RF12 | Iniciar a execução de uma OS aprovada | UC12 | Mecânico |
| RF13 | Registrar as peças usadas e baixar o estoque | UC13 | Mecânico |
| RF14 | Concluir a OS | UC14 | Mecânico |
| RF15 | Registrar os pagamentos e entregar o veículo, numa única transação | UC15 | Atendente |
| RF16 | Consultar OS por número, cliente, placa, estado e período | UC16 | Atendente, Gerente, Mecânico (fila restrita) |
| RF17 | Cancelar uma OS antes da entrega, com motivo | UC17 | Atendente, Gerente |
| RF18 | Registrar a entrada de peças no estoque ⚠️ | UC18 | Almoxarife |
| RF19 | Apresentar o faturamento por período ⚠️ | UC19 | Gerente |
| RF20 | Gravar e exibir avisos dentro do app: OS concluída (atendente), saldo insuficiente (almoxarife) e desconto pendente (gerente) e desconto decidido (atendente) ⚠️ | UC10, UC13, UC14 | Atendente, Almoxarife, Gerente |
| RF21 | Guardar e exibir o histórico de transições da OS ⚠️ | UC16 | Atendente, Gerente |
| RF22 | Destacar peças abaixo do estoque mínimo ⚠️ | UC04 | Almoxarife |
| RF23 | Encerrar a sessão do usuário ⚠️ | UC01 | Todos |

## 2. Requisitos não funcionais

As metas numéricas são **propostas** para guiar testes; ajustar quando o enunciado disser o contrário.

| RNF | Categoria | Requisito | Verificação |
|---|---|---|---|
| RNF01 | Desempenho | Listagens e consultas respondem em até 2 s para 95% das chamadas, com até 10 mil OS e 50 mil movimentações de estoque | Teste de carga simples com dados de seed |
| RNF02 | Desempenho | Ações de escrita (lançar peça, mudar estado) respondem em até 1 s no mesmo cenário | Teste de rota |
| RNF03 | Integridade | Cada caso de uso que altera mais de uma tabela roda numa **transação**; nunca deixa a OS e o estoque inconsistentes | Teste de serviço com falha injetada |
| RNF04 | Integridade | Saldo de peça nunca fica negativo, nem com duas requisições simultâneas | Teste de concorrência |
| RNF05 | Segurança | Todas as rotas, exceto `/health`, exigem JWT válido; perfil sem permissão recebe `403` (RN09) | Testes de rota por perfil |
| RNF06 | Segurança | O app não lê nem escreve no banco fora da API: RLS sem política de escrita e sem leitura, exceto os `avisos` do próprio usuário | Teste com a chave publicável |
| RNF07 | Segurança | Nenhuma chave de serviço ou senha em código versionado, no app ou em log; o Pino redige `authorization`, `senha` e `password` | Revisão, `git log -S` e teste de log |
| RNF08 | Segurança | Comunicação por HTTPS em produção; rate limit nas rotas de escrita e de autenticação | Teste de rota |
| RNF09 | Privacidade (LGPD) | Coletar só o necessário de cliente (nome, documento, telefone, e-mail, endereço); o mecânico não recebe documento nem telefone; busca por documento sem PII em query string; seed e testes só com dados fictícios; projeto Supabase em `sa-east-1`. Anonimização a pedido do titular **ainda sem caso de uso** (aguarda aprovação de escopo) | Revisão de DTOs e de logs |
| RNF10 | Auditoria | Toda mudança de estado da OS, movimentação de estoque e pagamento guarda autor e data/hora, e não pode ser alterada | Teste do gatilho de só inserção |
| RNF11 | Usabilidade | Telas funcionam de 360 px (celular) a desktop; mensagens de erro em português, claras e sem códigos internos | Teste de widget com tamanhos diferentes |
| RNF12 | Acessibilidade | Contraste mínimo AA nas cores da marca; rótulos semânticos em campos e botões | Revisão com ferramenta de contraste |
| RNF13 | Compatibilidade | Web: Chrome, Edge e Firefox atuais. Android: a versão mínima do Flutter 3.44 ⚠️ | Teste manual em dispositivo |
| RNF14 | Disponibilidade | O sistema exige conexão; sem rede, o app mostra aviso e não perde dados já enviados | Teste manual |
| RNF15 | Observabilidade | Logs estruturados (Pino) com identificador da requisição, sem dados pessoais | Revisão de logs |
| RNF16 | Manutenibilidade | Camada `domain` sem importar Flutter; módulos do backend só se falam por `index.ts`; regras de negócio cobertas por teste automatizado | Teste de arquitetura e cobertura das regras |
| RNF17 | Manutenibilidade | `flutter analyze`, `flutter test`, `npm run lint`, `typecheck` e `npm test` passam antes de cada commit | Execução local e CI |
| RNF18 | Portabilidade | O backend roda em container Docker (só o backend; o banco nunca roda em container); o app compila para web e Android | `docker build`, `flutter build web`, `flutter build apk` |
| RNF19 | Documentação | A API tem contrato OpenAPI gerado do código, sempre atual | `openapi:gerar` no CI |
| RNF20 | Idioma | Interface, mensagens, documentação e commits em português do Brasil | Revisão |

## 3. Glossário

| Termo | Significado |
|---|---|
| OS | Ordem de serviço: registro que acompanha um veículo na oficina |
| **OS ativa** | OS em qualquer estado, exceto `ENTREGUE` e `CANCELADA`. É o termo usado em todos os documentos (substitui "em aberto") |
| Estado | Posição da OS no ciclo: `ABERTA`, `DIAGNOSTICADA`, `AGUARDANDO_APROVACAO`, `APROVADA`, `EM_EXECUCAO`, `CONCLUIDA`, `ENTREGUE`, `CANCELADA` |
| Estado terminal | `ENTREGUE` ou `CANCELADA`: a OS não muda mais |
| Perfil | Papel do usuário: Atendente, Mecânico, Almoxarife ou Gerente |
| Diagnóstico | Parecer técnico do mecânico sobre o defeito |
| Orçamento | Lista de serviços e peças com valores, mais o desconto, montada depois do diagnóstico |
| Subtotal | Soma de quantidade × valor unitário dos itens do orçamento |
| Desconto | Valor em centavos abatido do subtotal; vale para o orçamento inteiro |
| Autorização de desconto | Solicitação do atendente decidida pelo gerente (`PENDENTE`, `APROVADA`, `RECUSADA`) para desconto acima de 10% do subtotal; perde a validade se o subtotal ou o desconto mudar |
| Peça usada | Peça efetivamente consumida numa OS, que baixa o estoque |
| Saldo | Quantidade atual de uma peça em estoque |
| Estoque mínimo | Saldo abaixo do qual a peça é destacada para reposição |
| Movimentação de estoque | Registro de entrada, baixa ou estorno; o saldo resulta delas |
| Estorno | Devolução ao estoque de uma peça lançada |
| "Não devolver" | Marca, no cancelamento, de uma peça já aplicada no veículo que não volta ao estoque; exige motivo |
| Almoxarifado | Estoque físico de peças da oficina |
| Fila do mecânico | Lista de OS que o mecânico enxerga: as em `ABERTA`, `APROVADA` e `EM_EXECUCAO` |
| Rascunho | Diagnóstico salvo sem finalizar (`finalizado = false`); a OS continua `ABERTA` |
| Razão do estoque | Conjunto de movimentações (entrada, baixa, estorno) de que o saldo resulta |
| Observação | Anotação do mecânico sobre o andamento da execução |
| Canal | Forma pela qual o cliente respondeu ao orçamento: balcão ou telefone |
| Aviso | Notificação gravada para um perfil (OS concluída, saldo insuficiente, desconto pendente) |
| Pagamento | Forma e valor recebidos de uma OS; só são gravados no ato da entrega, e a soma é igual ao total da OS |
| Faturamento | Soma dos pagamentos das OS entregues no período, pela data de entrega, no fuso America/Sao_Paulo |
| Ticket médio | Faturamento dividido pela quantidade de OS entregues no período |
| Centavos | Unidade em que todo valor monetário é guardado (inteiro) |
| RLS | Row Level Security: política do Postgres que decide quem lê e escreve cada linha |
| JWT / JWKS | Token de sessão do Supabase e o conjunto de chaves públicas que o backend usa para verificá-lo |
