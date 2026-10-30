#!/usr/bin/env python3
"""Gera features/, CHECKLIST.md, telas/Mapa de telas.md, 00 - Índice.md, api/Endpoints.md e requisitos/Rastreabilidade.md.

ATENÇÃO: recria features/ e CHECKLIST.md do zero. Por segurança, aborta se algum CA já saiu de "Pendente" ou se alguma
tarefa de fase estiver marcada, a menos que receba --force. Use --dry-run para só listar o que seria sobrescrito.
Convenções.md e prioridade/atual.md NÃO são mais gerados: editam-se à mão."""
import os, pathlib

R = pathlib.Path(__file__).resolve().parents[2]  # raiz do repositório
V = R / 'OficinaFacilSecondBrain'
import sys, datetime
HOJE = datetime.date.today().isoformat()

# fase -> (título, descrição)
FASES = {
    'F1': ('Fundação técnica', 'Supabase de desenvolvimento, backend base, banco com RLS, app ligado ao backend, seed e CI'),
    'F2': ('Acesso e usuários', 'Login com 4 perfis e gestão de usuários'),
    'F3': ('Clientes e veículos', 'Cadastros que a OS referencia'),
    'F4': ('Catálogos e estoque', 'Serviços, peças e entrada no estoque'),
    'F5': ('Abrir, diagnosticar e orçar', 'Primeira metade do ciclo da OS'),
    'F6': ('Aprovação e execução', 'Cliente decide, mecânico executa e lança peças'),
    'F7': ('Concluir, entregar e cancelar', 'Fim do ciclo: primeiro fluxo ponta a ponta'),
    'F8': ('Consulta, histórico e faturamento', 'Visão gerencial'),
    'F9': ('Acabamento e entrega final', 'Android, integração, documentos e release'),
}

# Telas (derivadas dos UCs). id, nome, rota, perfis, uc
TELAS = [
    ('T01', 'Login', '/login', 'Todos (sem sessão)', ['001']),
    ('T02', 'Início (menu por perfil)', '/', 'Todos', ['001']),
    ('T03', 'Lista de usuários', '/usuarios', 'Gerente', ['006']),
    ('T04', 'Formulário de usuário', '/usuarios/novo · /usuarios/:id', 'Gerente', ['006']),
    ('T05', 'Lista de clientes', '/clientes', 'Atendente', ['002']),
    ('T06', 'Formulário de cliente', '/clientes/novo · /clientes/:id', 'Atendente', ['002']),
    ('T07', 'Veículos do cliente e formulário', '/clientes/:id/veiculos · /clientes/:id/veiculos/novo', 'Atendente', ['003']),
    ('T08', 'Lista de serviços', '/servicos', 'Gerente', ['005']),
    ('T09', 'Formulário de serviço', '/servicos/novo · /servicos/:id', 'Gerente', ['005']),
    ('T10', 'Lista de peças (com alerta de estoque baixo)', '/pecas', 'Almoxarife', ['004']),
    ('T11', 'Formulário de peça', '/pecas/novo · /pecas/:id', 'Almoxarife', ['004']),
    ('T12', 'Entrada no estoque', '/pecas/:id/entrada', 'Almoxarife', ['018']),
    ('T13', 'Abrir OS', '/os/nova', 'Atendente', ['007']),
    ('T14', 'Lista e busca de OS', '/os', 'Atendente, Gerente, Mecânico (fila restrita)', ['007', '016', '008', '012']),
    ('T15', 'Detalhe da OS (dados, orçamento, peças, histórico, ações por estado)', '/os/:id', 'Atendente, Gerente, Mecânico (sem documento e telefone do cliente)', ['007', '016', '014']),
    ('T16', 'Diagnóstico', '/os/:id/diagnostico', 'Mecânico', ['008']),
    ('T17', 'Orçamento (inclui pedir autorização de desconto)', '/os/:id/orcamento', 'Atendente', ['009', '010']),
    ('T18', 'Solicitações de desconto (pendentes e decididas)', '/descontos', 'Gerente', ['010']),
    ('T19', 'Aprovação ou recusa do cliente', '/os/:id/aprovacao', 'Atendente', ['011']),
    ('T20', 'Execução e peças usadas', '/os/:id/execucao', 'Mecânico', ['012', '013']),
    ('T21', 'Pagamento e entrega', '/os/:id/entrega', 'Atendente', ['015']),
    ('T22', 'Cancelar OS (diálogo com motivo)', 'diálogo sobre T15', 'Atendente, Gerente', ['017']),
    ('T23', 'Faturamento', '/faturamento', 'Gerente', ['019']),
    ('T24', 'Notificações no app (OS concluída, saldo insuficiente)', '/notificacoes', 'Atendente, Almoxarife', ['013', '014']),
]

# nnn, nome, fase, uc, us, atores, rn, deps, cas[(texto, ⚠️?)], notas
F = [
 ('000', 'Fundação técnica', 'F1', '—', '—', 'Time de desenvolvimento', [], [],
  [('Projeto Supabase de desenvolvimento criado; chaves e segredos fora do git (`backend/.env`, `mobile/env.json`)', 0),
   ('Backend sobe com `npm run dev`; `GET /health` responde 200 e `/docs` mostra o Swagger', 0),
   ('Variáveis de ambiente validadas com Zod: o backend recusa subir com configuração incompleta', 0),
   ('Migration inicial aplicada (modelo em [[Modelo de dados]]) com RLS ligada em todas as tabelas e sem política de escrita para o app', 0),
   ('JWT do Supabase validado por JWKS; rota sem token recebe 401 e perfil sem permissão recebe 403', 0),
   ('Erros da API padronizados num único formato JSON, sem vazar detalhe interno', 0),
   ('Teste de arquitetura impede um módulo de importar o interior de outro', 0),
   ('Seed cria o gerente inicial com e-mail e senha vindos de variável de ambiente', 0),
   ('App lê a configuração por `--dart-define`, autentica no Supabase e chama a API com `dio`', 0),
   ('Rotas do app protegidas por perfil (`redirect` no go_router)', 0),
   ('Dockerfile do backend gera imagem que sobe e responde em `/health`', 0),
   ('Verificações verdes no backend e no app, e CI rodando (analyze, test, lint, typecheck, build)', 0)],
  'Stack e arquitetura em [[Arquitetura]]. Decisões D1, D2, D6 e D12 já tomadas ([[00 - Índice de decisões]]). Nada de BullMQ/Redis.'),
 ('001', 'Autenticar', 'F2', 'UC01', 'US01, US22', 'Todos', ['RN09'], ['000'],
  [('Login e senha corretos (Supabase Auth) abrem a sessão; `GET /me` devolve nome e perfil e o app monta o menu do perfil', 0),
   ('Credenciais inválidas negam o acesso com mensagem genérica (sem dizer se o erro foi no login ou na senha)', 0),
   ('Token expirado é renovado pelo app; refresh inválido volta ao login', 0),
   ('Usuário inativo vê a mensagem de que está desativado', 0),
   ('Rota protegida sem sessão redireciona ao login', 0),
   ('O menu mostra só o que o perfil permite (RN09)', 0),
   ('"Sair" encerra a sessão e volta ao login (US22)', 1)],
  ''),
 ('002', 'Gerir clientes', 'F3', 'UC02', 'US02', 'Atendente', [], ['001'],
  [('Cadastrar cliente com nome, documento, telefone, e-mail e endereço', 1),
   ('Documento duplicado é recusado e mostra o cadastro existente', 0),
   ('Campos obrigatórios ausentes são destacados e o cadastro não é salvo', 0),
   ('Buscar por nome ou documento e alterar os dados', 0),
   ('Inativar cliente mantém o histórico de OS', 0),
   ('Cliente com OS ativa não pode ser inativado (testado na feature 007)', 0)],
  'A regra da OS aberta só é testável de ponta a ponta depois da feature 007.'),
 ('003', 'Gerir veículos', 'F3', 'UC03', 'US03', 'Atendente', [], ['002'],
  [('Cadastrar veículo vinculado a um cliente, com placa, marca, modelo, ano, cor e quilometragem', 1),
   ('Placa duplicada é recusada e exibe o veículo existente', 0),
   ('Placa em formato inválido é recusada', 0),
   ('Buscar por placa ou por cliente e alterar os dados', 0),
   ('Transferir o veículo para outro cliente mantém o histórico de OS com o dono anterior', 1)],
  ''),
 ('005', 'Gerir serviços', 'F4', 'UC05', 'US05', 'Gerente', [], ['001'],
  [('Cadastrar serviço com descrição, valor da mão de obra e tempo estimado', 1),
   ('Valor menor ou igual a zero é recusado', 0),
   ('Alterar o preço não muda orçamentos já montados', 0),
   ('Serviço inativo não aparece em orçamentos novos', 0)],
  ''),
 ('004', 'Gerir peças', 'F4', 'UC04', 'US04, US21', 'Almoxarife', ['RN07'], ['001'],
  [('Cadastrar peça com código, descrição, preço e estoque mínimo; nasce com saldo zero', 1),
   ('Código duplicado é recusado', 0),
   ('Preço menor ou igual a zero é recusado', 0),
   ('Buscar por código ou descrição e alterar os dados', 0),
   ('O saldo só muda por movimentação (entrada UC18 ou baixa UC13), nunca por edição', 0),
   ('Peças abaixo do estoque mínimo aparecem destacadas na listagem (US21)', 1)],
  ''),
 ('018', 'Dar entrada no estoque', 'F4', 'UC18', 'US19', 'Almoxarife', ['RN07'], ['004'],
  [('Registrar quantidade, custo unitário e nota de origem soma ao saldo', 1),
   ('A entrada fica registrada com data e responsável', 0),
   ('Quantidade menor ou igual a zero é recusada', 0),
   ('Peça não cadastrada leva o almoxarife ao cadastro (UC04)', 0)],
  'UC18 foi deduzido dos papéis; conferir com o documento oficial.'),
 ('006', 'Gerir usuários', 'F2', 'UC06', 'US06', 'Gerente', ['RN09'], ['001'],
  [('Criar usuário com nome, e-mail, perfil (Atendente, Mecânico, Almoxarife ou Gerente) e senha inicial; o backend cria a conta no Supabase Auth com a chave de serviço', 0),
   ('E-mail (login) duplicado é recusado', 0),
   ('Trocar o perfil vale a partir do próximo login', 0),
   ('Redefinir senha', 0),
   ('Inativar usuário impede a autenticação e mantém o histórico de ações', 0),
   ('O sistema impede inativar o último gerente ativo', 1)],
  'Senha guardada pelo Supabase Auth (D2); nunca passa pelo nosso banco. Chave de serviço só no backend.'),
 ('007', 'Abrir OS', 'F5', 'UC07', 'US07', 'Atendente', ['RN01'], ['002', '003'],
  [('Confirmar a abertura cria a OS em `ABERTA` com número único e data/hora', 0),
   ('Veículo com OS ativa recusa nova abertura e mostra a OS existente', 0),
   ('Queixa do cliente é obrigatória', 0),
   ('Cliente ou veículo não cadastrado leva ao cadastro e volta para a abertura', 0),
   ('Registra a quilometragem de entrada', 0)],
  ''),
 ('008', 'Registrar diagnóstico', 'F5', 'UC08', 'US08', 'Mecânico', ['RN01'], ['007'],
  [('Salvar o diagnóstico leva a OS de `ABERTA` para `DIAGNOSTICADA` e associa o mecânico', 0),
   ('OS fora de `ABERTA` não aceita diagnóstico e mostra o estado atual', 0),
   ('Diagnóstico vazio é recusado', 0),
   ('Salvar rascunho sem mudar o estado da OS', 1)],
  ''),
 ('009', 'Montar orçamento', 'F5', 'UC09', 'US09', 'Atendente', ['RN01', 'RN02'], ['008', '005', '004'],
  [('Confirmar leva a OS de `DIAGNOSTICADA` para `AGUARDANDO_APROVACAO`', 0),
   ('Calcula subtotal, desconto e total', 0),
   ('Orçamento sem serviço nem peça é recusado', 0),
   ('Desconto de até 10% é aplicado direto', 0),
   ('Desconto acima de 10% aciona a autorização do gerente (feature 010)', 0),
   ('Peça sem saldo avisa, mas permite orçar', 1)],
  'Valores em centavos (inteiro). Percentual = desconto ÷ subtotal; "acima de 10%" é estritamente maior. Desconto vale para o orçamento inteiro.'),
 ('010', 'Autorizar desconto', 'F5', 'UC10', 'US10', 'Gerente', ['RN02'], ['009'],
  [('Desconto acima de 10% só avança com autorização de um gerente autenticado', 0),
   ('A autorização registra o gerente e a data', 0),
   ('Credencial sem perfil de gerente não autoriza (o backend confere o perfil na tabela `perfis`)', 0),
   ('Recusa devolve o controle ao atendente, que ajusta o desconto ou segue sem ele', 0),
   ('Autorizar um percentual menor que o pedido', 1)],
  'Extensão de UC09 (`«extend»`). Gerente confirma no diálogo do atendente (D7).'),
 ('011', 'Registrar aprovação do cliente', 'F6', 'UC11', 'US11, US12', 'Atendente', ['RN03', 'RN04'], ['009'],
  [('Aprovação leva a OS de `AGUARDANDO_APROVACAO` para `APROVADA`, com data/hora e forma de contato', 0),
   ('Recusa leva a OS para `CANCELADA` e registra o motivo (US12)', 1),
   ('Orçamento alterado depois de apresentado obriga nova apresentação', 0),
   ('Cliente pedir ajuste e voltar ao orçamento (FORA DO MVP até a decisão D3)', 1)],
  'D3 aberta: no MVP o cliente só aprova ou recusa.'),
 ('012', 'Executar serviço', 'F6', 'UC12', 'US13', 'Mecânico', ['RN01', 'RN03'], ['011'],
  [('Iniciar leva a OS de `APROVADA` para `EM_EXECUCAO` e registra a data/hora de início', 0),
   ('OS não aprovada não pode ser iniciada', 0),
   ('O mecânico anota observações do andamento', 0),
   ('Serviço extra descoberto vira observação (fluxo de novo orçamento FORA DO MVP até a decisão D3)', 1)],
  'UC12 inclui UC13 (`«include»`).'),
 ('013', 'Registrar peças usadas', 'F6', 'UC13', 'US14', 'Mecânico', ['RN07'], ['012', '004', '018'],
  [('Lançar peça vincula à OS e baixa o saldo', 0),
   ('Saldo insuficiente é recusado e o almoxarife recebe aviso no app (D10)', 0),
   ('Peça fora do orçamento pede confirmação', 1),
   ('Remover peça lançada por engano devolve o saldo (estorno)', 1)],
  ''),
 ('014', 'Concluir OS', 'F7', 'UC14', 'US15', 'Mecânico', ['RN01'], ['012'],
  [('Concluir leva a OS de `EM_EXECUCAO` para `CONCLUIDA` com data/hora', 0),
   ('O atendente recebe aviso no app de que o veículo está pronto (D10)', 0),
   ('OS fora de `EM_EXECUCAO` não pode ser concluída', 0)],
  ''),
 ('015', 'Entregar e registrar pagamento', 'F7', 'UC15', 'US16', 'Atendente', ['RN05', 'RN08'], ['014'],
  [('Pagamento que cobre o total leva a OS de `CONCLUIDA` para `ENTREGUE`', 0),
   ('Registra forma de pagamento, valor, data/hora e quem entregou', 0),
   ('Valor insuficiente mantém a OS em `CONCLUIDA`', 0),
   ('OS fora de `CONCLUIDA` não pode ser entregue', 0),
   ('`ENTREGUE` é estado final', 0),
   ('Pagamento dividido em mais de uma forma; a soma não passa do total (D9)', 1)],
  ''),
 ('017', 'Cancelar OS', 'F7', 'UC17', 'US18', 'Atendente, Gerente', ['RN05', 'RN06'], ['015', '013'],
  [('Em qualquer estado antes de `ENTREGUE`, cancelar leva a OS para `CANCELADA`', 0),
   ('Motivo é obrigatório e a ação pede confirmação', 0),
   ('OS `ENTREGUE` ou já `CANCELADA` não pode ser cancelada', 0),
   ('Só atendente e gerente cancelam (RN06)', 0),
   ('Peças lançadas voltam ao estoque, com opção de marcar "não devolver" e registrar o motivo (D8)', 1)],
  'Extensão de UC16. Já existe a regra de transição em `StatusOrdemServico`.'),
 ('016', 'Consultar OS', 'F8', 'UC16', 'US17, US23', 'Atendente, Gerente', [], ['007'],
  [('Filtrar por número, cliente, placa, estado e período', 0),
   ('Mecânico vê só a fila da sua etapa (`ABERTA`, `APROVADA`, `EM_EXECUCAO`)', 0),
   ('Sem resultado, mostra que nada foi encontrado', 0),
   ('Abrir a OS mostra dados, estado atual, orçamento e peças', 0),
   ('Histórico de transições com estado, usuário e data/hora (US23)', 1),
   ('A consulta não altera dados', 0)],
  'A F5 já entrega uma lista simples de OS; esta feature completa filtros, fila do mecânico e histórico.'),
 ('019', 'Ver faturamento', 'F8', 'UC19', 'US20', 'Gerente', [], ['015'],
  [('O total soma os pagamentos de OS `ENTREGUE` no período, pela data de entrega; a agregação roda no servidor', 0),
   ('Mostra quantidade de OS e ticket médio', 0),
   ('Período sem OS entregues mostra total zero', 0),
   ('Detalhar por forma de pagamento, mecânico ou serviço', 1)],
  'UC19 foi deduzido dos papéis; conferir com o documento oficial.'),
 ('020', 'Acabamento e entrega final', 'F9', '—', '—', 'Time de desenvolvimento', [], ['019'],
  [('App testado em dispositivo Android e layout ajustado para telas pequenas', 0),
   ('Layout web responsivo conferido', 0),
   ('Teste de integração (smoke.sh) cobre o fluxo completo `ABERTA` até `ENTREGUE` contra o Supabase de dev', 0),
   ('Imagem Docker do backend publicada e API de demonstração no ar; web publicado e APK gerado', 0),
   ('Diagramas, casos de uso, histórias e PDFs atualizados com o que mudou', 0),
   ('Changelog, versão e tag criados', 0)],
  ''),
]
F.sort(key=lambda f: f[0])

# ---------- correções da revisão de 2026-10-30 (aplicadas sobre os dados acima) ----------
def mod(n, deps=None, cas=None, notas=None, atores=None, us=None, add_cas=None, drop=None):
    for k, f in enumerate(F):
        if f[0] != n:
            continue
        L = list(f)
        if deps is not None: L[7] = deps
        if atores is not None: L[5] = atores
        if us is not None: L[4] = us
        c = list(L[8]) if cas is None else list(cas)
        if drop is not None: c = [x for x in c if not x[0].startswith(drop)]
        if add_cas: c += add_cas
        L[8] = c
        if notas is not None: L[9] = notas
        F[k] = tuple(L)
        return
    raise SystemExit('feature não encontrada: ' + n)

# CA: (texto, flag) onde flag 0 = normal, 1 = ⚠️ deduzido, 2 = ❌ descartado
mod('000', cas=[
  ('Projetos Supabase de desenvolvimento e de teste criados; chaves e segredos fora do git (`backend/.env`, `mobile/env.json`); `.env.example` e `mobile/env.example.json` sem valores reais', 0),
  ('Backend sobe com `npm run dev`; `GET /health` responde 200 e `/docs` mostra o Swagger', 0),
  ('Variáveis de ambiente validadas com Zod: o backend recusa subir com configuração incompleta', 0),
  ('Migration inicial aplicada (modelo em [[Modelo de dados]]) com RLS, gatilhos de só-inserção, índice único parcial de OS ativa e FK para `auth.users` dentro das migrations do Prisma; `shadowDatabaseUrl` aponta para o projeto de teste', 0),
  ('Teste com a chave publicável comprova que o app não lê nem escreve em nenhuma tabela, exceto as próprias linhas de `avisos`', 0),
  ('JWT validado por JWKS (só os algoritmos do projeto; confere `iss`, `aud` e `exp`); rota sem token recebe 401 e perfil sem permissão recebe 403', 0),
  ('Erros da API padronizados num único formato JSON, sem vazar detalhe interno; logs Pino com redação de `authorization`, `senha` e `password`', 0),
  ('CORS aceita só as origens do web do projeto; `helmet` e rate limit ativos', 0),
  ('Teste de arquitetura impede um módulo de importar o interior de outro', 0),
  ('Seed cria o gerente inicial com e-mail e senha vindos de variável de ambiente e só dados fictícios no catálogo de dev', 0),
  ('App lê a configuração por `--dart-define`, chama `GET /health` com `dio` e abre em pt-BR (`flutter_localizations`); manifesto Android principal com permissão INTERNET', 0),
  ('Conversão do estado da OS entre API (`UPPER_SNAKE`) e Dart (`camelCase`) num único lugar, com teste; relógio injetável nos dois lados', 0),
  ('Dockerfile do backend gera imagem que sobe e responde em `/health`', 0),
  ('Verificações verdes no backend e no app, e CI rodando (analyze, test, lint, typecheck, build)', 0)],
  notas='Stack e arquitetura em [[Arquitetura]]. Decisões 001, 002, 006 e 012 já aceitas. Nada de BullMQ/Redis. O login por perfil no app (`redirect`) é da feature 001.')

mod('001', add_cas=[('Rotas do app protegidas por perfil: sem sessão vai ao login; perfil sem permissão não abre a rota', 0)])
mod('002', drop='Cliente com OS ativa', notas='A regra "cliente com OS ativa não pode ser inativado" é testada na feature 007, quando a OS existe.')
mod('007', add_cas=[
  ('Inativar um cliente com OS ativa é recusado (409), regra da feature 002 que só se testa aqui', 0),
  ('`GET /os` lista as OS com número, estado, cliente e veículo; `GET /os/:id` detalha uma OS', 0)])
mod('009', drop='Desconto acima de 10% aciona', add_cas=[('Confirmar orçamento com desconto acima de 10% e sem autorização aprovada é recusado (409)', 0)],
    notas='Valores em centavos (inteiro). "Acima de 10%" é estritamente maior: `desconto*100 > subtotal*10`. Desconto vale para o orçamento inteiro e não pode passar do subtotal.')
mod('010', us='US10', atores='Atendente (solicita), Gerente (decide)', cas=[
  ('O atendente solicita a autorização de um desconto acima de 10%; a solicitação nasce `PENDENTE` e o gerente recebe aviso', 0),
  ('O gerente aprova ou recusa pela própria sessão; a decisão registra gerente, valor autorizado e data', 0),
  ('O gerente pode autorizar um valor menor que o pedido (valor autorizado ≤ solicitado)', 1),
  ('Perfil diferente de Gerente não decide (403)', 0),
  ('A autorização perde a validade se o subtotal ou o desconto do orçamento mudar depois', 0),
  ('Recusa devolve o controle ao atendente, que ajusta o desconto ou segue sem ele', 0),
  ('Aprovada e válida, a autorização permite confirmar o orçamento (feature 009)', 0)],
  notas='Extensão de UC09 (`«extend»`). Decisão 007 revisada: autorização assíncrona, sem senha de gerente passando pelo backend.')
mod('011', drop='Orçamento alterado', add_cas=[('Orçamento fica imutável em `AGUARDANDO_APROVACAO`: tentativa de alterar recebe 409', 0)])
mod('011', cas=[(t, 2 if t.startswith('Cliente pedir ajuste') else f) for t, f in [x for x in F if x[0] == '011'][0][8]])
mod('012', cas=[(t, 2 if t.startswith('Serviço extra') else f) for t, f in [x for x in F if x[0] == '012'][0][8]])
mod('013', add_cas=[('Dois lançamentos simultâneos da mesma peça nunca deixam o saldo negativo (teste de concorrência)', 0)])
mod('015', cas=[
  ('Entregar com pagamentos cuja soma é igual ao total leva a OS de `CONCLUIDA` para `ENTREGUE`, tudo na mesma transação', 0),
  ('Registra forma, valor, data/hora e quem entregou', 0),
  ('Soma diferente do total (a menos ou a mais) é recusada e a OS continua em `CONCLUIDA`', 0),
  ('OS fora de `CONCLUIDA` não pode ser entregue', 0),
  ('`ENTREGUE` é estado final', 0),
  ('Vários pagamentos (formas diferentes) na mesma entrega', 0)],
  notas='Decisão 009 revisada: pagamentos só são gravados no ato da entrega, sem estado intermediário de pagamento parcial.')
mod('016', atores='Atendente, Gerente, Mecânico (fila)')
mod('017', deps=['013'], add_cas=[('O estorno das peças acontece na mesma transação do cancelamento', 0)])
for n in ('018', '019'):
    f = [x for x in F if x[0] == n][0]
    mod(n, cas=[(t, 1) for t, _ in f[8]])
for n, pref in (('017', 'Peças lançadas voltam'), ('013', 'Saldo insuficiente'), ('014', 'O atendente recebe aviso')):
    f = [x for x in F if x[0] == n][0]
    mod(n, cas=[(t, 0 if t.startswith(pref) else fl) for t, fl in f[8]])

NOME = {f[0]: f[1] for f in F}
def fname(f): return f'{f[0]} - {f[1]}'
def link(n): return f'[[{n} - {NOME[n]}]]'


# ---------- dados extras: RF, API, tabelas ----------
# feature -> (RFs, [(método, caminho, perfis, descrição)], tabelas)
X = {
 '000': ('—', [('GET', '/health', 'Público', 'Estado do serviço'), ('GET', '/docs', 'Público (dev)', 'Swagger a partir do OpenAPI')], 'todas (RLS)'),
 '001': ('RF01, RF23', [('GET', '/me', 'Todos', 'Nome, perfil e situação do usuário autenticado')], 'perfis'),
 '006': ('RF06', [('GET', '/usuarios', 'Gerente', 'Lista usuários'), ('POST', '/usuarios', 'Gerente', 'Cria usuário (Auth + perfil)'),
                  ('GET', '/usuarios/:id', 'Gerente', 'Detalha'), ('PATCH', '/usuarios/:id', 'Gerente', 'Altera nome e perfil'),
                  ('POST', '/usuarios/:id/redefinir-senha', 'Gerente', 'Nova senha'), ('POST', '/usuarios/:id/inativar', 'Gerente', 'Inativa (não o último gerente)'),
                  ('POST', '/usuarios/:id/ativar', 'Gerente', 'Reativa')], 'perfis'),
 '002': ('RF02', [('GET', '/clientes', 'Atendente', 'Busca por nome ou documento'), ('POST', '/clientes', 'Atendente', 'Cadastra'),
                  ('GET', '/clientes/:id', 'Atendente', 'Detalha'), ('PATCH', '/clientes/:id', 'Atendente', 'Altera'),
                  ('POST', '/clientes/:id/inativar', 'Atendente', 'Inativa (sem OS ativa)')], 'clientes'),
 '003': ('RF03', [('GET', '/clientes/:id/veiculos', 'Atendente', 'Veículos do cliente'), ('POST', '/clientes/:id/veiculos', 'Atendente', 'Cadastra'),
                  ('GET', '/veiculos', 'Atendente', 'Busca por placa'), ('GET', '/veiculos/:id', 'Atendente', 'Detalha'),
                  ('PATCH', '/veiculos/:id', 'Atendente', 'Altera'), ('POST', '/veiculos/:id/transferir', 'Atendente', 'Muda o dono'),
                  ('POST', '/veiculos/:id/inativar', 'Atendente', 'Inativa')], 'veiculos'),
 '005': ('RF05', [('GET', '/servicos', 'Atendente, Gerente', 'Lista (ativos para orçamento)'), ('POST', '/servicos', 'Gerente', 'Cadastra'),
                  ('PATCH', '/servicos/:id', 'Gerente', 'Altera'), ('POST', '/servicos/:id/inativar', 'Gerente', 'Inativa')], 'servicos'),
 '004': ('RF04, RF22', [('GET', '/pecas', 'Atendente, Mecânico, Almoxarife', 'Lista; `?abaixoDoMinimo=true` para o alerta'), ('POST', '/pecas', 'Almoxarife', 'Cadastra (saldo 0)'),
                  ('GET', '/pecas/:id', 'Almoxarife', 'Detalha'), ('PATCH', '/pecas/:id', 'Almoxarife', 'Altera (sem tocar o saldo)'),
                  ('POST', '/pecas/:id/inativar', 'Almoxarife', 'Inativa')], 'pecas'),
 '018': ('RF18', [('POST', '/pecas/:id/entradas', 'Almoxarife', 'Entrada: quantidade, custo e nota'), ('GET', '/pecas/:id/movimentacoes', 'Almoxarife', 'Razão do estoque')],
         'pecas, movimentacoes_estoque'),
 '007': ('RF07', [('POST', '/os', 'Atendente', 'Abre a OS em `ABERTA`'), ('GET', '/os', 'Atendente, Gerente, Mecânico', 'Lista simples (número, estado, cliente, veículo); o mecânico vê só a fila da sua etapa'),
                  ('GET', '/os/:id', 'Atendente, Gerente, Mecânico', 'Detalhe; para o mecânico, sem documento e telefone do cliente')], 'ordens_servico, historico_transicoes'),
 '008': ('RF08', [('POST', '/os/:id/diagnostico', 'Mecânico', 'Registra e leva a `DIAGNOSTICADA`'), ('PUT', '/os/:id/diagnostico/rascunho', 'Mecânico', 'Guarda rascunho (`finalizado = false`)')],
         'diagnosticos, ordens_servico, historico_transicoes'),
 '009': ('RF09', [('PUT', '/os/:id/orcamento', 'Atendente', 'Grava itens e desconto (rascunho)'), ('POST', '/os/:id/orcamento/confirmar', 'Atendente', 'Confirma e leva a `AGUARDANDO_APROVACAO`')],
         'orcamentos, itens_orcamento, ordens_servico, historico_transicoes'),
 '010': ('RF10', [('POST', '/os/:id/orcamento/solicitacao-desconto', 'Atendente', 'Pede autorização de desconto acima de 10% (nasce `PENDENTE`, avisa o gerente)'),
                  ('GET', '/solicitacoes-desconto', 'Gerente', 'Lista pendentes e decididas'),
                  ('POST', '/solicitacoes-desconto/:id/decisao', 'Gerente', 'Aprova (valor igual ou menor) ou recusa, com o próprio JWT')], 'autorizacoes_desconto, avisos'),
 '011': ('RF11', [('POST', '/os/:id/aprovacao', 'Atendente', 'Aprova (`APROVADA`) ou recusa (`CANCELADA`)')], 'aprovacoes, ordens_servico, historico_transicoes'),
 '012': ('RF12', [('POST', '/os/:id/execucao', 'Mecânico', 'Inicia e leva a `EM_EXECUCAO`'), ('POST', '/os/:id/observacoes', 'Mecânico', 'Anota andamento')],
         'ordens_servico, observacoes, historico_transicoes'),
 '013': ('RF13, RF20', [('POST', '/os/:id/pecas-usadas', 'Mecânico', 'Lança peça e baixa o saldo'), ('DELETE', '/os/:id/pecas-usadas/:pecaUsadaId', 'Mecânico', 'Estorna lançamento')],
         'pecas_usadas, movimentacoes_estoque, pecas, avisos'),
 '014': ('RF14, RF20', [('POST', '/os/:id/concluir', 'Mecânico', 'Leva a `CONCLUIDA` e cria aviso para o atendente'), ('GET', '/avisos', 'Todos', 'Avisos do próprio usuário (T24)'),
                  ('POST', '/avisos/:id/lido', 'Todos', 'Marca aviso como lido')], 'ordens_servico, historico_transicoes, avisos'),
 '015': ('RF15', [('POST', '/os/:id/entregar', 'Atendente', 'Corpo com `pagamentos[]` (forma, valor); exige soma igual ao total e leva a `ENTREGUE` numa transação')],
         'pagamentos, ordens_servico, historico_transicoes'),
 '017': ('RF17', [('POST', '/os/:id/cancelar', 'Atendente, Gerente', 'Cancela com motivo e estorna as peças na mesma transação (decisão 008)')], 'ordens_servico, historico_transicoes, pecas_usadas, movimentacoes_estoque'),
 '016': ('RF16, RF21', [('GET', '/os', 'Atendente, Gerente, Mecânico', 'Estende a lista da 007 com filtros: numero, cliente, placa, estado, de, ate (cliente e placa vão no corpo de busca ou em parâmetro sem PII nos logs)'),
                  ('GET', '/os/:id/historico', 'Atendente, Gerente, Mecânico', 'Transições')],
         'ordens_servico, historico_transicoes'),
 '019': ('RF19', [('GET', '/faturamento', 'Gerente', 'Total, quantidade e ticket médio no período (`de`, `ate`)')], 'pagamentos, ordens_servico'),
 '020': ('—', [], '—'),
}

SUBTAREFAS = [
    ('Modelo', 'tabelas e migration Prisma, RLS, gatilhos e índices extras dentro da migration (`--create-only`), conforme [[Modelo de dados]]'),
    ('API', 'rota (Zod + perfil), serviço (regra de negócio, transação) e repositório no módulo do backend'),
    ('Testes da API', 'Vitest: regras e exceções de cada CA, e permissão por perfil'),
    ('Contrato', 'OpenAPI regenerado (`npm run openapi:gerar`) e conferido no Swagger'),
    ('App: domínio e dados', 'entidades, contrato do repositório e implementação com `dio`'),
    ('App: telas', 'telas do Mapa de telas e providers Riverpod'),
    ('Testes do app', 'domínio e widget cobrindo os CAs'),
    ('Verificação', 'backend: lint, format, typecheck, test, smoke; app: format, analyze, test, build apk'),
    ('Documentação', 'CAs em ✅, devtrack e, se algo mudou, notas do vault e PDFs de `entregas/`'),
]
TAREFAS_000 = [
    'Projetos Supabase de desenvolvimento e de teste criados; chaves guardadas fora do git; `.env.example` e `mobile/env.example.json` sem valores',
    'Backend base: Express 5, TypeScript, env com Zod, Pino com redação, Helmet, rate limit, CORS, erros padronizados, `/health`',
    'JWT validado por JWKS (algoritmos do projeto, `iss`, `aud`, `exp`) e middleware de perfil',
    'Prisma: migration inicial do modelo de dados com RLS, gatilhos de só-inserção, índice único parcial e FK para `auth.users`; `shadowDatabaseUrl` no projeto de teste',
    'Teste com a chave publicável: o app não lê nem escreve nas tabelas, exceto `avisos` do próprio usuário',
    'OpenAPI + Swagger e script `openapi:gerar`',
    'Vitest e teste de arquitetura dos módulos',
    'Seed do gerente inicial e do catálogo fictício de dev; `scripts/smoke.sh` com o primeiro fluxo',
    'Dockerfile do backend',
    'App: `supabase_flutter`, `dio`, `--dart-define`, `flutter_localizations` pt-BR, permissão INTERNET no manifesto, `fromApi/toApi` do estado com teste, relógio injetável',
    'CI: backend (lint, typecheck, test) e app (analyze, test, build)',
    'Documentação: nota em `metodos/` com o passo a passo de rodar o backend; devtrack',
]
TAREFAS_020 = [
    'Testar em dispositivo Android e ajustar o layout para telas pequenas',
    'Conferir o layout web responsivo',
    'Teste de integração do fluxo completo (`scripts/smoke.sh`)',
    'Publicar a imagem Docker e a API de demonstração; publicar o web e gerar o APK',
    'Atualizar diagramas, casos de uso, histórias, ER, API e regerar os PDFs de `entregas/`',
    'Changelog, versão e tag',
]

def telas_de(n):
    return [t for t in TELAS if n in t[4]]

def plain(n): return f'{n} — {NOME[n]}'
def ac_table(cas):
    return ['| # | Critério | Status |', '|---|---|---|'] + [
        f'| CA{i:02d} | {t}{" ⚠️" if a == 1 else ""} | {"❌ Descartado (fora do MVP)" if a == 2 else "🔲 Pendente"} |' for i, (t, a) in enumerate(cas, 1)]


# ---------- guarda: não destruir progresso ----------
FORCE = '--force' in sys.argv
DRY = '--dry-run' in sys.argv
def _progresso():
    achados = []
    for p in (V / 'features').glob('*.md'):
        t = p.read_text(encoding='utf-8')
        if re.search(r'\|\s*(🔄 Em progresso|✅ Concluído)', t) or re.search(r'^status:\s*(em andamento|concluida)', t, re.M):
            achados.append(p.name)
    ck = V / 'CHECKLIST.md'
    if ck.exists():
        fases = ck.read_text(encoding='utf-8').split('## F1')[-1]
        if re.search(r'^\s*- \[x\]', fases, re.M):
            achados.append('CHECKLIST.md (tarefas de fase marcadas)')
    return achados
import re
_prog = _progresso()
if _prog and not FORCE:
    print('ABORTADO: há progresso que seria apagado:', *_prog, sep='\n  - ')
    print('Use --force para sobrescrever mesmo assim (faça backup antes) ou edite os arquivos à mão.')
    sys.exit(1)
if DRY:
    print('--dry-run: nada será escrito. Arquivos que seriam recriados:', len(F), 'features, CHECKLIST, Mapa de telas, Índice, Endpoints, Rastreabilidade')
    sys.exit(0)

# ---------- features/ ----------
(V / 'features').mkdir(exist_ok=True)
for f in F:
    n, nome, fase, uc, us, atores, rns, deps, cas, notas = f
    rf, api, tabelas = X[n]
    t = telas_de(n)
    L = ['---', f'data: {HOJE}', 'status: planejada', f'fase: {fase}', f'uc: "{uc}"', f'us: "{us}"', f'rf: "{rf}"', '---', '',
         f'# {n} — {nome}', '', '## Objetivo', '']
    if uc == '—':
        L.append(f'{FASES[fase][1]}.')
    else:
        L.append(f'Entregar **{uc} — {nome}** para o ator **{atores}**. Fluxo completo (principal, alternativos e exceções) em [[Casos de uso]], seção {uc}.')
    L += ['', '## Referências', '', '| Item | Valor |', '|---|---|',
          f'| Fase | {fase} — {FASES[fase][0]} |', f'| Caso de uso | {uc} |', f'| Histórias | {us} |', f'| Requisitos | {rf} |',
          f'| Ator | {atores} |', f'| Regras de negócio | {", ".join(rns) if rns else "—"} |',
          f'| Tabelas | {tabelas} |',
          '| Especificação | [[Casos de uso]], [[Histórias de usuário]], [[Requisitos]], [[Modelo de dados]] |', '']
    L += ['## Critérios de aceitação', ''] + ac_table(cas)
    L += ['', 'Legenda: 🔲 Pendente · 🔄 Em progresso · ✅ Concluído · ❌ Descartado. ⚠️ = fluxo deduzido, conferir com o documento oficial.', '']
    L += ['## API', '']
    if api:
        L += ['| Método | Caminho (`/api/v1`) | Perfis | O que faz |', '|---|---|---|---|'] + [f'| {m} | `{p}` | {pf} | {d} |' for m, p, pf, d in api]
        L.append('\nContrato completo em [[Endpoints]].')
    else:
        L.append('Sem endpoint próprio.')
    L += ['', '## Telas', '']
    if t:
        L += [f'- **{a} {b}** — `{c}` ({d})' for a, b, c, d, _ in t]
        L.append('\nCatálogo completo em [[Mapa de telas]].')
    else:
        L.append('Sem tela própria.')
    L += ['', '## Dependências', '']
    L += ([f'- {link(d)}' for d in deps] if deps else ['Nenhuma.'])
    L += ['', '## Tarefas', '', 'As tarefas desta feature ficam no [[CHECKLIST]], na seção da fase.', '']
    if notas:
        L += ['## Notas técnicas', '', notas, '']
    (V / 'features' / f'{n} - {nome}.md').write_text('\n'.join(L), encoding='utf-8')

# ---------- telas/ ----------
(V / 'telas').mkdir(exist_ok=True)
L = ['---', f'data: {HOJE}', '---', '', '# Mapa de telas', '',
     'Telas derivadas dos casos de uso, sem inventar nada além deles. Cada tela pertence a uma ou mais features.',
     'Rotas definidas aqui valem para o `go_router`; se uma rota mudar, muda aqui primeiro.', '',
     '| ID | Tela | Rota | Perfis | Features |', '|---|---|---|---|---|']
for a, b, c, d, ucs in TELAS:
    L.append(f'| {a} | {b} | `{c}` | {d} | {", ".join(link(u) for u in ucs)} |')
L += ['', '## Acesso por perfil (RN09)', '', '| Perfil | Telas |', '|---|---|']
for p in ['Atendente', 'Mecânico', 'Almoxarife', 'Gerente']:
    ids = [t[0] for t in TELAS if p in t[3] or 'Todos' in t[3]]
    L.append(f'| {p} | {", ".join(ids)} |')
(V / 'telas' / 'Mapa de telas.md').write_text('\n'.join(L) + '\n', encoding='utf-8')

# ---------- CHECKLIST ----------
L = ['---', f'data: {HOJE}', '---', '', '# CHECKLIST — OficinaFácil', '',
     'Lista mestra de tudo que o projeto precisa ter. Marque com `[x]` conforme avança.',
     'Stack: Flutter + backend Node/TypeScript + Supabase ([[Arquitetura]]).', '',
     '**Regras para marcar:**',
     '1. Cada feature de caso de uso tem 9 tarefas fixas (modelo, API, testes da API, contrato, app em dois blocos, testes do app, verificação, documentação). A `000` e a `020` têm tarefas próprias.',
     '2. A linha da feature só é marcada quando as tarefas estão marcadas **e** todos os CAs do arquivo da feature estão ✅.',
     '3. A fase só é marcada quando todas as suas features estão marcadas.',
     '4. O comportamento esperado vive no arquivo da feature (CAs). O que construir vive aqui. Não duplicar texto entre os dois.',
     '5. Ao concluir uma feature: atualizar o devtrack, o quadro do GitHub Projects e, se mudou algo, as notas do vault e os PDFs de `entregas/`.', '',
     '## Entrega 1 (concluída)', '',
     '- [x] Tela inicial com logo, nome e etapas da OS',
     '- [x] Repositório no GitHub',
     '- [x] Nome e ícone (web e Android)',
     '- [x] Diagramas Mermaid (casos de uso, estados, arquitetura, pastas)',
     '- [x] `StatusOrdemServico` no domínio, com testes',
     '- [x] Documento de casos de uso (UC01 a UC19)',
     '- [x] Histórias de usuário (23, derivadas)',
     '- [x] PDFs dos documentos',
     '- [x] Quadro no GitHub Projects (visão Board a criar pela interface)', '',
     '## Base de documentação e arquitetura (2026-10-30)', '',
     '- [x] Stack definida: Flutter + Node/TypeScript + Supabase (D1, D2, D6, D12)',
     '- [x] Documentação toda dentro do vault: [[Requisitos]], [[Casos de uso]], [[Histórias de usuário]], [[Arquitetura]], [[Modelo de dados]], [[Diagramas]], [[Roadmap]], 12 decisões em `decisions/`',
     '- [x] [[Endpoints]] e [[Rastreabilidade]] gerados das features',
     '- [x] README e CLAUDE.md alinhados à nova stack, com regras invioláveis',
     '- [x] Revisão por agente Opus de tudo, com correções aplicadas (ver [[2026-10-30 - Revisão Opus]])', '',
     '## Pendências transversais', '',
     '- [ ] Teste do app em dispositivo Android (celular não detectado pelo adb em 2026-10-30)',
     '- [x] Decisão 004 resolvida: o professor não entregou documento; seguem UC18, UC19 e as histórias deduzidas',
     '- [ ] Decisões 003, 005 e 011 abertas; 007 a 010 propostas, confirmar (ver [[00 - Índice de decisões]])',
     '- [ ] Criar a visão Board no GitHub Projects',
     '- [ ] Decidir se `identidade-visual/opcoes-v2/` fica no vault ou sai',
     '- [ ] Escolher hospedagem do backend (Railway ou Render) e confirmar planos gratuitos',
     '- [x] Vault versionado no mesmo repositório do código (decisão do usuário, 2026-10-30)',
     '- [x] Mudanças de regras do CLAUDE.md aplicadas (ver [[2026-10-30 - Revisão Opus]])',
     '- [ ] Decidir escopo: anonimização LGPD (RNF09), Plano de testes e Wireframes', '']
for fase, (titulo, desc) in FASES.items():
    L += [f'## {fase} — {titulo}', '', f'_{desc}_', '', f'- [ ] **Fase {fase} concluída**', '']
    for f in [x for x in F if x[2] == fase]:
        n, nome = f[0], f[1]
        L += [f'### {link(n)}' + (f' ({f[3]})' if f[3] != '—' else ''), '', f'- [ ] **{n} — {nome}**']
        if n == '000':
            L += [f'  - [ ] {x}' for x in TAREFAS_000]
        elif n == '020':
            L += [f'  - [ ] {x}' for x in TAREFAS_020]
        else:
            L += [f'  - [ ] {s}: {d}' for s, d in SUBTAREFAS]
        L.append('')
(V / 'CHECKLIST.md').write_text('\n'.join(L), encoding='utf-8')

# ---------- Índice ----------
(V / '00 - Índice.md').write_text('\n'.join([
 '---', f'data: {HOJE}', '---', '', '# OficinaFácil — Índice do vault', '',
 '- [[OficinaFácil — Visão Geral]]', '- [[Convenções]]', '- [[CHECKLIST]] — lista mestra marcável', '- [[Mapa de telas]]',
 '- [[Roadmap]]', '- [[00 - Índice de decisões]]', '- [[atual|Prioridades atuais]]', '',
 '## Especificação', '', '- [[Requisitos]] · [[Casos de uso]] · [[Histórias de usuário]] · [[Rastreabilidade]]',
 '- [[Arquitetura]] · [[Modelo de dados]] · [[Diagramas]] · [[Endpoints]]', '',
 '## Features (numeração = número do caso de uso)', '', '| Feature | Fase | UC | RF | Histórias |', '|---|---|---|---|---|',
] + [f'| {link(f[0])} | {f[2]} | {f[3]} | {X[f[0]][0]} | {f[4]} |' for f in F] + ['',
 '## Pastas', '', '- `features/`: uma spec por feature, com critérios de aceitação e API',
 '- `requisitos/`: requisitos, casos de uso, histórias, rastreabilidade', '- `arquitetura/`: arquitetura, modelo de dados, diagramas', '- `api/`: contrato dos endpoints (gerado)',
 '- `telas/`: mapa de telas e rotas', '- `decisions/`: uma decisão por arquivo', '- `auditorias/`: auditorias e revisões', '- `entregas/`: PDFs gerados', '- `identidade-visual/`: kit do logo', '- `metodos/`: como gerar as notas e os PDFs',
 '- `devtrack/`: log de cada sessão', '- `commits/`: um arquivo por commit importante', '- `prioridade/`: o que fazer agora', '']), encoding='utf-8')

# ================= notas geradas dentro do vault =================
GER = '> Nota GERADA por script a partir das features. Não editar à mão.'
(V / 'api').mkdir(exist_ok=True)
L = ['---', f'data: {HOJE}', '---', '', GER, '', '# Endpoints — API do OficinaFácil', '',
     'Contrato resumido por caso de uso. O contrato completo e sempre atual é o OpenAPI do backend (`backend/openapi.json`, Swagger em `/docs`). Arquitetura em [[Arquitetura]].', '',
     '- **Base:** `/api/v1`. **Formato:** JSON. **Dinheiro:** centavos inteiros. **Datas:** ISO 8601.',
     '- **Autenticação:** `Authorization: Bearer <JWT do Supabase>` em todas as rotas, exceto `/health`.',
     '- **Autorização:** o perfil vem da tabela `perfis`; perfil sem permissão recebe `403`, sem token `401`.',
     '- **Erros:** formato único `{ "erro": { "codigo": "...", "mensagem": "..." } }`; validação com Zod devolve `422`; transição de estado inválida devolve `409`.',
     '- **Estados da OS:** `ABERTA`, `DIAGNOSTICADA`, `AGUARDANDO_APROVACAO`, `APROVADA`, `EM_EXECUCAO`, `CONCLUIDA`, `ENTREGUE`, `CANCELADA`.', '',
     '| Feature | UC | Método | Caminho | Perfis | O que faz |', '|---|---|---|---|---|---|']
for f in F:
    for m, p, pf, d in X[f[0]][1]:
        L.append(f'| {link(f[0])} | {f[3]} | {m} | `{p}` | {pf} | {d} |')
L += ['', 'Login e logout não têm endpoint: são do Supabase Auth, chamados direto pelo app.',
      'Avisos entre perfis (RF20) chegam por Supabase Realtime, sem endpoint próprio.', '']
(V / 'api' / 'Endpoints.md').write_text('\n'.join(L), encoding='utf-8')

L = ['---', f'data: {HOJE}', '---', '', GER, '', '# Rastreabilidade', '',
     'RF → UC → história → feature → endpoints → telas → tabelas. Requisitos em [[Requisitos]].', '',
     '| RF | UC | Histórias | Feature | Endpoints | Telas | Tabelas |', '|---|---|---|---|---|---|---|']
for f in F:
    rf, api, tab = X[f[0]]
    eps = '<br>'.join(f'{m} `{p}`' for m, p, _, _ in api) or '—'
    tl = ', '.join(t[0] for t in telas_de(f[0])) or '—'
    L.append(f'| {rf} | {f[3]} | {f[4]} | {link(f[0])} | {eps} | {tl} | {tab} |')
L += ['', 'Telas em [[Mapa de telas]].', '']
(V / 'requisitos').mkdir(exist_ok=True)
(V / 'requisitos' / 'Rastreabilidade.md').write_text('\n'.join(L), encoding='utf-8')

print('features:', len(F), '· telas:', len(TELAS), '· notas geradas: Endpoints, Rastreabilidade')

# ---------- checagem de links ----------
import re
_nomes = {p.stem for p in V.rglob('*.md')}
_q = sorted({(p.name, m) for p in V.rglob('*.md') for m in re.findall(r'\[\[([^\]|#]+)', p.read_text(encoding='utf-8'))
             if m not in _nomes and m != 'links'})
print('links quebrados:', _q)
