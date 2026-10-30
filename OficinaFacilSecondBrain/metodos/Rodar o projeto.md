---
data: 2026-10-30
---

# Rodar o projeto

Passo a passo para subir backend e app, e problemas conhecidos. Arquitetura em [[Arquitetura]]; regras em `CLAUDE.md`.

## Pré-requisitos

Node 22 ou superior, Flutter 3.44, Chrome, Docker (opcional) e `psql` (para conferir o banco).

## Backend

```bash
cd backend
cp .env.example .env        # preencha; o .env é ignorado pelo git
npm install
npx prisma migrate deploy   # aplica as migrations no projeto Supabase do .env
npm run db:seed             # catálogo fictício; o gerente exige a chave de serviço
npm run dev                 # API em http://localhost:3000, Swagger em /docs
```

Variáveis do `.env` (nomes em `backend/.env.example`):

| Variável | Para quê |
|---|---|
| `SUPABASE_URL` | URL do projeto |
| `DATABASE_URL` | conexão da API; em produção e no CI use a do **pooler** (IPv4) |
| `DIRECT_URL` | conexão direta, usada pelo Prisma nas migrations |
| `SUPABASE_SERVICE_ROLE_KEY` | só no backend; criar usuário (UC06) e o seed do gerente |
| `TEST_*` | projeto Supabase de **teste**, só para os testes de integração |
| `SEED_GERENTE_EMAIL`, `SEED_GERENTE_SENHA` | gerente inicial (dados fictícios em desenvolvimento) |

Nunca colar valores no chat nem em arquivo versionado (regra R20).

### Verificação

```bash
npm run lint && npm run format:check && npm run typecheck && npm test   # a cada mudança
bash scripts/smoke.sh                                                    # antes de fechar uma feature
```

`npm test` roda os testes unitários e HTTP (sem banco). Os de integração (`test/integracao`) só rodam com `TEST_DIRECT_URL` (e, para RLS, `TEST_SUPABASE_URL` e `TEST_SUPABASE_PUBLISHABLE_KEY`); sem elas são ignorados.

### Docker

```bash
docker build -t oficina-facil-backend backend
docker run --rm -p 3000:3000 --env-file backend/.env -e NODE_ENV=production oficina-facil-backend
```

A imagem roda como usuário `node` e tem *healthcheck* em `/health`.

## App

```bash
cd mobile
cp env.example.json env.json   # preencha SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY e API_URL
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
flutter run -d android --dart-define-from-file=env.json
```

`API_URL` precisa terminar em `/api/v1`. No emulador Android o `localhost` do computador é `http://10.0.2.2:3000/api/v1`; num celular físico use o IP do computador na rede.

Sem `--dart-define-from-file=env.json` o app recusa iniciar e explica o que falta.

## Problemas conhecidos

- **Container sem banco (`indisponivel` em `/health`):** a conexão direta do Supabase é só IPv6. Use a string do pooler em `DATABASE_URL`.
- **`flutter build apk` falha com `trustAnchors parameter must be non-empty`:** o Java desta máquina está com o repositório de certificados vazio e o Gradle não consegue baixar bibliotecas novas. Contorno, sem mudar nada permanente:
  ```bash
  cd mobile/android && ./gradlew --stop
  cd .. && JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=/etc/pki/ca-trust/extracted/java/cacerts -Djavax.net.ssl.trustStorePassword=changeit" \
    flutter build apk --debug --dart-define-from-file=env.json
  ```
- **`pkill -f` no mesmo comando que o contém** mata o próprio shell; encerre processos pela porta (`ss -ltnp`).
