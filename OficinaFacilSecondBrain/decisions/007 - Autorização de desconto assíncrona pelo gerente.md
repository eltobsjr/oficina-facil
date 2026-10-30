---
data: 2026-10-30
status: proposta
---

# 007 — Autorização de desconto assíncrona pelo gerente

## Contexto

UC10: desconto acima de 10% exige um gerente. A primeira proposta era um diálogo no aparelho do atendente, onde o gerente digitava as próprias credenciais. A revisão apontou riscos: a rota viraria um oráculo de força bruta da senha do gerente (o limite do Supabase Auth é por IP, e todas as tentativas saem do IP do backend), cria sessão do gerente que precisa ser encerrada, e a senha poderia vazar em log ou erro de validação.

## Alternativas consideradas

- Diálogo no aparelho do atendente com credenciais do gerente (descartada)
- **Pedido assíncrono: o atendente solicita, o gerente decide pela própria sessão** (adotada)

## Decisão

O atendente cria uma solicitação (`PENDENTE`); o gerente recebe um aviso e decide em `POST /solicitacoes-desconto/:id/decisao` com o **próprio JWT** (perfil Gerente na tabela `perfis`), podendo aprovar um valor menor. A autorização guarda o subtotal de referência e perde a validade se o subtotal ou o desconto mudar. Nenhuma senha de gerente passa pela sessão do atendente.

## Consequências

- Nova tabela `autorizacoes_desconto` com status, valores solicitado e autorizado e `subtotal_centavos_ref`.
- Novos endpoints (ver [[Endpoints]]) e a tela T18 vira "Solicitações de desconto" (`/descontos`).
- O atendente aguarda a decisão; com o gerente presente no balcão ele decide em segundos pelo próprio app.
- Se o professor exigir o diálogo síncrono, o UC10 e a T18 mudam.
