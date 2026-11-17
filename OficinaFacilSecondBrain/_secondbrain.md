---
schema: 2
versionado: true
sensibilidade: normal   # normal | alta (alta = startup/institucional: nunca vai para o git)
backup: true            # false = fora do backup para HD externo
hooks: true
diataxis: false
modulos: [devtrack, decisoes, features, commits, prioridade, estado]
papeis:
  devtrack: devtrack/
  decisoes: decisions/
  features: features/
  commits: commits/
  prioridade: prioridade/atual.md
  estado: ESTADO.md
  indice: INDEX.md
extras:
  - { path: agil/, descricao: "Metodologia ágil (Scrum e Kanban) do projeto" }
  - { path: api/, descricao: "contrato dos endpoints (gerado)" }
  - { path: arquitetura/, descricao: "arquitetura, modelo de dados, diagramas" }
  - { path: artefatos/, descricao: "Artefatos de entrega: design, slides e índice" }
  - { path: auditorias/, descricao: "auditorias e revisões" }
  - { path: diagramas/, descricao: "Diagramas" }
  - { path: entregas/, descricao: "PDFs gerados" }
  - { path: identidade-visual/, descricao: "kit do logo" }
  - { path: metodos/, descricao: "como gerar as notas e os PDFs" }
  - { path: requisitos/, descricao: "requisitos, casos de uso, histórias, rastreabilidade" }
  - { path: telas/, descricao: "mapa de telas e rotas" }
nomes:
  devtrack: "AAAA-MM-DD - Título"
  decisoes: "NNN - Título"
  features: "NNN - Título"
campos-extra:
  features: [fase, rf, uc, us]
criado: 2026-11-16
migrado-de: legado
---

# OficinaFacil — Manifesto do vault

Mapa humano do vault. Edite livremente; as skills leem o frontmatter acima.
