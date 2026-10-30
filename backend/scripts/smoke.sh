#!/usr/bin/env bash
# Fluxo ponta a ponta mínimo contra uma API em execução (padrão: http://localhost:3000).
# Verifica saúde, documentação, autenticação e a sondagem de RLS com a chave publicável.
# Uso: API_URL=http://localhost:3000 bash scripts/smoke.sh
# Para a sondagem de RLS defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY (não são impressas).
set -u
API="${API_URL:-http://localhost:3000}"
falhas=0; total=0

verifica() { # descrição, esperado, obtido
  total=$((total + 1))
  if [ "$2" = "$3" ]; then printf '  ok   %s\n' "$1"; else printf '  FALHA %s (esperado %s, obtido %s)\n' "$1" "$2" "$3"; falhas=$((falhas + 1)); fi
}
status() { curl -s -o /dev/null -w '%{http_code}' --max-time 15 "$@"; }

echo "Smoke test em $API"
verifica "GET /health responde 200" 200 "$(status "$API/health")"
verifica "GET /docs responde 200" 200 "$(status -L "$API/docs/")"
verifica "GET /openapi.json documenta /me" 1 "$(curl -s --max-time 15 "$API/openapi.json" | grep -c '"/me"' | sed 's/^[1-9][0-9]*$/1/')"
verifica "GET /api/v1/me sem token -> 401" 401 "$(status "$API/api/v1/me")"
verifica "GET /api/v1/me com token inválido -> 401" 401 "$(status -H 'Authorization: Bearer invalido' "$API/api/v1/me")"
verifica "rota inexistente -> 404" 404 "$(status "$API/api/v1/nao-existe")"
verifica "erro em JSON com código" 1 "$(curl -s --max-time 15 "$API/api/v1/nao-existe" | grep -c '"codigo":"nao_encontrado"')"

if [ -n "${SUPABASE_URL:-}" ] && [ -n "${SUPABASE_PUBLISHABLE_KEY:-}" ]; then
  for t in clientes ordens_servico pecas pagamentos; do
    codigo="$(status "$SUPABASE_URL/rest/v1/$t?select=*" -H "apikey: $SUPABASE_PUBLISHABLE_KEY" -H "Authorization: Bearer $SUPABASE_PUBLISHABLE_KEY")"
    verifica "app sem login não lê $t (401)" 401 "$codigo"
  done
  codigo="$(status -X POST "$SUPABASE_URL/rest/v1/clientes" -H "apikey: $SUPABASE_PUBLISHABLE_KEY" -H "Authorization: Bearer $SUPABASE_PUBLISHABLE_KEY" -H 'Content-Type: application/json' -d '{"nome":"x","documento":"1","telefone":"1"}')"
  verifica "app sem login não escreve em clientes (401)" 401 "$codigo"
else
  echo "  (sondagem de RLS ignorada: defina SUPABASE_URL e SUPABASE_PUBLISHABLE_KEY)"
fi

echo "Resultado: $((total - falhas))/$total ok, $falhas falha(s)"
[ "$falhas" -eq 0 ]
