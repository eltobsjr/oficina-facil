/**
 * Carrega e valida as variáveis de ambiente com Zod.
 *
 * Toda configuração do backend passa por aqui. `env()` é lazy: nunca chame no topo de um módulo,
 * só em tempo de execução, para que testes importem código sem precisar de .env. Em NODE_ENV=test
 * o arquivo .env NÃO é lido, para os testes nunca tocarem em credenciais reais.
 */

import dotenv from 'dotenv';
import { z } from 'zod';

if ((process.env['NODE_ENV'] ?? 'development') !== 'test') dotenv.config({ quiet: true });

/** Variável opcional que vem vazia no .env.example: vazio vira "não definida". */
const opcional = z
  .string()
  .min(1)
  .optional()
  .or(z.literal('').transform(() => undefined));

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),

  /** Conexão usada pela API em execução (pooler, quando houver). */
  DATABASE_URL: z.string().min(1),
  /** Conexão direta, usada pelo Prisma nas migrations. */
  DIRECT_URL: opcional,

  SUPABASE_URL: z.url(),
  /** Só o backend tem esta chave (criar usuário, UC06). Nunca vai para o app. */
  SUPABASE_SERVICE_ROLE_KEY: opcional,

  /** Origens do web aceitas pelo CORS em produção, separadas por vírgula. */
  CORS_ORIGINS: z.string().default(''),

  // Rate limit por IP, janela de 1 minuto.
  RATE_LIMIT_GERAL_POR_MINUTO: z.coerce.number().int().positive().default(300),
  RATE_LIMIT_ESCRITA_POR_MINUTO: z.coerce.number().int().positive().default(100),

  // Timeouts do servidor HTTP em ms (mitigação de Slowloris).
  HTTP_HEADERS_TIMEOUT_MS: z.coerce.number().int().positive().default(20_000),
  HTTP_REQUEST_TIMEOUT_MS: z.coerce.number().int().nonnegative().default(30_000),
  HTTP_KEEP_ALIVE_TIMEOUT_MS: z.coerce.number().int().positive().default(15_000),
});

export type Env = z.infer<typeof EnvSchema>;

export function carregarEnv(fonte: NodeJS.ProcessEnv = process.env): Env {
  const resultado = EnvSchema.safeParse(fonte);
  if (!resultado.success) {
    const linhas = resultado.error.issues.map((i) => `- ${i.path.join('.')}: ${i.message}`);
    throw new Error(`Variáveis de ambiente inválidas:\n${linhas.join('\n')}`);
  }
  return resultado.data;
}

let cache: Env | undefined;

/** Lazy: nunca chamar no topo de um módulo. */
export function env(): Env {
  cache ??= carregarEnv();
  return cache;
}

/** Origens liberadas no CORS em produção. */
export function origensCors(e: Env = env()): string[] {
  return e.CORS_ORIGINS.split(',')
    .map((o) => o.trim())
    .filter((o) => o.length > 0);
}
