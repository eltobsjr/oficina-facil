---
data: 2026-10-30
---

# Gerar notas e PDFs

Parte do vault é **gerada por script** a partir de uma única fonte de dados, para nada ficar divergente. Regra R2 do `CLAUDE.md`: notas geradas não se editam à mão.

## O que é gerado

| Saída | Origem |
|---|---|
| `features/*.md`, `CHECKLIST.md`, `telas/Mapa de telas.md`, `00 - Índice.md` | dados dentro de `gerar-vault.py` |
| `api/Endpoints.md`, `requisitos/Rastreabilidade.md` | os mesmos dados |
| `entregas/*.pdf` | notas do vault, por `gerar-pdf.mjs` |

**Atenção:** rodar `gerar-vault.py` **recria** as features e o CHECKLIST do zero, apagando o status dos CAs e as tarefas já marcadas. Depois que o desenvolvimento começar, edite o status direto nos arquivos e **não** rode o gerador sem antes salvar o progresso, ou migre os dados para um formato que o preserve.

## Regerar o vault

```bash
python3 OficinaFacilSecondBrain/metodos/gerar-vault.py --dry-run   # lista o que seria recriado
python3 OficinaFacilSecondBrain/metodos/gerar-vault.py             # recusa se houver progresso; --force sobrescreve
```

Termina imprimindo `links quebrados: []` quando todos os `[[links]]` resolvem.

## Gerar os PDFs

Pré-requisitos: Node, Google Chrome e `pdftoppm` (para conferir). Numa pasta temporária:

```bash
mkdir /tmp/pdf && cd /tmp/pdf && npm init -y && npm i marked@12 mermaid@10
cp node_modules/mermaid/dist/mermaid.min.js .
node OficinaFacilSecondBrain/metodos/gerar-pdf.mjs <nota.md> <saida.html> "<título>"
google-chrome --headless=new --no-sandbox --disable-gpu --virtual-time-budget=30000 \
  --no-pdf-header-footer --print-to-pdf=<saida.pdf> file:///tmp/pdf/<saida.html>
```

Conferir sempre as páginas com diagramas (`pdftoppm -r 50 -png`): diagramas largos ficam ilegíveis.
