/**
 * Seed de desenvolvimento (dados 100% fictícios, regra R28). Idempotente.
 *
 *   npm run db:seed
 *
 * - Catálogo fictício de serviços e peças (só fora de produção).
 * - Gerente inicial, se SEED_GERENTE_EMAIL, SEED_GERENTE_SENHA e SUPABASE_SERVICE_ROLE_KEY estiverem
 *   definidas: cria o usuário no Supabase Auth (chave de serviço, só no backend) e o perfil GERENTE.
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { createClient } from '@supabase/supabase-js';
import { PrismaClient } from '../src/generated/prisma/client.js';

const SERVICOS = [
  {
    codigo: 'SRV-001',
    descricao: 'Troca de óleo e filtro',
    valorCentavos: 12000,
    tempoEstimadoMin: 40,
  },
  {
    codigo: 'SRV-002',
    descricao: 'Alinhamento e balanceamento',
    valorCentavos: 18000,
    tempoEstimadoMin: 60,
  },
  { codigo: 'SRV-003', descricao: 'Revisão de freios', valorCentavos: 25000, tempoEstimadoMin: 90 },
  {
    codigo: 'SRV-004',
    descricao: 'Diagnóstico com scanner',
    valorCentavos: 15000,
    tempoEstimadoMin: 30,
  },
];

const PECAS = [
  { codigo: 'PC-001', descricao: 'Filtro de óleo', precoCentavos: 3500, estoqueMinimo: 5 },
  { codigo: 'PC-002', descricao: 'Óleo 5W30 (litro)', precoCentavos: 4200, estoqueMinimo: 10 },
  {
    codigo: 'PC-003',
    descricao: 'Pastilha de freio (jogo)',
    precoCentavos: 18000,
    estoqueMinimo: 3,
  },
  { codigo: 'PC-004', descricao: 'Vela de ignição', precoCentavos: 2800, estoqueMinimo: 8 },
];

async function semearGerente(prisma: PrismaClient) {
  const email = process.env['SEED_GERENTE_EMAIL'];
  const senha = process.env['SEED_GERENTE_SENHA'];
  const chave = process.env['SUPABASE_SERVICE_ROLE_KEY'];
  const url = process.env['SUPABASE_URL'];
  if (!email || !senha || !chave || !url) {
    console.log(
      'Gerente inicial: ignorado (faltam SEED_GERENTE_EMAIL, SEED_GERENTE_SENHA ou SUPABASE_SERVICE_ROLE_KEY).',
    );
    return;
  }
  const supabase = createClient(url, chave, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  let usuarioId: string | undefined;
  const criado = await supabase.auth.admin.createUser({
    email,
    password: senha,
    email_confirm: true,
  });
  if (criado.data.user) {
    usuarioId = criado.data.user.id;
  } else {
    // Já existe: localiza pelo e-mail.
    const lista = await supabase.auth.admin.listUsers({ page: 1, perPage: 1000 });
    usuarioId = lista.data.users.find((u) => u.email === email)?.id;
  }
  if (!usuarioId)
    throw new Error(
      `Não foi possível criar nem localizar o usuário no Supabase Auth: ${criado.error?.message ?? 'erro desconhecido'}`,
    );
  await prisma.perfilUsuario.upsert({
    where: { usuarioId },
    create: { usuarioId, nome: 'Gerente', email, perfil: 'GERENTE' },
    update: { perfil: 'GERENTE', ativo: true },
  });
  console.log('Gerente inicial: ok.');
}

async function main() {
  const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: process.env['DATABASE_URL']! }),
  });
  try {
    if (process.env['NODE_ENV'] !== 'production') {
      for (const s of SERVICOS)
        await prisma.servico.upsert({ where: { codigo: s.codigo }, create: s, update: {} });
      for (const p of PECAS)
        await prisma.peca.upsert({ where: { codigo: p.codigo }, create: p, update: {} });
      console.log(`Catálogo fictício: ${SERVICOS.length} serviços e ${PECAS.length} peças.`);
    }
    await semearGerente(prisma);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((erro) => {
  console.error(erro instanceof Error ? erro.message : erro);
  process.exit(1);
});
