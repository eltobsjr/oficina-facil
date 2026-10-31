#!/usr/bin/env python3
"""Gera metodos/trello-quadro.json: a especificação do quadro do Trello a partir do vault.

Lê features/*.md e o CHECKLIST.md (status e tarefas) e junta aos cartões de trabalho já concluído.
Não fala com o Trello: o JSON é a entrada para criar o quadro (pelo MCP do Trello ou pela API).
Uso: python3 metodos/gerar-trello.py
"""
import json
import pathlib
import re

V = pathlib.Path(__file__).resolve().parents[1]
URL_QUADRO = 'https://trello.com/b/6ae4da0b233ab7b22fcc5814'

# Semana de cada feature (Roadmap) e fim da semana (domingo).
SEMANAS = {1: '2026-11-08', 2: '2026-11-15', 3: '2026-11-22', 4: '2026-11-29', 5: '2026-12-06', 6: '2026-12-13',
           7: '2026-12-20', 8: '2026-12-27', 9: '2027-01-03', 10: '2027-01-10', 11: '2027-01-17', 12: '2027-01-24',
           13: '2027-01-31', 14: '2027-02-07', 15: '2027-02-14'}
SEMANA_DA_FEATURE = {'000': 1, '006': 2, '001': 2, '002': 3, '003': 3, '005': 4, '004': 4, '018': 5, '007': 6, '008': 7,
                     '009': 7, '010': 8, '011': 10, '012': 10, '013': 11, '014': 12, '015': 12, '017': 13, '016': 14,
                     '019': 14, '020': 15}
FASE_DA_FEATURE = {'000': 'F1', '001': 'F2', '006': 'F2', '002': 'F3', '003': 'F3', '005': 'F4', '004': 'F4', '018': 'F4',
                   '007': 'F5', '008': 'F5', '009': 'F5', '010': 'F5', '011': 'F6', '012': 'F6', '013': 'F6', '014': 'F7',
                   '015': 'F7', '017': 'F7', '016': 'F8', '019': 'F8', '020': 'F9'}
# Features cujo backend ou app já existem (cartão fica em "Em andamento" e não em "Próximas").
EM_ANDAMENTO = {'000', '001', '006'}

ETIQUETAS = [
    {'nome': 'F0 Análise', 'cor': 'sky'}, {'nome': 'F1 Fundação', 'cor': 'black'}, {'nome': 'F2 Acesso', 'cor': 'blue'},
    {'nome': 'F3 Cadastros', 'cor': 'green'}, {'nome': 'F4 Catálogos', 'cor': 'lime'}, {'nome': 'F5 Orçar', 'cor': 'orange'},
    {'nome': 'F6 Execução', 'cor': 'yellow'}, {'nome': 'F7 Entrega', 'cor': 'red'}, {'nome': 'F8 Gestão', 'cor': 'purple'},
    {'nome': 'F9 Acabamento', 'cor': 'pink'}, {'nome': 'Backend', 'cor': 'blue_dark'}, {'nome': 'App', 'cor': 'green_dark'},
    {'nome': 'Documentação', 'cor': 'sky_light'}, {'nome': 'Marco', 'cor': 'red_dark'}, {'nome': 'Decisão', 'cor': 'orange_dark'},
    {'nome': 'Bloqueado pelo usuário', 'cor': 'red_light'},
]
NOME_FASE = {'F1': 'F1 Fundação', 'F2': 'F2 Acesso', 'F3': 'F3 Cadastros', 'F4': 'F4 Catálogos', 'F5': 'F5 Orçar',
             'F6': 'F6 Execução', 'F7': 'F7 Entrega', 'F8': 'F8 Gestão', 'F9': 'F9 Acabamento'}


def cartao(titulo, descricao, etiquetas, vencimento=None, checklist=None, concluido=False):
    c = {'titulo': titulo, 'descricao': descricao, 'etiquetas': etiquetas}
    if vencimento:
        c['vencimento'] = vencimento
    if concluido:
        c['vencimentoConcluido'] = True
    if checklist:
        c['checklist'] = {'nome': 'Tarefas', 'itens': [{'texto': t, 'feito': f} for t, f in checklist]}
    return c


# ---------- tarefas por feature, lidas do CHECKLIST ----------
checklist = (V / 'CHECKLIST.md').read_text(encoding='utf-8')
tarefas = {}
for m in re.finditer(r'^- \[[ x]\] \*\*(\d{3}) — [^\n]*\n((?:  - \[[ x]\] [^\n]*\n)+)', checklist, re.M):
    itens = []
    for linha in m.group(2).splitlines():
        feito = linha.strip().startswith('- [x]')
        texto = re.sub(r'^\s*- \[[ x]\] ', '', linha)
        texto = re.sub(r'\[\[([^\]|]+)(\|[^\]]+)?\]\]', r'\1', texto)
        itens.append((texto[:300], feito))
    tarefas[m.group(1)] = itens

# ---------- features ----------
features = {}
for p in sorted((V / 'features').glob('*.md')):
    t = p.read_text(encoding='utf-8')
    n = p.name[:3]
    nome = re.search(r'^# \d{3} — (.+)$', t, re.M).group(1)
    uc = re.search(r'^uc: "([^"]*)"', t, re.M).group(1)
    cas = re.findall(r'^\| CA\d\d \| (.*?) \| (.*?) \|$', t, re.M)
    features[n] = {'nome': nome, 'uc': uc, 'cas': cas, 'arquivo': f'OficinaFacilSecondBrain/features/{p.name}'}


def descricao_feature(n):
    f = features[n]
    linhas = [f"**{f['uc']}**" if f['uc'] != '—' else '**Fundação**', '',
              f"Semana {SEMANA_DA_FEATURE[n]} do Roadmap. Especificação: `{f['arquivo']}`.", '', '**Critérios de aceitação**']
    for texto, status in f['cas']:
        marca = '✅' if status.startswith('✅') else ('🔄' if status.startswith('🔄') else ('❌' if status.startswith('❌') else '⬜'))
        linhas.append(f'- {marca} {texto}')
    return '\n'.join(linhas)


def cartao_feature(n, concluido=False):
    f = features[n]
    etiquetas = [NOME_FASE[FASE_DA_FEATURE[n]]]
    return cartao(f"S{SEMANA_DA_FEATURE[n]} · {n} {f['nome']}", descricao_feature(n), etiquetas,
                  SEMANAS[SEMANA_DA_FEATURE[n]], tarefas.get(n), concluido)


# ---------- concluído ----------
concluidos = [
    cartao('Tela inicial, logo, nome e ícones (Entrega 1)', 'Logo porca com check `#1F4E79`, favicon, ícones web e Android, tela inicial. Kit em `OficinaFacilSecondBrain/identidade-visual/`.', ['F0 Análise', 'App']),
    cartao('Repositório no GitHub', 'github.com/eltobsjr/oficina-facil. Monorepo com `mobile/`, `backend/` e o vault.', ['F0 Análise']),
    cartao('StatusOrdemServico no domínio, com testes', 'Enum de 8 estados, transições e cancelamento; tabela 8×8 testada; conversão `fromApi`/`toApi`.', ['F0 Análise', 'App']),
    cartao('Casos de uso (19 UCs) e diagramas', 'Atores, regras RN01 a RN09, fluxos e diagramas Mermaid. Nota `requisitos/Casos de uso`.', ['F0 Análise', 'Documentação']),
    cartao('Histórias de usuário (23)', 'Derivadas dos casos de uso. Nota `requisitos/Histórias de usuário`.', ['F0 Análise', 'Documentação']),
    cartao('Requisitos RF e RNF, glossário', '23 requisitos funcionais e 20 não funcionais. Nota `requisitos/Requisitos`.', ['F0 Análise', 'Documentação']),
    cartao('Modelo de dados (17 tabelas)', 'ER em 3 diagramas, enums, restrições e RLS. Nota `arquitetura/Modelo de dados`.', ['F0 Análise', 'Documentação']),
    cartao('Arquitetura e stack', 'Flutter + Node/TypeScript + Supabase. Nota `arquitetura/Arquitetura`.', ['F0 Análise', 'Documentação']),
    cartao('12 decisões registradas', 'Uma por arquivo em `decisions/`: 4 aceitas, 4 propostas, 4 abertas.', ['F0 Análise', 'Decisão']),
    cartao('Vault SecondBrain, CHECKLIST e Roadmap semanal', 'Documentação toda no vault, dentro do repositório. Cronograma de 15 semanas até 14/02/2027.', ['F0 Análise', 'Documentação']),
    cartao('CLAUDE.md com 30 regras e README', 'Regras inviolábeis do projeto e README detalhado.', ['F0 Análise', 'Documentação']),
    cartao('Auditoria externa e revisão Opus', 'Duas revisões independentes; todas as correções aplicadas. Notas em `auditorias/`.', ['F0 Análise', 'Documentação']),
    cartao('PDFs de entrega', 'Nove documentos em `entregas/` com diagramas renderizados.', ['F0 Análise', 'Documentação']),
    cartao('F1 · Banco no Supabase com RLS', '17 tabelas, 22 CHECKs, 6 gatilhos de só-inserção, índice parcial, FK para `auth.users`, Realtime em `avisos`; app sem login recebe 401.', ['F1 Fundação', 'Backend']),
    cartao('F1 · Backend base', 'Express 5, TypeScript, Zod, Pino, Helmet, rate limit, erros no formato único, JWT por JWKS, OpenAPI/Swagger, Docker, `smoke.sh`.', ['F1 Fundação', 'Backend']),
    cartao('F1 · App ligado ao Supabase e ao backend', '`supabase_flutter`, `dio`, configuração por `--dart-define`, pt-BR.', ['F1 Fundação', 'App']),
    cartao('S1 · Backend de usuários (006)', 'Listar, criar, detalhar, alterar, redefinir senha, inativar, ativar; último gerente protegido por `FOR UPDATE`. 79 testes.', ['F2 Acesso', 'Backend']),
    cartao('S2 · Login, sessão e menu por perfil (001)', 'T01 Login, T02 Início, redirecionamento por perfil comparado com o Mapa de telas, menu e shell responsivo.', ['F2 Acesso', 'App']),
    cartao('S2 · Telas de usuários T03 e T04 (006)', 'Lista com busca, filtros e rolagem infinita; formulário de criar e editar; inativar, reativar e redefinir senha. 216 testes no app.', ['F2 Acesso', 'App']),
]

# ---------- em andamento, próximas, bloqueado, decisões ----------
andamento = [cartao_feature(n) for n in ('000', '001', '006')]
proximas = [cartao_feature(n) for n in sorted(features, key=lambda k: (SEMANA_DA_FEATURE[k], k)) if n not in EM_ANDAMENTO]
marcos = [
    cartao('Marco M1 · Login com 4 perfis e gestão de usuários', 'Fim da S2 (15/11/2026).', ['Marco'], SEMANAS[2]),
    cartao('Marco M2 · Cadastros e estoque completos', 'Fim da S5 (06/12/2026).', ['Marco'], SEMANAS[5]),
    cartao('Marco M3 · OS orçada, com desconto aprovado pelo gerente', 'Fim da S8 (27/12/2026).', ['Marco'], SEMANAS[8]),
    cartao('Marco M4 · Ciclo completo da OS até a entrega', 'Fim da S13 (31/01/2027).', ['Marco'], SEMANAS[13]),
    cartao('Marco M5 · Sistema completo em web e Android, API no ar', 'Fim da S15 (14/02/2027).', ['Marco'], SEMANAS[15]),
    cartao('S9 · Folga de Ano-Novo e dívida técnica', 'Sem feature nova: absorve atrasos, revisão geral, PDFs, atualizar o plano. **A decisão 003 precisa estar tomada até o fim desta semana.**', ['Documentação'], SEMANAS[9]),
]
bloqueado = [
    cartao('Rotacionar a senha do banco e a chave anon', 'Foram coladas no chat.', ['Bloqueado pelo usuário', 'F1 Fundação'], SEMANAS[1]),
    cartao('Testar o app no Android real', 'O celular não foi detectado pelo `adb`. Habilitar a depuração USB.', ['Bloqueado pelo usuário', 'App']),
    cartao('Criar a visão Board no GitHub Projects (opcional)', 'Só pela interface; o `gh` não cria visões. O Trello passa a ser o quadro principal.', ['Bloqueado pelo usuário']),
]
decisoes = [
    cartao('Decisão 003 · Ajuste do orçamento e serviço extra', 'Bloqueia a S10. Recomendação: no MVP o cliente só aprova ou recusa. Até o fim da S9.', ['Decisão'], SEMANAS[9]),
    cartao('Decisão 005 · Recorte de entrega', 'Tudo ao final ou por marco? Depende do que o professor pedir a cada semana.', ['Decisão']),
    cartao('Decisão 011 · UML formal', 'Os diagramas são Mermaid. Confirmar com o professor se atendem ao "UML" pedido.', ['Decisão']),
    cartao('Confirmar as propostas 007 a 010', 'Desconto assíncrono, estorno no cancelamento, pagamento só na entrega, avisos no app. Seguimos com elas até contestar. Até a S5.', ['Decisão'], SEMANAS[5]),
    cartao('Aprovar anonimização LGPD, Plano de testes e Wireframes', 'Exigem escopo novo (UC, RF, documentos). Aguardam aprovação.', ['Decisão']),
]

quadro = {
    'quadro': 'OficinaFácil',
    'url': URL_QUADRO,
    'etiquetas': ETIQUETAS,
    'listas': [
        {'nome': '✅ Concluído', 'cartoes': concluidos},
        {'nome': '🔄 Em andamento', 'cartoes': andamento},
        {'nome': '⛔ Bloqueado (depende do usuário)', 'cartoes': bloqueado},
        {'nome': '❓ Decisões', 'cartoes': decisoes},
        {'nome': '⏭️ Próximas, em ordem de execução', 'cartoes': proximas},
        {'nome': '🏁 Marcos e folga', 'cartoes': marcos},
    ],
}
saida = V / 'metodos' / 'trello-quadro.json'
saida.write_text(json.dumps(quadro, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
total = sum(len(lista['cartoes']) for lista in quadro['listas'])
print(f"{saida.name}: {len(quadro['listas'])} listas, {total} cartões, {len(ETIQUETAS)} etiquetas")
for lista in quadro['listas']:
    print(f"  {lista['nome']}: {len(lista['cartoes'])}")
