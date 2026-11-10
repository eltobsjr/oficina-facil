#!/usr/bin/env python3
"""Gera a página "Diagramas e andamento" a partir do vault.

Lê `features/*.md`, `CHECKLIST.md`, `telas/Mapa de telas.md` e as páginas do app em `mobile/lib`
e escreve um HTML único, com índice lateral, o andamento por fase e, para cada feature, o diagrama,
o impacto, os critérios e as tarefas. Não escreve nada no vault.

Uso:
    python3 metodos/gerar-diagramas.py SAIDA.html

Depois de rodar, publique o HTML como artifact (mesmo caminho de arquivo, para manter o endereço).
Quando entrar uma página nova no app, acrescente o arquivo em PAGINAS.
"""

import html
import re
import sys
from datetime import date
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
REPO = RAIZ.parent

# Página do app -> telas do Mapa de telas que ela implementa.
PAGINAS = {
    "login_page.dart": ["T01"],
    "paginas_de_sessao.dart": ["T25", "T26"],
    "inicio_page.dart": ["T02"],
    "usuarios_page.dart": ["T03"],
    "usuario_form_page.dart": ["T04"],
    "clientes_page.dart": ["T05"],
    "cliente_form_page.dart": ["T06"],
    "veiculos_do_cliente_page.dart": ["T07"],
    "veiculo_form_page.dart": ["T07"],
}

LINKS = {
    "telas": "https://claude.ai/artifact/Rex4DaKEukimei8rmLSfLR",
    "design": "https://claude.ai/artifact/5eHASyyNSZeUqBQpSApv5X",
}

ICONES_CA = {"✅": "feito", "🔄": "andamento", "🔲": "pendente", "❌": "descartado"}
ROTULO_CA = {"feito": "Concluído", "andamento": "Em andamento", "pendente": "Pendente", "descartado": "Descartado"}


def ler(caminho):
    return Path(caminho).read_text(encoding="utf-8")


def inline(texto, nomes):
    """Markdown mínimo: links [[ ]], negrito e código."""
    texto = html.escape(texto, quote=False)

    def link(m):
        alvo, _, rotulo = m.group(1).partition("|")
        numero = re.match(r"(\d{3}) - ", alvo)
        rotulo = rotulo or alvo
        if numero and numero.group(1) in nomes:
            return f'<a href="#f{numero.group(1)}">{rotulo}</a>'
        return rotulo

    texto = re.sub(r"\[\[([^\]]+)\]\]", link, texto)
    texto = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", texto)
    texto = re.sub(r"`([^`]+)`", r"<code>\1</code>", texto)
    return texto


def secao(corpo, titulo):
    """Texto entre `## titulo` e o próximo `## `."""
    m = re.search(rf"^## {re.escape(titulo)}\s*\n(.*?)(?=^## |\Z)", corpo, re.S | re.M)
    return m.group(1).strip() if m else ""


def tabela(texto):
    linhas = [l for l in texto.splitlines() if l.strip().startswith("|")]
    saida = []
    for l in linhas:
        celulas = [c.strip() for c in l.strip().strip("|").split("|")]
        if all(re.fullmatch(r"-+", c) for c in celulas):
            continue
        saida.append(celulas)
    return saida[1:] if saida else []


def ler_feature(caminho):
    corpo = ler(caminho)
    numero = caminho.name[:3]
    titulo = re.search(r"^# (\d{3}) — (.+)$", corpo, re.M)
    meta = dict(re.findall(r"^(\w+): \"?([^\"\n]+)\"?$", corpo.split("---")[1], re.M))
    diagrama = re.search(r"```mermaid\n(.*?)```", secao(corpo, "Diagrama"), re.S)
    impacto_m = re.search(r"### Impacto no sistema\s*\n(.*?)(?=^## |\Z)", corpo, re.S | re.M)
    criterios = []
    for c in tabela(secao(corpo, "Critérios de aceitação")):
        if len(c) >= 3 and c[0].startswith("CA"):
            icone = next((i for i in ICONES_CA if c[2].startswith(i)), "🔲")
            criterios.append((c[0], c[1], ICONES_CA[icone], c[2][len(icone):].strip(" —-")))
    return {
        "numero": numero,
        "nome": titulo.group(2) if titulo else caminho.stem,
        "fase": meta.get("fase", ""),
        "uc": meta.get("uc", ""),
        "objetivo": secao(corpo, "Objetivo"),
        "diagrama": diagrama.group(1).strip() if diagrama else "",
        "impacto": [l[2:] for l in (impacto_m.group(1).strip().splitlines() if impacto_m else []) if l.startswith("- ")],
        "criterios": criterios,
        "api": tabela(secao(corpo, "API")),
        "telas": [l[2:] for l in secao(corpo, "Telas").splitlines() if l.startswith("- ")],
        "deps": re.findall(r"\[\[(\d{3}) - ", secao(corpo, "Dependências")),
        "tarefas": [],
        "linha_marcada": False,
    }


def ler_checklist(texto, features):
    fases = []
    atual_fase = atual_feat = None
    for linha in texto.splitlines():
        m = re.match(r"^## (F\d) — (.+)$", linha)
        if m:
            atual_fase = {"id": m.group(1), "nome": m.group(2), "descricao": "", "concluida": False, "features": []}
            fases.append(atual_fase)
            atual_feat = None
            continue
        if atual_fase is None:
            continue
        if linha.startswith("_") and not atual_fase["descricao"]:
            atual_fase["descricao"] = linha.strip("_ ")
        m = re.match(r"^- \[(x| )\] \*\*Fase ", linha)
        if m:
            atual_fase["concluida"] = m.group(1) == "x"
        m = re.match(r"^- \[(x| )\] \*\*(\d{3}) — ", linha)
        if m and m.group(2) in features:
            atual_feat = features[m.group(2)]
            atual_feat["linha_marcada"] = m.group(1) == "x"
            atual_fase["features"].append(atual_feat["numero"])
            continue
        m = re.match(r"^  - \[(x| )\] (.+)$", linha)
        if m and atual_feat is not None:
            atual_feat["tarefas"].append((m.group(1) == "x", m.group(2)))
    return fases


def pendencias_transversais(texto):
    bloco = re.search(r"^## Pendências transversais\s*\n(.*?)(?=^## |\Z)", texto, re.S | re.M)
    itens = []
    for l in (bloco.group(1) if bloco else "").splitlines():
        m = re.match(r"^- \[(x| )\] (.+)$", l)
        if m:
            itens.append((m.group(1) == "x", m.group(2)))
    return itens


def telas_do_mapa():
    saida = []
    for c in tabela(ler(RAIZ / "telas" / "Mapa de telas.md")):
        if re.fullmatch(r"T\d+", c[0]):
            saida.append({"id": c[0], "nome": c[1], "rota": c[2].strip("`"), "perfis": c[3], "features": re.findall(r"\[\[(\d{3}) - ", c[4])})
    return saida


def telas_no_app():
    existentes = set()
    desconhecidas = []
    for p in (REPO / "mobile" / "lib").rglob("*.dart"):
        if "presentation/pages" in p.as_posix():
            if p.name in PAGINAS:
                existentes.update(PAGINAS[p.name])
            else:
                desconhecidas.append(p.name)
    if desconhecidas:
        print("Página do app fora de PAGINAS:", ", ".join(sorted(desconhecidas)), file=sys.stderr)
    return existentes


def situacao(f):
    cas = [c for c in f["criterios"] if c[2] != "descartado"]
    feitos = sum(1 for c in cas if c[2] == "feito")
    tarefas_ok = sum(1 for t in f["tarefas"] if t[0])
    if f["linha_marcada"] and cas and feitos == len(cas):
        return "feito"
    if feitos or tarefas_ok:
        return "andamento"
    return "pendente"


def barra(feito, total):
    pct = round(100 * feito / total) if total else 0
    return f'<div class="barra" role="img" aria-label="{feito} de {total}"><span style="width:{pct}%"></span></div>'


def gerar():
    arquivos = sorted((RAIZ / "features").glob("0*.md"))
    features = {f.name[:3]: ler_feature(f) for f in arquivos}
    checklist = ler(RAIZ / "CHECKLIST.md")
    fases = ler_checklist(checklist, features)
    transversais = pendencias_transversais(checklist)
    mapa = telas_do_mapa()
    no_app = telas_no_app()
    nomes = set(features)

    for f in features.values():
        f["situacao"] = situacao(f)

    total_cas = sum(1 for f in features.values() for c in f["criterios"] if c[2] != "descartado")
    cas_ok = sum(1 for f in features.values() for c in f["criterios"] if c[2] == "feito")
    total_tar = sum(len(f["tarefas"]) for f in features.values())
    tar_ok = sum(1 for f in features.values() for t in f["tarefas"] if t[0])
    feat_ok = sum(1 for f in features.values() if f["situacao"] == "feito")

    def sel(situ):
        return {"feito": "Concluída", "andamento": "Em andamento", "pendente": "Pendente"}[situ]

    # --- índice lateral
    indice = ['<a class="nav-top" href="#andamento">Andamento</a>', '<a class="nav-top" href="#telas">Telas do app</a>']
    for fase in fases:
        indice.append(f'<div class="nav-fase">{fase["id"]} · {html.escape(fase["nome"])}</div>')
        for n in fase["features"]:
            f = features[n]
            indice.append(f'<a class="nav-f s-{f["situacao"]}" href="#f{n}"><span class="pt" aria-hidden="true"></span>{n} {html.escape(f["nome"])}<span class="sr"> ({sel(f["situacao"])})</span></a>')

    # --- andamento
    linhas_fase = []
    for fase in fases:
        fs = [features[n] for n in fase["features"]]
        ok = sum(1 for f in fs if f["situacao"] == "feito")
        linhas_fase.append(
            f'<tr><td><strong>{fase["id"]}</strong> {html.escape(fase["nome"])}<div class="mut">{html.escape(fase["descricao"])}</div></td>'
            f'<td class="num">{ok}/{len(fs)}</td><td>{barra(ok, len(fs))}</td></tr>'
        )

    feito_li, falta_li = [], []
    for fase in fases:
        for n in fase["features"]:
            f = features[n]
            ok_t = [t[1] for t in f["tarefas"] if t[0]]
            falta_t = [t[1] for t in f["tarefas"] if not t[0]]
            if ok_t:
                feito_li.append(f'<li><a href="#f{n}">{n} {html.escape(f["nome"])}</a><span class="mut"> · {len(ok_t)} de {len(f["tarefas"])} tarefas</span></li>')
            cas_falta = [c for c in f["criterios"] if c[2] in ("pendente", "andamento")]
            if falta_t or cas_falta:
                resumo = f"{len(falta_t)} tarefas e {len(cas_falta)} critérios" if f["tarefas"] else f"{len(cas_falta)} critérios"
                falta_li.append(f'<li><a href="#f{n}">{n} {html.escape(f["nome"])}</a><span class="mut"> · falta {resumo}</span></li>')

    transv_li = "".join(
        f'<li class="{"ok" if ok else "ab"}"><span class="tick" aria-hidden="true">{"✓" if ok else "○"}</span>{inline(t, nomes)}</li>' for ok, t in transversais
    )

    andamento = f"""
<section id="andamento">
  <h2>Andamento</h2>
  <div class="cartoes">
    <div class="cartao"><span class="k">Features concluídas</span><span class="v num">{feat_ok}<small>/{len(features)}</small></span></div>
    <div class="cartao"><span class="k">Critérios de aceitação</span><span class="v num">{cas_ok}<small>/{total_cas}</small></span></div>
    <div class="cartao"><span class="k">Tarefas do CHECKLIST</span><span class="v num">{tar_ok}<small>/{total_tar}</small></span></div>
    <div class="cartao"><span class="k">Telas no app</span><span class="v num">{len(no_app)}<small>/{len(mapa)}</small></span></div>
  </div>
  <div class="tabela"><table><thead><tr><th>Fase</th><th>Features</th><th>Progresso</th></tr></thead><tbody>{"".join(linhas_fase)}</tbody></table></div>
  <div class="duas">
    <div><h3>O que já foi feito</h3><ul class="lista">{"".join(feito_li) or "<li>Nada ainda.</li>"}</ul></div>
    <div><h3>O que falta</h3><ul class="lista">{"".join(falta_li)}</ul></div>
  </div>
  <h3>Pendências transversais</h3>
  <ul class="lista transv">{transv_li}</ul>
</section>"""

    # --- telas
    linhas_tela = []
    for t in mapa:
        existe = t["id"] in no_app
        feats = ", ".join(f'<a href="#f{n}">{n}</a>' for n in t["features"] if n in nomes)
        linhas_tela.append(
            f'<tr><td><strong>{t["id"]}</strong></td><td>{html.escape(t["nome"])}</td><td><code>{html.escape(t["rota"])}</code></td>'
            f'<td>{html.escape(t["perfis"])}</td><td>{feats}</td><td><span class="chip {"ex" if existe else ""}">{"No app" if existe else "Só desenho"}</span></td></tr>'
        )
    telas = f"""
<section id="telas">
  <h2>Telas do app</h2>
  <p>Desenhos no <a href="{LINKS["telas"]}">canvas de telas</a> e regras no <a href="{LINKS["design"]}">design system</a>. "No app" quer dizer que a tela já existe no código.</p>
  <div class="tabela"><table><thead><tr><th>Tela</th><th>Nome</th><th>Rota</th><th>Perfis</th><th>Features</th><th>Situação</th></tr></thead><tbody>{"".join(linhas_tela)}</tbody></table></div>
</section>"""

    # --- features
    blocos = []
    for fase in fases:
        for n in fase["features"]:
            f = features[n]
            cas = "".join(
                f'<tr><td>{c[0]}</td><td>{inline(c[1], nomes)}</td><td><span class="chip c-{c[2]}">{ROTULO_CA[c[2]]}</span>'
                f'{"<div class=nota>" + inline(c[3], nomes) + "</div>" if c[3] else ""}</td></tr>'
                for c in f["criterios"]
            )
            api = "".join(
                f'<tr><td><code>{html.escape(r[0])}</code></td><td><code>{html.escape(r[1])}</code></td><td>{html.escape(r[2])}</td><td>{inline(r[3], nomes)}</td></tr>'
                for r in f["api"] if len(r) >= 4
            )
            tar = "".join(f'<li class="{"ok" if ok else "ab"}"><span class="tick" aria-hidden="true">{"✓" if ok else "○"}</span>{inline(t, nomes)}</li>' for ok, t in f["tarefas"])
            deps = ", ".join(f'<a href="#f{d}">{d} {html.escape(features[d]["nome"])}</a>' for d in f["deps"] if d in features) or "Nenhuma"
            tela_li = "".join(f"<li>{inline(t, nomes)}</li>" for t in f["telas"])
            diag = f'<pre class="mermaid">{html.escape(f["diagrama"], quote=False)}</pre>' if f["diagrama"] else '<p class="mut">Sem diagrama ainda.</p>'
            impacto = "".join(f"<li>{inline(i, nomes)}</li>" for i in f["impacto"])
            ok_c = sum(1 for c in f["criterios"] if c[2] == "feito")
            tot_c = sum(1 for c in f["criterios"] if c[2] != "descartado")
            ok_t = sum(1 for t in f["tarefas"] if t[0])
            blocos.append(f"""
<section class="feature" id="f{n}">
  <header>
    <div class="cab"><span class="num-f">{n}</span><h2>{html.escape(f["nome"])}</h2><span class="chip s-{f["situacao"]}">{sel(f["situacao"])}</span></div>
    <p class="mut">{html.escape(fase["id"])} · {html.escape(fase["nome"])}{" · " + html.escape(f["uc"]) if f["uc"] else ""} · critérios {ok_c}/{tot_c} · tarefas {ok_t}/{len(f["tarefas"])}</p>
  </header>
  <p>{inline(f["objetivo"], nomes)}</p>
  <h3>Diagrama</h3>
  {diag}
  <h3>Impacto no sistema</h3>
  <ul class="lista">{impacto}</ul>
  <h3>Critérios de aceitação</h3>
  <div class="tabela"><table><thead><tr><th>#</th><th>Critério</th><th>Situação</th></tr></thead><tbody>{cas}</tbody></table></div>
  {"<h3>API</h3><div class=tabela><table><thead><tr><th>Método</th><th>Caminho</th><th>Perfis</th><th>O que faz</th></tr></thead><tbody>" + api + "</tbody></table></div>" if api else ""}
  <div class="duas">
    <div><h3>Telas</h3><ul class="lista">{tela_li or "<li>Sem tela própria.</li>"}</ul></div>
    <div><h3>Depende de</h3><p>{deps}</p></div>
  </div>
  {"<h3>Tarefas</h3><ul class=lista>" + tar + "</ul>" if tar else ""}
</section>""")

    return CASCA.format(
        data=date.today().strftime("%d/%m/%Y"),
        indice="\n".join(indice),
        andamento=andamento,
        telas=telas,
        features="\n".join(blocos),
        link_telas=LINKS["telas"],
        link_design=LINKS["design"],
    )


CASCA = """<title>Diagramas e andamento</title>
<meta name="claude:viewport-fit-sides" content="cover">
<style>
  /* Layout: índice lateral fixo e leitura em uma coluna. Cores do design system OficinaFácil. */
  :root {{
    --bg:#f5f5f7; --surface:#ffffff; --fg:#1d1d1f; --muted:#333333; --line:#e0e0e0;
    --acao:#0066cc; --on-acao:#ffffff; --tile:#272729; --on-tile:#ffffff; --on-tile-mut:#cccccc; --link-tile:#2997ff;
    --ok-bg:#e8f1fb; --perigo:#b3261e;
    --font:system-ui,-apple-system,BlinkMacSystemFont,"Inter","Segoe UI",sans-serif;
    --mono:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;
  }}
  @media (prefers-color-scheme: dark) {{
    :root:not([data-theme="light"]) {{
      --bg:#000000; --surface:#1d1d1f; --fg:#f5f5f7; --muted:#cccccc; --line:#38383a;
      --acao:#2997ff; --on-acao:#000000; --tile:#272729; --ok-bg:#12263a; --perigo:#ff6961; color-scheme:dark;
    }}
  }}
  :root[data-theme="dark"] {{
    --bg:#000000; --surface:#1d1d1f; --fg:#f5f5f7; --muted:#cccccc; --line:#38383a;
    --acao:#2997ff; --on-acao:#000000; --tile:#272729; --ok-bg:#12263a; --perigo:#ff6961; color-scheme:dark;
  }}
  *{{box-sizing:border-box}}
  html{{scroll-behavior:smooth;scroll-padding-top:16px}}
  body{{margin:0;background:var(--bg);color:var(--fg);font:400 17px/1.47 var(--font);letter-spacing:-.374px;
    padding-left:max(0px,env(safe-area-inset-left,0px));padding-right:max(0px,env(safe-area-inset-right,0px))}}
  a{{color:var(--acao)}}
  code{{font-family:var(--mono);font-size:.86em;background:var(--bg);border:1px solid var(--line);border-radius:5px;padding:0 5px}}
  .mut{{color:var(--muted);font-size:14px;letter-spacing:-.224px}}
  .num{{font-variant-numeric:tabular-nums}}
  .sr{{position:absolute;left:-9999px}}
  h1,h2,h3{{margin:0;font-family:var(--font)}}
  h2{{font-size:28px;line-height:1.14;font-weight:600;letter-spacing:.196px}}
  h3{{font-size:17px;font-weight:600;margin:28px 0 10px}}
  .topo{{background:var(--tile);color:var(--on-tile);padding:40px max(20px,env(safe-area-inset-left,0px)) 36px}}
  .topo-in{{max-width:1180px;margin:0 auto}}
  .topo h1{{font-size:clamp(32px,6vw,48px);line-height:1.08;font-weight:600;letter-spacing:-.28px}}
  .topo p{{margin:10px 0 0;color:var(--on-tile-mut);max-width:62ch}}
  .topo a{{color:var(--link-tile)}}
  .quadro{{max-width:1180px;margin:0 auto;display:grid;grid-template-columns:268px minmax(0,1fr);gap:0 40px;padding:0 20px}}
  nav.indice{{position:sticky;top:0;align-self:start;max-height:100vh;overflow:auto;padding:24px 0 40px;font-size:14px;letter-spacing:-.224px}}
  nav.indice a{{display:flex;align-items:center;gap:8px;text-decoration:none;color:var(--fg);padding:6px 10px;border-radius:8px;line-height:1.3}}
  nav.indice a:hover{{background:var(--surface)}}
  nav.indice .nav-top{{font-weight:600}}
  .nav-fase{{margin:18px 10px 4px;font-size:12px;font-weight:600;color:var(--muted);letter-spacing:-.12px}}
  .pt{{width:9px;height:9px;border-radius:50%;border:2px solid var(--muted);flex:none}}
  .s-feito .pt{{background:var(--acao);border-color:var(--acao)}}
  .s-andamento .pt{{border-color:var(--acao);background:linear-gradient(90deg,var(--acao) 50%,transparent 50%)}}
  main{{padding:28px 0 80px;min-width:0}}
  section{{margin-bottom:56px}}
  .cartoes{{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px;margin:20px 0 24px}}
  .cartao{{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:16px 20px;display:flex;flex-direction:column}}
  .cartao .k{{font-size:14px;color:var(--muted)}}
  .cartao .v{{font-size:40px;line-height:1.1;font-weight:600;letter-spacing:0}}
  .cartao small{{font-size:20px;font-weight:400;color:var(--muted)}}
  .tabela{{overflow-x:auto;background:var(--surface);border:1px solid var(--line);border-radius:18px}}
  table{{width:100%;border-collapse:collapse;font-size:14px;letter-spacing:-.224px}}
  th,td{{text-align:left;padding:10px 14px;border-bottom:1px solid var(--line);vertical-align:top}}
  th{{font-weight:600;color:var(--muted);white-space:nowrap}}
  tr:last-child td{{border-bottom:0}}
  .barra{{height:8px;border-radius:4px;background:var(--line);min-width:120px}}
  .barra span{{display:block;height:8px;border-radius:4px;background:var(--acao)}}
  .duas{{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:0 32px}}
  .lista{{margin:0;padding:0;list-style:none;display:flex;flex-direction:column;gap:8px;font-size:15px;line-height:1.4;letter-spacing:-.24px}}
  .lista li{{min-width:0}}
  li.ok .tick{{color:var(--acao)}}
  .tick{{display:inline-block;width:20px;font-weight:600}}
  .chip{{display:inline-block;border:1px solid var(--line);border-radius:9999px;padding:2px 10px;font-size:12px;font-weight:600;letter-spacing:-.12px;background:var(--surface);white-space:nowrap}}
  .chip.ex,.chip.s-feito,.chip.c-feito{{background:var(--acao);color:var(--on-acao);border-color:var(--acao)}}
  .chip.s-andamento,.chip.c-andamento{{border-color:var(--acao);color:var(--acao)}}
  .chip.c-descartado{{color:var(--muted)}}
  .nota{{color:var(--muted);font-size:13px;margin-top:4px;max-width:60ch}}
  .feature{{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:28px 28px 32px}}
  .cab{{display:flex;align-items:center;gap:12px;flex-wrap:wrap}}
  .num-f{{font-family:var(--mono);font-size:14px;color:var(--muted);border:1px solid var(--line);border-radius:8px;padding:2px 8px}}
  .feature header p{{margin:6px 0 0}}
  .feature .tabela{{border-radius:12px}}
  pre.mermaid{{background:var(--bg);border:1px solid var(--line);border-radius:12px;padding:16px;overflow-x:auto;margin:0;text-align:center}}
  :focus-visible{{outline:2px solid var(--acao);outline-offset:2px}}
  @media (max-width:900px){{
    .quadro{{grid-template-columns:minmax(0,1fr);padding:0 16px}}
    nav.indice{{position:static;max-height:none;padding:16px 0 0;columns:2}}
    .nav-fase{{break-after:avoid}}
    .duas{{grid-template-columns:minmax(0,1fr)}}
    .feature{{padding:20px 16px 24px}}
    body{{padding-left:max(0px,env(safe-area-inset-left,0px))}}
  }}
  @media (prefers-reduced-motion:reduce){{html{{scroll-behavior:auto}}}}
</style>

<header class="topo">
  <div class="topo-in">
    <h1>Diagramas e andamento</h1>
    <p>Todas as funcionalidades do OficinaFácil, com o diagrama de cada uma, o que ela muda no sistema e o que já foi feito. Gerado do vault em {data}.</p>
    <p><a href="{link_telas}">Telas desenhadas</a> · <a href="{link_design}">Design system</a></p>
  </div>
</header>
<div class="quadro">
  <nav class="indice" aria-label="Índice">
{indice}
  </nav>
  <main>
{andamento}
{telas}
{features}
  </main>
</div>
"""


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    Path(sys.argv[1]).write_text(gerar(), encoding="utf-8")
    print("Gerado:", sys.argv[1])
