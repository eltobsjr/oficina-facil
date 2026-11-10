/**
 * Troca o gerente principal do projeto Supabase de desenvolvimento.
 *
 *   npm run db:trocar-gerente
 *
 * Lê NOVO_GERENTE_EMAIL e NOVO_GERENTE_SENHA (e, se quiser, NOVO_GERENTE_NOME) do `.env`, que é
 * ignorado pelo git: nenhum e-mail ou senha real fica no código (R20, R28 e R30).
 * Cria o novo gerente no Supabase Auth e em `perfis`, e depois apaga todos os outros usuários.
 * Recusa rodar se já houver cliente, veículo ou ordem de serviço, para nunca apagar dado real (R19).
 */

import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { createClient } from '@supabase/supabase-js';
import { PrismaClient } from '../src/generated/prisma/client.js';

function exigir(nome: string): string {
  const valor = process.env[nome];
  if (!valor) throw new Error(`Falta a variável ${nome} no .env.`);
  return valor;
}

async function main() {
  const email = exigir('NOVO_GERENTE_EMAIL');
  const senha = exigir('NOVO_GERENTE_SENHA');
  const nome = process.env['NOVO_GERENTE_NOME'] ?? 'Gerente';
  const supabase = createClient(exigir('SUPABASE_URL'), exigir('SUPABASE_SERVICE_ROLE_KEY'), {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const prisma = new PrismaClient({
    adapter: new PrismaPg({ connectionString: exigir('DATABASE_URL') }),
  });
  try {
    const [clientes, veiculos, ordens] = await Promise.all([
      prisma.cliente.count(),
      prisma.veiculo.count(),
      prisma.ordemServico.count(),
    ]);
    if (clientes + veiculos + ordens > 0)
      throw new Error('O banco já tem cliente, veículo ou ordem de serviço: nada foi alterado.');

    let usuarioId: string | undefined;
    const criado = await supabase.auth.admin.createUser({
      email,
      password: senha,
      email_confirm: true,
    });
    if (criado.data.user) {
      usuarioId = criado.data.user.id;
    } else {
      const lista = await supabase.auth.admin.listUsers({ page: 1, perPage: 1000 });
      const existente = lista.data.users.find((u) => u.email === email);
      if (!existente) throw new Error(`Não foi possível criar o gerente: ${criado.error?.message}`);
      usuarioId = existente.id;
      await supabase.auth.admin.updateUserById(usuarioId, { password: senha });
    }
    await prisma.perfilUsuario.upsert({
      where: { usuarioId },
      create: { usuarioId, nome, email, perfil: 'GERENTE' },
      update: { nome, perfil: 'GERENTE', ativo: true },
    });

    const antigos = await prisma.perfilUsuario.findMany({
      where: { usuarioId: { not: usuarioId } },
      select: { usuarioId: true },
    });
    for (const { usuarioId: antigo } of antigos) {
      await prisma.perfilUsuario.delete({ where: { usuarioId: antigo } });
      const apagado = await supabase.auth.admin.deleteUser(antigo);
      if (apagado.error)
        throw new Error(`Falha ao apagar o usuário antigo: ${apagado.error.message}`);
    }
    console.log(`Novo gerente criado. Usuários antigos apagados: ${antigos.length}.`);
  } finally {
    await prisma.$disconnect();
  }
}

main().catch((erro) => {
  console.error(erro instanceof Error ? erro.message : erro);
  process.exit(1);
});
