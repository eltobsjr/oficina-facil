/**
 * Instância única do PrismaClient (Prisma 7 com driver adapter pg).
 *
 * Reexporta tipos e enums do client gerado, para que o resto do código importe daqui e não de
 * `generated/`. `pingBanco()` alimenta o `/health`.
 */

import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../generated/prisma/client.js';
import { env } from '../../config/env.js';

export * from '../../generated/prisma/client.js';

let cliente: PrismaClient | undefined;

export function prisma(): PrismaClient {
  if (!cliente) {
    const adapter = new PrismaPg({ connectionString: env().DATABASE_URL });
    cliente = new PrismaClient({ adapter });
  }
  return cliente;
}

export async function desconectarPrisma(): Promise<void> {
  await cliente?.$disconnect();
  cliente = undefined;
}

export async function pingBanco(): Promise<boolean> {
  try {
    await prisma().$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}
