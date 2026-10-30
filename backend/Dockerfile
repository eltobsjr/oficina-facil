# Imagem do backend do OficinaFácil (API Express).
#
# Multi-stage: a imagem final não carrega devDependencies nem código TypeScript e roda o build
# compilado (`node dist/server.js`), o mesmo artefato em desenvolvimento e produção.
# O banco é o Postgres do Supabase (nunca um container): Auth e Realtime não existem num Postgres puro.

# ---- estágio de build ----
FROM node:22-alpine AS build
WORKDIR /app

# npm ci com lockfile (regra de segurança do projeto).
COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json tsconfig.build.json prisma.config.ts ./
COPY prisma ./prisma
COPY src ./src

# `prisma generate` roda com o placeholder do prisma.config.ts: não precisa de banco no build.
RUN npm run build

# Reinstala só as dependências de produção para copiar node_modules já enxuto.
RUN npm ci --omit=dev

# ---- imagem final ----
FROM node:22-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# dumb-init como PID 1: encaminha SIGTERM para o Node, que fecha o Prisma antes de sair.
RUN apk add --no-cache dumb-init

COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/prisma ./prisma
COPY --chown=node:node package.json ./

# Nunca root.
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/server.js"]
