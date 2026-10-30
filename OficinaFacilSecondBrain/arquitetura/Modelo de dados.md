---
data: 2026-10-30
---

# Modelo de dados — OficinaFácil

Banco: Postgres do Supabase, acessado pelo backend via Prisma. Arquitetura em [[Arquitetura]].

Convenções:
- Chaves primárias `uuid` (`id`), exceto `ordens_servico.numero`, que é sequencial e legível.
- **Dinheiro em centavos** (`inteiro`). Datas em `timestamptz`; relatórios por período usam o fuso **America/Sao_Paulo**.
- Nomes de tabela em `snake_case` e no plural. Colunas em `snake_case`.
- Nada é apagado de verdade: cadastros usam `ativo`; movimentação, histórico e pagamentos são **só de inserção**.
- `ordens_servico.numero` vem de uma sequence do Postgres; **lacunas na numeração são aceitas** (rollback consome número).

## 1. Diagramas entidade-relacionamento

O modelo é dividido em três diagramas, por assunto, para ficar legível. Tabelas que aparecem só com a chave primária são detalhadas no diagrama onde pertencem.

### 1.1 Cadastros e estoque

```mermaid
erDiagram
  clientes ||--o{ veiculos : "possui"
  pecas ||--o{ movimentacoes_estoque : "movimenta"
  perfis ||--o{ movimentacoes_estoque : "responsável"

  perfis {
    uuid usuario_id PK "igual a auth.users.id"
    text nome
    text email UK
    perfil_enum perfil
    boolean ativo
    timestamptz criado_em
  }
  clientes {
    uuid id PK
    text nome
    text documento UK "CPF ou CNPJ, só dígitos, com dígito verificador"
    text telefone
    text email
    text endereco
    boolean ativo
  }
  veiculos {
    uuid id PK
    uuid cliente_id FK
    text placa UK "normalizada, padrão antigo ou Mercosul"
    text marca
    text modelo
    int ano
    text cor
    int quilometragem
    boolean ativo
  }
  servicos {
    uuid id PK
    text codigo UK
    text descricao
    int valor_centavos
    int tempo_estimado_min
    boolean ativo
  }
  pecas {
    uuid id PK
    text codigo UK
    text descricao
    int preco_centavos
    int saldo
    int estoque_minimo
    boolean ativo
  }
  movimentacoes_estoque {
    uuid id PK
    uuid peca_id FK
    tipo_mov_enum tipo "ENTRADA, BAIXA ou ESTORNO"
    int quantidade
    int custo_unitario_centavos
    text documento_origem
    uuid os_id FK "nulo em ENTRADA"
    uuid usuario_id FK
    timestamptz criado_em
  }
```

### 1.2 Ordem de serviço, orçamento e histórico

```mermaid
erDiagram
  clientes ||--o{ ordens_servico : "contrata"
  veiculos ||--o{ ordens_servico : "entra em"
  perfis ||--o{ ordens_servico : "abre"
  ordens_servico ||--o| diagnosticos : "tem"
  ordens_servico ||--o| orcamentos : "tem"
  orcamentos ||--|{ itens_orcamento : "contém"
  orcamentos ||--o{ autorizacoes_desconto : "pode ter"
  servicos ||--o{ itens_orcamento : "compõe"
  pecas ||--o{ itens_orcamento : "compõe"
  ordens_servico ||--o{ aprovacoes : "recebe"
  ordens_servico ||--o{ observacoes : "anota"
  ordens_servico ||--o{ historico_transicoes : "registra"
  perfis ||--o{ avisos : "recebe"

  ordens_servico {
    uuid id PK
    int numero UK "sequence"
    uuid cliente_id FK
    uuid veiculo_id FK
    text queixa
    int quilometragem_entrada
    status_enum status
    uuid aberta_por FK
    uuid mecanico_id FK "nulo até o diagnóstico"
    timestamptz aberta_em
    timestamptz iniciada_em
    timestamptz concluida_em
    timestamptz entregue_em
    uuid entregue_por FK
    text motivo_cancelamento
  }
  diagnosticos {
    uuid id PK
    uuid os_id FK, UK
    text texto
    boolean finalizado "false = rascunho"
    uuid mecanico_id FK
    timestamptz atualizado_em
  }
  orcamentos {
    uuid id PK
    uuid os_id FK, UK
    int subtotal_centavos
    int desconto_centavos
    int total_centavos
    timestamptz confirmado_em
  }
  itens_orcamento {
    uuid id PK
    uuid orcamento_id FK
    tipo_item_enum tipo "SERVICO ou PECA"
    uuid servico_id FK
    uuid peca_id FK
    text descricao
    int quantidade
    int valor_unitario_centavos
  }
  autorizacoes_desconto {
    uuid id PK
    uuid orcamento_id FK
    uuid atendente_id FK
    uuid gerente_id FK "nulo até decidir"
    status_desconto_enum status "PENDENTE, APROVADA ou RECUSADA"
    int subtotal_centavos_ref "subtotal no momento do pedido"
    int desconto_solicitado_centavos
    int desconto_autorizado_centavos
    timestamptz criado_em
    timestamptz decidido_em
  }
  aprovacoes {
    uuid id PK
    uuid os_id FK
    resultado_enum resultado "APROVADA ou RECUSADA"
    canal_enum canal "BALCAO ou TELEFONE"
    text motivo
    uuid usuario_id FK
    timestamptz criado_em
  }
  observacoes {
    uuid id PK
    uuid os_id FK
    text texto
    uuid usuario_id FK
    timestamptz criado_em
  }
  historico_transicoes {
    uuid id PK
    uuid os_id FK
    status_enum de "nulo na abertura da OS"
    status_enum para
    uuid usuario_id FK
    text motivo
    timestamptz criado_em
  }
  avisos {
    uuid id PK
    uuid destinatario_id FK
    aviso_enum tipo "OS_CONCLUIDA, SALDO_INSUFICIENTE ou DESCONTO_PENDENTE"
    uuid os_id FK "opcional"
    uuid peca_id FK "opcional"
    timestamptz lido_em
    timestamptz criado_em
  }
```

### 1.3 Execução e pagamento

```mermaid
erDiagram
  ordens_servico ||--o{ pecas_usadas : "consome"
  pecas ||--o{ pecas_usadas : "é usada em"
  ordens_servico ||--o{ pagamentos : "é paga por"
  pecas ||--o{ movimentacoes_estoque : "movimenta"
  ordens_servico {
    uuid id PK
  }
  pecas {
    uuid id PK
  }
  movimentacoes_estoque {
    uuid id PK
  }
  pecas_usadas {
    uuid id PK
    uuid os_id FK
    uuid peca_id FK
    int quantidade
    int valor_unitario_centavos
    uuid mecanico_id FK
    boolean estornada
    boolean devolvida "nulo se não estornada; false = não devolver"
    text motivo_nao_devolucao
    timestamptz criado_em
  }
  pagamentos {
    uuid id PK
    uuid os_id FK
    forma_enum forma "DINHEIRO, CARTAO ou PIX"
    int valor_centavos
    uuid usuario_id FK
    timestamptz criado_em
  }
```

## 2. Enumerações

| Enum | Valores |
|---|---|
| `perfil_enum` | `ATENDENTE`, `MECANICO`, `ALMOXARIFE`, `GERENTE` |
| `status_enum` | `ABERTA`, `DIAGNOSTICADA`, `AGUARDANDO_APROVACAO`, `APROVADA`, `EM_EXECUCAO`, `CONCLUIDA`, `ENTREGUE`, `CANCELADA` |
| `tipo_mov_enum` | `ENTRADA`, `BAIXA`, `ESTORNO` |
| `tipo_item_enum` | `SERVICO`, `PECA` |
| `resultado_enum` | `APROVADA`, `RECUSADA` |
| `status_desconto_enum` | `PENDENTE`, `APROVADA`, `RECUSADA` |
| `canal_enum` | `BALCAO`, `TELEFONE` |
| `forma_enum` | `DINHEIRO`, `CARTAO`, `PIX` |
| `aviso_enum` | `OS_CONCLUIDA`, `SALDO_INSUFICIENTE`, `DESCONTO_PENDENTE` |

**Mapeamento do estado da OS.** No banco e na API o estado é `AGUARDANDO_APROVACAO` (igual às notas). No Dart, o enum `StatusOrdemServico` usa `aguardandoAprovacao`. A conversão é explícita, num único lugar (`fromApi`/`toApi`), e tem teste.

## 3. Dicionário das tabelas

| Tabela | Finalidade | UC |
|---|---|---|
| `perfis` | Perfil e situação de cada usuário; `usuario_id` aponta para `auth.users` do Supabase | UC01, UC06 |
| `clientes` | Cadastro de clientes | UC02 |
| `veiculos` | Veículos de um cliente | UC03 |
| `servicos` | Catálogo de serviços e valor da mão de obra | UC05 |
| `pecas` | Catálogo de peças e saldo atual | UC04 |
| `movimentacoes_estoque` | Razão do estoque: toda entrada, baixa e estorno. O `saldo` em `pecas` é consequência | UC13, UC17, UC18 |
| `ordens_servico` | A OS e seu estado atual | UC07 a UC17 |
| `diagnosticos` | Parecer do mecânico (um por OS); `finalizado = false` é rascunho | UC08 |
| `orcamentos` e `itens_orcamento` | Valores da OS; itens guardam o preço do momento | UC09 |
| `autorizacoes_desconto` | Pedido e decisão de desconto acima de 10%; perde a validade se o subtotal ou o desconto mudar | UC10 |
| `aprovacoes` | Resposta do cliente (aprova ou recusa) | UC11 |
| `observacoes` | Anotações de andamento do mecânico durante a execução | UC12 |
| `pecas_usadas` | Peças efetivamente consumidas; guarda estorno e "não devolver" | UC13, UC17 |
| `pagamentos` | Pagamentos gravados no ato da entrega | UC15, UC19 |
| `historico_transicoes` | Toda mudança de estado, com autor e data | UC16 |
| `avisos` | Avisos entre perfis (OS concluída, saldo insuficiente, desconto pendente) | UC13, UC14, UC10 |

## 4. Restrições e índices

| Regra | Como o banco garante |
|---|---|
| Documento, placa, e-mail do perfil, código de peça e de serviço únicos | `UNIQUE` |
| Uma OS ativa por veículo (UC07) | Índice único parcial em `ordens_servico(veiculo_id)` onde `status` não é `ENTREGUE` nem `CANCELADA` |
| Saldo nunca negativo (RN07) | `CHECK (saldo >= 0)` em `pecas`, além do `UPDATE ... WHERE saldo >= q` no serviço |
| Desconto coerente | `CHECK (desconto_centavos >= 0 AND desconto_centavos <= subtotal_centavos)` em `orcamentos` |
| Preços e valores positivos; quantidades positivas | `CHECK (... > 0)` |
| Movimentação, histórico e pagamentos só de inserção | Gatilho que rejeita `UPDATE` e `DELETE` (dentro da migration) |
| Um diagnóstico e um orçamento por OS | `UNIQUE (os_id)` |
| Consultas de OS, faturamento e estoque | Índices em `ordens_servico(status)`, `(veiculo_id)`, `(cliente_id)`, `(aberta_em)`, `(entregue_em)`; `pagamentos(os_id)`; `historico_transicoes(os_id)`; `pecas_usadas(os_id)`; `movimentacoes_estoque(peca_id, criado_em)` |
| `perfis.usuario_id` aponta para `auth.users` | FK escrita em SQL na migration (o Prisma não gerencia o schema `auth`) |

Tudo que o Prisma não expressa (RLS, gatilhos, índice parcial, FK para `auth.users`) vai **dentro da migration**, criada com `prisma migrate dev --create-only` e editada antes de aplicar.

## 5. Regras de cálculo

- `subtotal = Σ quantidade × valor_unitario` dos itens.
- `desconto` em centavos. A regra "acima de 10%" (RN02) é aritmética inteira: **`desconto * 100 > subtotal * 10`** exige autorização aprovada.
- O desconto vale para o orçamento inteiro, não por item.
- `total = subtotal − desconto`.
- A autorização só vale enquanto `subtotal_centavos_ref` e o desconto autorizado continuam iguais ao orçamento; se mudar, volta a ser necessária.
- A OS só vai a `ENTREGUE` quando a soma dos pagamentos enviados na entrega é igual ao `total` (decisão 009).
- Faturamento (UC19) soma pagamentos das OS entregues, no período pela **data de entrega** (`entregue_em`), em America/Sao_Paulo.

## 6. Acesso do app (RLS)

Todas as tabelas têm RLS ligada. Para `anon` e `authenticated`:

| Operação | Política |
|---|---|
| `SELECT` | **Somente em `avisos`**, e só a linha cujo `destinatario_id` é o próprio usuário (`auth.uid()`). Realtime publica só essa tabela |
| `SELECT` nas demais tabelas | **Nenhuma política**: inacessíveis pelo PostgREST e pelo Realtime. O app lê pela API |
| `INSERT`, `UPDATE`, `DELETE` | **Nenhuma política**: bloqueado. Só o backend, com a conexão direta, escreve |

Assim, mesmo com a chave publicável, um usuário não lê OS, clientes nem estoque fora da API (que aplica o perfil). Políticas, gatilhos e índices vivem nas migrations do Prisma. Teste de aceitação: com a chave publicável, qualquer `SELECT` fora de `avisos` retorna zero linhas e qualquer escrita falha.

## 7. Dados pessoais (LGPD)

Cliente guarda nome, documento, telefone, e-mail e endereço. Diretrizes (RNF09 em [[Requisitos]]):
- O mecânico não recebe documento nem telefone do cliente.
- Busca por documento não vai em query string (evita PII nos logs).
- Seed e testes usam só dados fictícios; nenhum CPF real.
- Projeto Supabase na região `sa-east-1` (São Paulo).
- Anonimização de cliente a pedido do titular ainda **não tem caso de uso nem coluna**; depende de aprovação de escopo (fica como pendência no [[CHECKLIST]]).

## 8. Dados iniciais (seed)

- Um usuário **Gerente** para o primeiro acesso, criado pelo script de seed com e-mail e senha vindos de variável de ambiente (nunca no repositório).
- Catálogo fictício (alguns serviços e peças) apenas no ambiente de desenvolvimento.
