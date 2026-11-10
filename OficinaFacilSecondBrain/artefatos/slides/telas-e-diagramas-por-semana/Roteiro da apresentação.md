---
data: 2026-11-10
---

# Roteiro da apresentação ao professor

Gerado das notas dos slides de `artefatos/slides/telas-e-diagramas-por-semana/` (não editar à mão: editar a nota do slide e regerar). Deck: https://claude.ai/artifact/UsDXKHoeGbjtHZzrzDvjdH. Cerca de 15 minutos.

## Quem fala

| Pessoa | Slides |
|---|---|
| Elto | 1, 2, 3, 4, 19, 20 |
| Evillyn | 5, 6 |
| Pedro | 7 |
| Roberto | 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 |

O Roberto cuida só da parte de diagramas (slides 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18).

## Fala por slide

### 1. OficinaFácil (Elto)

ELTO (cerca de 30 segundos). Boa tarde. Somos o grupo do OficinaFácil, um sistema de ordens de serviço para oficina mecânica. Vamos mostrar o projeto, o plano, a arquitetura, as telas que já funcionam e os diagramas que explicam como tudo funciona por dentro. Eu abro e mostro o plano e o processo, a Evillyn fala da arquitetura e das telas, o Roberto apresenta os diagramas e o Pedro fala do design, do código e dos próximos passos.

### 2. O projeto em uma frase (Elto)

ELTO (cerca de 1 minuto). O OficinaFácil acompanha o carro desde a entrada na oficina até a entrega e o pagamento. Há quatro tipos de usuário, cada um vendo só o que pode: o atendente recebe o cliente e monta o orçamento, o mecânico diagnostica e executa, o almoxarife cuida do estoque e o gerente aprova descontos e vê o faturamento. A ordem de serviço passa por oito estados, de aberta até entregue, ou cancelada. O plano tem 15 semanas, de 2 de novembro a 14 de fevereiro, em nove fases. A tecnologia é Flutter no celular e na web, um backend em Node com TypeScript e o Supabase como banco e autenticação.

### 3. Linha do tempo: onde estamos (Elto)

ELTO (cerca de 1 minuto). Este é o plano inteiro: 15 semanas em nove fases. Em azul está o que já foi concluído: as fases 1, 2 e 3, com o marco M1 atingido. Estamos na semana 2 e a fase 3 só estava prevista para a semana que vem, então estamos uma semana à frente. O número embaixo de cada fase é o peso: somamos, para cada funcionalidade, os critérios de aceitação, os endpoints da API, as telas e as tabelas que ela toca. O total do projeto é 254 e já entregamos 73, cerca de 29%, em duas das quinze semanas. A fase 5, abrir e orçar a ordem, é a mais pesada, por isso tem três semanas, e a folga de fim de ano vem logo depois.

### 4. Como trabalhamos: Scrum e Kanban (Elto)

ELTO (cerca de 1 minuto). Seguimos o Scrum, como no livro Engenharia de Software Moderna, com sprints de uma semana. Cada funcionalidade é uma história de usuário no formato como, quero e para, com critérios de aceitação objetivos. O quadro no Trello é um Kanban: Product Backlog com o que falta, em ordem de prioridade; Sprint Backlog com o que foi escolhido para a semana; Em andamento, com no máximo dois cards ao mesmo tempo; e Concluído. Cada card tem um peso, que é a soma dos critérios, endpoints, telas e tabelas da funcionalidade. Só entra na sprint o que está claro e sem dependência, a chamada definição de pronto para começar; e só é concluído o que foi provado, testado e documentado, a definição de feito.

### 5. O app nunca fala direto com o banco (Evillyn)

EVILLYN (cerca de 1 minuto). A decisão mais importante da arquitetura é esta: o aplicativo nunca fala direto com o banco de dados. O app, no celular ou na web, mostra as telas e confere se os campos foram preenchidos, mas não decide nada sozinho. Quem decide é a nossa API, em Node: é ela que aplica as regras da oficina, como o desconto acima de 10% ou a baixa de estoque, e confere quem está logado e o que essa pessoa pode fazer. O Supabase guarda os dados, faz o login e envia avisos na hora. Por que assim? Porque um aplicativo pode ser alterado por alguém mal-intencionado, e a regra precisa ficar num lugar seguro. Além disso, cada tabela do banco só mostra dados a quem tem permissão, o perfil é conferido a cada pedido, então trocar o perfil de alguém vale na hora, e os valores em dinheiro são guardados em centavos, para não ter erro de arredondamento.

### 6. As telas que já funcionam (Evillyn)

EVILLYN (cerca de 1 minuto). Estas são telas do aplicativo funcionando, com dados de exemplo. À esquerda, o login: a pessoa entra com e-mail e senha e vê apenas o menu do seu perfil; um mecânico, por exemplo, não vê a parte de usuários. No meio, a lista de usuários, que só o gerente acessa: ele busca, filtra por perfil, cria e desativa usuários. À direita, a lista de clientes, usada pelo atendente: ele busca por nome ou CPF e CNPJ e abre os veículos de cada cliente. O mesmo código funciona na web e no Android. Em seguida, o Roberto mostra os diagramas que explicam como essas telas funcionam por dentro.

### 7. Design próprio e código testado (Pedro)

PEDRO (cerca de 1 minuto e 30). Eu cuido do design e da qualidade do código. Criamos um design system próprio, com poucas regras para a interface ficar limpa: só uma cor de ação, o azul, em todo botão e link; o dado mais importante de cada tela num bloco escuro; botões de ação em formato de pílula e sem sombra; e o logo na cor original da marca. Sobre o código, são 561 testes automáticos, 210 no backend e 351 no aplicativo. No backend, cada módulo só usa outro pela porta de entrada dele, o arquivo index.ts, e um teste de arquitetura quebra se alguém violar essa regra. Só viramos componente o que tem dois ou mais usos reais, para não complicar à toa.

### 8. Os diagramas do projeto (Roberto)

ROBERTO (cerca de 40 segundos). Agora vou mostrar os diagramas, que são a parte de modelagem do projeto. Usamos os quatro tipos que o livro Engenharia de Software Moderna apresenta no capítulo 4. Pacotes mostra como o código é dividido e quem usa quem. Classes mostra as coisas do sistema, o que cada uma guarda e como se ligam. Sequência mostra quem chama quem, e em que ordem, em um cenário. Atividades mostra o caminho da pessoa, com as decisões. Eles são desenhados em Mermaid e ficam no repositório junto com o código, organizados por semana. Quando há tela, ela aparece ao lado do diagrama.

### 9. Semana 1 · Pacotes do sistema (Roberto)

ROBERTO (cerca de 50 segundos). Semana 1. Este é o diagrama de pacotes do sistema inteiro. Cada caixa grande é um pacote: o app, o backend e o Supabase. A seta tracejada significa que a origem usa o destino, e a seta grossa é uma chamada pela rede. O ponto principal é que o app só fala com o mundo por uma camada, a data, e a tela nunca chama a API direto. Toda regra de negócio fica no service, no backend, e só o backend escreve no banco. O login é a única conversa direta do app com o Supabase.

### 10. Semana 2 · Login (Roberto)

ROBERTO (cerca de 50 segundos). Semana 2, login. Este é um diagrama de sequência: cada caixa no topo é um objeto do código, e os números dão a ordem das chamadas. As cores mostram onde cada objeto está: azul no app, âmbar no backend e verde no Supabase. A pessoa informa e-mail e senha; o SessaoNotifier pede ao Auth do Supabase para conferir a senha e recebe um token. Com o token, chama a API, que confere o token e busca o perfil no banco. Se a conta está ativa, o app abre o menu do perfil; se está inativa ou sem perfil, a API responde 403 e a sessão é encerrada com uma mensagem.

### 11. Semana 2 · O caminho do login (Roberto)

ROBERTO (cerca de 40 segundos). Semana 2. O diagrama de atividades mostra o caminho completo da pessoa, com as decisões. Ao abrir o app, se já há sessão salva, vai direto ao menu. Se não, passa pela tela de login e digita e-mail e senha. Se as credenciais e a conta são válidas, abre o menu do perfil; se não, aparece a mensagem e ela tenta de novo. Os losangos são as decisões.

### 12. Semana 2 · Usuários (Roberto)

ROBERTO (cerca de 50 segundos). Semana 2, usuários. O cenário é o gerente criando um usuário. A tela manda os dados para a rota da API, que chama o ServicoUsuarios. O serviço confere se o e-mail já existe, cria a conta no Auth do Supabase e grava o perfil no Postgres. O bloco opt mostra a compensação: se gravar o perfil falhar, a conta criada é removida, para não ficar uma conta pela metade. Inativar segue o mesmo molde, e o serviço confere antes que sempre sobra um gerente ativo.

### 13. Semana 2 · Pacotes do app (Roberto)

ROBERTO (cerca de 40 segundos). Semana 2, estrutura do app. Cada funcionalidade tem três pastas: presentation, com as telas; domain, com os dados, como o Usuário; e data, com a conversa com a API. As setas apontam para o domain, que não conhece nem tela nem rede, e só a data usa o ApiClient, no pacote core, que é compartilhado.

### 14. Semana 2 · Classes de sessão e usuários (Roberto)

ROBERTO (cerca de 40 segundos). Semana 2, classes. UsuarioSessao é quem está logado agora, com nome, e-mail e perfil. Usuario é a pessoa da lista de usuários, com a informação de estar ativa. Os dois usam o Perfil, que é um conjunto fixo: atendente, mecânico, almoxarife ou gerente. A página de usuários agrupa vários usuários. Nenhuma regra de negócio está nessas classes: elas só guardam dados.

### 15. Semana 3 · Clientes (Roberto)

ROBERTO (cerca de 45 segundos). Semana 3, clientes. O atendente envia os dados, a rota chama o ServicoClientes e ele tenta gravar o cliente no banco. O bloco alt mostra os dois caminhos. Se o documento já existe, o banco recusa, o backend devolve 409 junto com o cadastro existente e a tela mostra esse cadastro para o atendente não duplicar. Se é novo, o cliente é gravado e a tela volta para a lista.

### 16. Semana 3 · Veículos (Roberto)

ROBERTO (cerca de 45 segundos). Semana 3, veículos. O cenário é transferir um veículo para outro cliente. A rota chama o ServicoVeiculos, que pergunta ao módulo de clientes, pela porta dele, se o novo cliente existe. Só então troca o dono do veículo no banco. A nota no fim lembra a regra: as ordens de serviço antigas continuam ligadas ao dono anterior.

### 17. Semana 3 · Pacotes de clientes e veículos (Roberto)

ROBERTO (cerca de 40 segundos). Semana 3, estrutura. No backend, o módulo de veículos precisa saber se o cliente existe, e pergunta ao módulo de clientes pela porta index.ts, nunca pelo interior. No app, a lista de veículos aparece dentro do cliente, e a transferência usa o seletor de clientes. Um teste de arquitetura quebra o build se um módulo usar o interior do outro.

### 18. Semana 3 · Classes de clientes e veículos (Roberto)

ROBERTO (cerca de 45 segundos). Semana 3, classes. Um cliente possui vários veículos, e cada veículo guarda o id do dono. Transferir troca o dono, mas o histórico de ordens de serviço fica com o dono anterior. Documento ou placa repetidos viram um erro próprio, que carrega o cadastro que já existe. Nada é apagado, só inativado. Com isso fechamos a parte de diagramas.

### 19. Por que as próximas fases vêm nesta ordem (Elto)

ELTO (cerca de 1 minuto e 30). Agora, o porquê da ordem das próximas fases, além do peso de cada uma. A fase 4, catálogos e estoque, vem primeiro porque a ordem de serviço usa serviço e peça, e o estoque precisa existir antes de uma peça ser baixada. A fase 5 abre, diagnostica e orça a ordem: ali nasce o controle das etapas da ordem, que sustenta o resto, e o desconto fica por último porque depende do orçamento. A fase 6 exige ordem orçada: só se executa com a aprovação do cliente. A fase 7 entrega e cancela: só se paga ordem concluída. A fase 8 lê tudo que veio antes, com filtros e faturamento, e a fase 9 integra e publica. Estamos uma semana adiantados: as datas ficam iguais e essa semana vira folga a mais no Natal e no Ano-Novo.

### 20. Próximos passos (Elto)

ELTO (cerca de 40 segundos, depois perguntas). Para fechar: os próximos passos são a fase 4, catálogos e estoque, e depois a fase 5, onde nasce o coração do sistema, a ordem de serviço passando por todas as etapas. Seguimos uma semana à frente do plano, com a folga de fim de ano preservada. Em duas semanas temos a especificação completa, três fases concluídas e provadas, um design próprio e uma base com 561 testes. Agora abrimos para perguntas. Arquitetura e banco: Evillyn. Diagramas: Roberto. Plano e processo: eu. Design e código: Pedro.

## Se perguntarem

- **Por que o app não fala direto com o banco?** Para a regra de negócio ficar num lugar só, a API, com teste e em transação. O app só ajuda a pessoa.
- **Por que esses quatro diagramas?** São os que o livro Engenharia de Software Moderna apresenta no capítulo 4 (pacotes, classes, sequência e atividades). Todos em Mermaid, no repositório, por semana.
- **Onde está o diagrama de casos de uso?** Na nota Casos de uso do vault, com os 19 casos e a matriz de perfis.
- **Por que a API demora na primeira chamada?** Está no plano gratuito do Render, que dorme sem uso; a primeira chamada leva cerca de um minuto.
- **Os dados das telas são reais?** Não, todos fictícios.
- **Como o peso é calculado?** Critérios de aceitação + endpoints + telas + tabelas de cada funcionalidade. É uma régua de tamanho, não de horas.
- **O que falta?** Peças, serviços, estoque e todo o ciclo da OS (fases 4 a 9), conforme o Roadmap.
