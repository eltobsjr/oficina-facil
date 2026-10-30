---
data: 2026-10-30
status: aceita
---

# 006 — Backend em Node e TypeScript

## Contexto

O usuário pediu um backend próprio, sem Edge Function, com Supabase. Os projetos Polímata (Supabase com RPC e Edge Functions, sem backend) e Confia (backend próprio + Supabase) foram comparados. O time não domina Java, então Spring Boot saiu.

## Alternativas consideradas

- Spring Boot (curva alta para quem não domina Java)
- Go (linguagem nova)
- Dart no servidor (ecossistema menor)
- Polímata: só Supabase com Edge Functions (não atende ao pedido)

## Decisão

Stack do Confia, enxuta: Node 22, Express 5, TypeScript, Zod, Prisma, Pino, Helmet, rate limit, Vitest, OpenAPI gerado do Zod. Fora: BullMQ/Valkey, gateway de pagamento, mapas e painel admin em React.

## Consequências

- Dois projetos (app e backend) e TypeScript novo para o time.
- Ganhos: regras testáveis, contrato OpenAPI, validação em toda rota e código reaproveitável do Confia (JWKS, erros, logger, OpenAPI, teste de arquitetura).
