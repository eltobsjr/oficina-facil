# Histórias de usuário — OficinaFácil

Derivadas dos [casos de uso](casos-de-uso.md) e das regras de negócio (RN01 a RN09).

> **Atenção.** Os textos oficiais US01 a US23 do professor não estão no repositório. Esta lista
> tem 23 histórias montadas a partir dos casos de uso; a numeração e o texto podem diferir do
> documento oficial e devem ser conferidos. Histórias fora dos 19 casos originais (US12, US21,
> US22, US23) vêm de fluxos alternativos e estão marcadas com ⚠️.

Formato: **Como** `<ator>`, **quero** `<ação>`, **para** `<benefício>`. Critérios em
Dado / Quando / Então.

## Resumo

| US | Título | Ator | Caso de uso | Prioridade |
|---|---|---|---|---|
| US01 | Entrar no sistema | Todos | UC01 | Alta |
| US02 | Gerir clientes | Atendente | UC02 | Alta |
| US03 | Gerir veículos | Atendente | UC03 | Alta |
| US04 | Gerir peças | Almoxarife | UC04 | Média |
| US05 | Gerir serviços | Gerente | UC05 | Média |
| US06 | Gerir usuários | Gerente | UC06 | Alta |
| US07 | Abrir OS | Atendente | UC07 | Alta |
| US08 | Registrar diagnóstico | Mecânico | UC08 | Alta |
| US09 | Montar orçamento | Atendente | UC09 | Alta |
| US10 | Autorizar desconto acima de 10% | Gerente | UC10 | Média |
| US11 | Registrar aprovação do cliente | Atendente | UC11 | Alta |
| US12 ⚠️ | Registrar recusa do orçamento | Atendente | UC11 (FA1) | Média |
| US13 | Executar serviço | Mecânico | UC12 | Alta |
| US14 | Registrar peças usadas | Mecânico | UC13 | Alta |
| US15 | Concluir OS | Mecânico | UC14 | Alta |
| US16 | Entregar e registrar pagamento | Atendente | UC15 | Alta |
| US17 | Consultar OS | Atendente, Gerente | UC16 | Alta |
| US18 | Cancelar OS | Atendente, Gerente | UC17 | Média |
| US19 | Dar entrada no estoque | Almoxarife | UC18 | Média |
| US20 | Ver faturamento | Gerente | UC19 | Baixa |
| US21 ⚠️ | Ver alerta de estoque baixo | Almoxarife | UC04 (FA2) | Baixa |
| US22 ⚠️ | Sair do sistema | Todos | UC01 (FA1) | Baixa |
| US23 ⚠️ | Ver histórico de transições da OS | Atendente, Gerente | UC16 | Baixa |

## Acesso e cadastros

### US01 — Entrar no sistema
**Como** usuário (atendente, mecânico, almoxarife ou gerente), **quero** me autenticar com login e senha, **para** acessar apenas as funções do meu perfil.
- Dado um usuário ativo, quando informo credenciais corretas, então a sessão abre com o menu do meu perfil.
- Quando informo credenciais inválidas, então o acesso é negado com mensagem genérica.
- Dado um usuário inativo, então o sistema informa que ele está desativado.

### US02 — Gerir clientes
**Como** atendente, **quero** cadastrar, buscar, alterar e inativar clientes, **para** ter os dados à mão ao abrir uma OS.
- Quando cadastro um cliente com documento já existente, então o sistema recusa e mostra o cadastro atual.
- Dado um cliente com OS em aberto, então ele não pode ser inativado.
- O histórico de OS é mantido ao inativar.

### US03 — Gerir veículos
**Como** atendente, **quero** cadastrar veículos vinculados a um cliente, **para** abrir OS para o carro certo.
- Quando informo placa já cadastrada, então o sistema recusa e exibe o veículo existente.
- Quando informo placa em formato inválido, então o sistema recusa.
- Todo veículo pertence a um cliente.

### US04 — Gerir peças
**Como** almoxarife, **quero** manter o catálogo de peças com preço e estoque mínimo, **para** que orçamentos e consumo usem dados corretos.
- Código de peça é único.
- Preço menor ou igual a zero é recusado.
- O saldo só muda por registro de peças usadas (US14) e entrada no estoque (US19).

### US05 — Gerir serviços
**Como** gerente, **quero** manter o catálogo de serviços e seus valores, **para** padronizar os orçamentos.
- Valor menor ou igual a zero é recusado.
- Alterar o preço não muda orçamentos já montados.
- Serviço inativo não aparece em orçamentos novos.

### US06 — Gerir usuários
**Como** gerente, **quero** criar usuários e definir seu perfil, **para** controlar quem acessa o quê.
- Login é único.
- O perfil é um de: Atendente, Mecânico, Almoxarife, Gerente.
- O sistema impede inativar o último gerente ativo.

## Ciclo da ordem de serviço

### US07 — Abrir OS
**Como** atendente, **quero** abrir uma OS com cliente, veículo e queixa, **para** registrar a entrada do carro.
- Quando confirmo, então a OS nasce em `ABERTA` com número único e data/hora.
- Dado um veículo com OS ativa, então o sistema recusa a nova abertura.
- A queixa é obrigatória.

### US08 — Registrar diagnóstico
**Como** mecânico, **quero** registrar o diagnóstico de uma OS aberta, **para** que o atendente possa orçar.
- Dado uma OS `ABERTA`, quando salvo o diagnóstico, então ela vai para `DIAGNOSTICADA` com o mecânico responsável.
- OS fora de `ABERTA` não aceita diagnóstico.

### US09 — Montar orçamento
**Como** atendente, **quero** compor o orçamento com serviços, peças e desconto, **para** apresentá-lo ao cliente.
- Dado uma OS `DIAGNOSTICADA`, quando confirmo, então ela vai para `AGUARDANDO_APROVACAO`.
- O sistema calcula subtotal, desconto e total.
- Orçamento sem itens é recusado.
- Desconto até 10% é aplicado direto.

### US10 — Autorizar desconto acima de 10%
**Como** gerente, **quero** autorizar ou recusar descontos acima de 10%, **para** controlar a margem da oficina.
- Dado um desconto maior que 10%, então o orçamento só avança com autorização de um gerente autenticado.
- A autorização registra gerente e data.
- Credencial sem perfil de gerente não autoriza.

### US11 — Registrar aprovação do cliente
**Como** atendente, **quero** registrar que o cliente aprovou o orçamento, **para** liberar a execução.
- Dado uma OS `AGUARDANDO_APROVACAO`, quando registro a aprovação, então ela vai para `APROVADA`, com data/hora e forma de contato.

### US12 ⚠️ — Registrar recusa do orçamento
**Como** atendente, **quero** registrar a recusa do cliente e o motivo, **para** encerrar a OS.
- Quando registro a recusa, então a OS vai para `CANCELADA` com o motivo.

### US13 — Executar serviço
**Como** mecânico, **quero** iniciar a execução de uma OS aprovada, **para** registrar o andamento do trabalho.
- Dado uma OS `APROVADA`, quando inicio, então ela vai para `EM_EXECUCAO` com data/hora de início.
- OS não aprovada não pode ser iniciada.

### US14 — Registrar peças usadas
**Como** mecânico, **quero** lançar as peças consumidas na OS, **para** manter o estoque correto.
- Quando lanço uma peça, então o saldo é baixado.
- Saldo insuficiente é recusado.
- Peça fora do orçamento pede confirmação.

### US15 — Concluir OS
**Como** mecânico, **quero** marcar a OS como concluída, **para** avisar que o carro está pronto.
- Dado uma OS `EM_EXECUCAO`, quando concluo, então ela vai para `CONCLUIDA` e o atendente é avisado.

### US16 — Entregar e registrar pagamento
**Como** atendente, **quero** registrar o pagamento e entregar o veículo, **para** fechar a OS.
- Dado uma OS `CONCLUIDA`, quando o pagamento cobre o total, então ela vai para `ENTREGUE`.
- Valor insuficiente mantém a OS em `CONCLUIDA`.
- `ENTREGUE` é estado final.

### US17 — Consultar OS
**Como** atendente ou gerente, **quero** buscar OS por número, cliente, placa, estado ou período, **para** acompanhar o andamento.
- A consulta não altera dados.
- Sem resultado, o sistema informa que nada foi encontrado.

### US18 — Cancelar OS
**Como** atendente ou gerente, **quero** cancelar uma OS informando o motivo, **para** encerrar o que não vai seguir.
- Em qualquer estado antes de `ENTREGUE`, o cancelamento leva a OS para `CANCELADA`.
- OS `ENTREGUE` ou já `CANCELADA` não pode ser cancelada.
- Peças já baixadas voltam ao estoque.
- Mecânico e almoxarife não cancelam.

## Estoque e gestão

### US19 — Dar entrada no estoque
**Como** almoxarife, **quero** registrar a chegada de peças, **para** manter o saldo atualizado.
- Quando registro quantidade, custo e nota, então o saldo aumenta e a entrada fica registrada.
- Quantidade menor ou igual a zero é recusada.

### US20 — Ver faturamento
**Como** gerente, **quero** ver o faturamento por período, **para** acompanhar o resultado da oficina.
- O total soma os pagamentos de OS `ENTREGUE` no período.
- Período sem OS mostra total zero.

## Complementares ⚠️

### US21 ⚠️ — Ver alerta de estoque baixo
**Como** almoxarife, **quero** ver peças abaixo do estoque mínimo, **para** repor antes de faltar.
- Peças com saldo menor que o mínimo aparecem destacadas na listagem.

### US22 ⚠️ — Sair do sistema
**Como** usuário, **quero** encerrar minha sessão, **para** que outra pessoa não use meu acesso.
- Quando escolho "Sair", então a sessão fecha e volto ao login.

### US23 ⚠️ — Ver histórico de transições da OS
**Como** atendente ou gerente, **quero** ver quem mudou o estado da OS e quando, **para** auditar o andamento.
- A tela da OS lista cada transição com estado, usuário e data/hora.
