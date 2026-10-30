-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "perfil_enum" AS ENUM ('ATENDENTE', 'MECANICO', 'ALMOXARIFE', 'GERENTE');

-- CreateEnum
CREATE TYPE "status_enum" AS ENUM ('ABERTA', 'DIAGNOSTICADA', 'AGUARDANDO_APROVACAO', 'APROVADA', 'EM_EXECUCAO', 'CONCLUIDA', 'ENTREGUE', 'CANCELADA');

-- CreateEnum
CREATE TYPE "tipo_mov_enum" AS ENUM ('ENTRADA', 'BAIXA', 'ESTORNO');

-- CreateEnum
CREATE TYPE "tipo_item_enum" AS ENUM ('SERVICO', 'PECA');

-- CreateEnum
CREATE TYPE "resultado_enum" AS ENUM ('APROVADA', 'RECUSADA');

-- CreateEnum
CREATE TYPE "status_desconto_enum" AS ENUM ('PENDENTE', 'APROVADA', 'RECUSADA');

-- CreateEnum
CREATE TYPE "canal_enum" AS ENUM ('BALCAO', 'TELEFONE');

-- CreateEnum
CREATE TYPE "forma_enum" AS ENUM ('DINHEIRO', 'CARTAO', 'PIX');

-- CreateEnum
CREATE TYPE "aviso_enum" AS ENUM ('OS_CONCLUIDA', 'SALDO_INSUFICIENTE', 'DESCONTO_PENDENTE');

-- CreateTable
CREATE TABLE "perfis" (
    "usuario_id" UUID NOT NULL,
    "nome" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "perfil" "perfil_enum" NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "perfis_pkey" PRIMARY KEY ("usuario_id")
);

-- CreateTable
CREATE TABLE "avisos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "destinatario_id" UUID NOT NULL,
    "tipo" "aviso_enum" NOT NULL,
    "os_id" UUID,
    "peca_id" UUID,
    "lido_em" TIMESTAMPTZ,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "avisos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "clientes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "nome" TEXT NOT NULL,
    "documento" TEXT NOT NULL,
    "telefone" TEXT NOT NULL,
    "email" TEXT,
    "endereco" TEXT,
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "veiculos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "cliente_id" UUID NOT NULL,
    "placa" TEXT NOT NULL,
    "marca" TEXT NOT NULL,
    "modelo" TEXT NOT NULL,
    "ano" INTEGER NOT NULL,
    "cor" TEXT,
    "quilometragem" INTEGER NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "veiculos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "servicos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "codigo" TEXT NOT NULL,
    "descricao" TEXT NOT NULL,
    "valor_centavos" INTEGER NOT NULL,
    "tempo_estimado_min" INTEGER NOT NULL,
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "servicos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pecas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "codigo" TEXT NOT NULL,
    "descricao" TEXT NOT NULL,
    "preco_centavos" INTEGER NOT NULL,
    "saldo" INTEGER NOT NULL DEFAULT 0,
    "estoque_minimo" INTEGER NOT NULL DEFAULT 0,
    "ativo" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "pecas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "movimentacoes_estoque" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "peca_id" UUID NOT NULL,
    "tipo" "tipo_mov_enum" NOT NULL,
    "quantidade" INTEGER NOT NULL,
    "custo_unitario_centavos" INTEGER,
    "documento_origem" TEXT,
    "os_id" UUID,
    "usuario_id" UUID NOT NULL,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "movimentacoes_estoque_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ordens_servico" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "numero" SERIAL NOT NULL,
    "cliente_id" UUID NOT NULL,
    "veiculo_id" UUID NOT NULL,
    "queixa" TEXT NOT NULL,
    "quilometragem_entrada" INTEGER NOT NULL,
    "status" "status_enum" NOT NULL DEFAULT 'ABERTA',
    "aberta_por" UUID NOT NULL,
    "mecanico_id" UUID,
    "aberta_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "iniciada_em" TIMESTAMPTZ,
    "concluida_em" TIMESTAMPTZ,
    "entregue_em" TIMESTAMPTZ,
    "entregue_por" UUID,
    "motivo_cancelamento" TEXT,

    CONSTRAINT "ordens_servico_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "diagnosticos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "texto" TEXT NOT NULL,
    "finalizado" BOOLEAN NOT NULL DEFAULT false,
    "mecanico_id" UUID NOT NULL,
    "atualizado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "diagnosticos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "orcamentos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "subtotal_centavos" INTEGER NOT NULL,
    "desconto_centavos" INTEGER NOT NULL DEFAULT 0,
    "total_centavos" INTEGER NOT NULL,
    "confirmado_em" TIMESTAMPTZ,

    CONSTRAINT "orcamentos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "itens_orcamento" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "orcamento_id" UUID NOT NULL,
    "tipo" "tipo_item_enum" NOT NULL,
    "servico_id" UUID,
    "peca_id" UUID,
    "descricao" TEXT NOT NULL,
    "quantidade" INTEGER NOT NULL,
    "valor_unitario_centavos" INTEGER NOT NULL,

    CONSTRAINT "itens_orcamento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "autorizacoes_desconto" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "orcamento_id" UUID NOT NULL,
    "atendente_id" UUID NOT NULL,
    "gerente_id" UUID,
    "status" "status_desconto_enum" NOT NULL DEFAULT 'PENDENTE',
    "subtotal_centavos_ref" INTEGER NOT NULL,
    "desconto_solicitado_centavos" INTEGER NOT NULL,
    "desconto_autorizado_centavos" INTEGER,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidido_em" TIMESTAMPTZ,

    CONSTRAINT "autorizacoes_desconto_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "aprovacoes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "resultado" "resultado_enum" NOT NULL,
    "canal" "canal_enum" NOT NULL,
    "motivo" TEXT,
    "usuario_id" UUID NOT NULL,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "aprovacoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "observacoes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "texto" TEXT NOT NULL,
    "usuario_id" UUID NOT NULL,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "observacoes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pecas_usadas" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "peca_id" UUID NOT NULL,
    "quantidade" INTEGER NOT NULL,
    "valor_unitario_centavos" INTEGER NOT NULL,
    "mecanico_id" UUID NOT NULL,
    "estornada" BOOLEAN NOT NULL DEFAULT false,
    "devolvida" BOOLEAN,
    "motivo_nao_devolucao" TEXT,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pecas_usadas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pagamentos" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "forma" "forma_enum" NOT NULL,
    "valor_centavos" INTEGER NOT NULL,
    "usuario_id" UUID NOT NULL,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pagamentos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "historico_transicoes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "os_id" UUID NOT NULL,
    "de" "status_enum",
    "para" "status_enum" NOT NULL,
    "usuario_id" UUID NOT NULL,
    "motivo" TEXT,
    "criado_em" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "historico_transicoes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "perfis_email_key" ON "perfis"("email");

-- CreateIndex
CREATE INDEX "avisos_destinatario_id_criado_em_idx" ON "avisos"("destinatario_id", "criado_em");

-- CreateIndex
CREATE UNIQUE INDEX "clientes_documento_key" ON "clientes"("documento");

-- CreateIndex
CREATE UNIQUE INDEX "veiculos_placa_key" ON "veiculos"("placa");

-- CreateIndex
CREATE INDEX "veiculos_cliente_id_idx" ON "veiculos"("cliente_id");

-- CreateIndex
CREATE UNIQUE INDEX "servicos_codigo_key" ON "servicos"("codigo");

-- CreateIndex
CREATE UNIQUE INDEX "pecas_codigo_key" ON "pecas"("codigo");

-- CreateIndex
CREATE INDEX "movimentacoes_estoque_peca_id_criado_em_idx" ON "movimentacoes_estoque"("peca_id", "criado_em");

-- CreateIndex
CREATE UNIQUE INDEX "ordens_servico_numero_key" ON "ordens_servico"("numero");

-- CreateIndex
CREATE INDEX "ordens_servico_status_idx" ON "ordens_servico"("status");

-- CreateIndex
CREATE INDEX "ordens_servico_veiculo_id_idx" ON "ordens_servico"("veiculo_id");

-- CreateIndex
CREATE INDEX "ordens_servico_cliente_id_idx" ON "ordens_servico"("cliente_id");

-- CreateIndex
CREATE INDEX "ordens_servico_aberta_em_idx" ON "ordens_servico"("aberta_em");

-- CreateIndex
CREATE INDEX "ordens_servico_entregue_em_idx" ON "ordens_servico"("entregue_em");

-- CreateIndex
CREATE UNIQUE INDEX "diagnosticos_os_id_key" ON "diagnosticos"("os_id");

-- CreateIndex
CREATE UNIQUE INDEX "orcamentos_os_id_key" ON "orcamentos"("os_id");

-- CreateIndex
CREATE INDEX "itens_orcamento_orcamento_id_idx" ON "itens_orcamento"("orcamento_id");

-- CreateIndex
CREATE INDEX "autorizacoes_desconto_orcamento_id_idx" ON "autorizacoes_desconto"("orcamento_id");

-- CreateIndex
CREATE INDEX "autorizacoes_desconto_status_idx" ON "autorizacoes_desconto"("status");

-- CreateIndex
CREATE INDEX "aprovacoes_os_id_idx" ON "aprovacoes"("os_id");

-- CreateIndex
CREATE INDEX "observacoes_os_id_idx" ON "observacoes"("os_id");

-- CreateIndex
CREATE INDEX "pecas_usadas_os_id_idx" ON "pecas_usadas"("os_id");

-- CreateIndex
CREATE INDEX "pagamentos_os_id_idx" ON "pagamentos"("os_id");

-- CreateIndex
CREATE INDEX "historico_transicoes_os_id_idx" ON "historico_transicoes"("os_id");

-- AddForeignKey
ALTER TABLE "avisos" ADD CONSTRAINT "avisos_destinatario_id_fkey" FOREIGN KEY ("destinatario_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "veiculos" ADD CONSTRAINT "veiculos_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes_estoque" ADD CONSTRAINT "movimentacoes_estoque_peca_id_fkey" FOREIGN KEY ("peca_id") REFERENCES "pecas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes_estoque" ADD CONSTRAINT "movimentacoes_estoque_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "movimentacoes_estoque" ADD CONSTRAINT "movimentacoes_estoque_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_veiculo_id_fkey" FOREIGN KEY ("veiculo_id") REFERENCES "veiculos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_aberta_por_fkey" FOREIGN KEY ("aberta_por") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_mecanico_id_fkey" FOREIGN KEY ("mecanico_id") REFERENCES "perfis"("usuario_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ordens_servico" ADD CONSTRAINT "ordens_servico_entregue_por_fkey" FOREIGN KEY ("entregue_por") REFERENCES "perfis"("usuario_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "diagnosticos" ADD CONSTRAINT "diagnosticos_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "diagnosticos" ADD CONSTRAINT "diagnosticos_mecanico_id_fkey" FOREIGN KEY ("mecanico_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "orcamentos" ADD CONSTRAINT "orcamentos_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "itens_orcamento" ADD CONSTRAINT "itens_orcamento_orcamento_id_fkey" FOREIGN KEY ("orcamento_id") REFERENCES "orcamentos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "itens_orcamento" ADD CONSTRAINT "itens_orcamento_servico_id_fkey" FOREIGN KEY ("servico_id") REFERENCES "servicos"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "itens_orcamento" ADD CONSTRAINT "itens_orcamento_peca_id_fkey" FOREIGN KEY ("peca_id") REFERENCES "pecas"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "autorizacoes_desconto" ADD CONSTRAINT "autorizacoes_desconto_orcamento_id_fkey" FOREIGN KEY ("orcamento_id") REFERENCES "orcamentos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "autorizacoes_desconto" ADD CONSTRAINT "autorizacoes_desconto_atendente_id_fkey" FOREIGN KEY ("atendente_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "autorizacoes_desconto" ADD CONSTRAINT "autorizacoes_desconto_gerente_id_fkey" FOREIGN KEY ("gerente_id") REFERENCES "perfis"("usuario_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aprovacoes" ADD CONSTRAINT "aprovacoes_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aprovacoes" ADD CONSTRAINT "aprovacoes_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "observacoes" ADD CONSTRAINT "observacoes_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "observacoes" ADD CONSTRAINT "observacoes_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pecas_usadas" ADD CONSTRAINT "pecas_usadas_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pecas_usadas" ADD CONSTRAINT "pecas_usadas_peca_id_fkey" FOREIGN KEY ("peca_id") REFERENCES "pecas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pecas_usadas" ADD CONSTRAINT "pecas_usadas_mecanico_id_fkey" FOREIGN KEY ("mecanico_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pagamentos" ADD CONSTRAINT "pagamentos_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pagamentos" ADD CONSTRAINT "pagamentos_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "historico_transicoes" ADD CONSTRAINT "historico_transicoes_os_id_fkey" FOREIGN KEY ("os_id") REFERENCES "ordens_servico"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "historico_transicoes" ADD CONSTRAINT "historico_transicoes_usuario_id_fkey" FOREIGN KEY ("usuario_id") REFERENCES "perfis"("usuario_id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- ============================================================================
-- Parte escrita à mão: o que o Prisma não expressa (decisão 001, regra R19).
-- Modelo de dados e regras: vault, arquitetura/Modelo de dados.
-- ============================================================================

-- ---------------------------------------------------------------- FK para o Supabase Auth
ALTER TABLE "perfis"
  ADD CONSTRAINT "perfis_usuario_id_fkey_auth"
  FOREIGN KEY ("usuario_id") REFERENCES auth.users ("id") ON DELETE RESTRICT;

-- ---------------------------------------------------------------- regras de integridade (CHECK)
ALTER TABLE "pecas"
  ADD CONSTRAINT "pecas_saldo_nao_negativo" CHECK ("saldo" >= 0),
  ADD CONSTRAINT "pecas_preco_positivo" CHECK ("preco_centavos" > 0),
  ADD CONSTRAINT "pecas_estoque_minimo_nao_negativo" CHECK ("estoque_minimo" >= 0);

ALTER TABLE "servicos"
  ADD CONSTRAINT "servicos_valor_positivo" CHECK ("valor_centavos" > 0),
  ADD CONSTRAINT "servicos_tempo_positivo" CHECK ("tempo_estimado_min" > 0);

ALTER TABLE "veiculos"
  ADD CONSTRAINT "veiculos_ano_valido" CHECK ("ano" BETWEEN 1900 AND 2100),
  ADD CONSTRAINT "veiculos_quilometragem_nao_negativa" CHECK ("quilometragem" >= 0);

ALTER TABLE "ordens_servico"
  ADD CONSTRAINT "os_quilometragem_nao_negativa" CHECK ("quilometragem_entrada" >= 0);

ALTER TABLE "movimentacoes_estoque"
  ADD CONSTRAINT "movimentacoes_quantidade_positiva" CHECK ("quantidade" > 0),
  ADD CONSTRAINT "movimentacoes_custo_nao_negativo" CHECK ("custo_unitario_centavos" IS NULL OR "custo_unitario_centavos" >= 0);

ALTER TABLE "orcamentos"
  ADD CONSTRAINT "orcamentos_subtotal_nao_negativo" CHECK ("subtotal_centavos" >= 0),
  ADD CONSTRAINT "orcamentos_desconto_coerente" CHECK ("desconto_centavos" >= 0 AND "desconto_centavos" <= "subtotal_centavos"),
  ADD CONSTRAINT "orcamentos_total_confere" CHECK ("total_centavos" = "subtotal_centavos" - "desconto_centavos");

ALTER TABLE "itens_orcamento"
  ADD CONSTRAINT "itens_quantidade_positiva" CHECK ("quantidade" > 0),
  ADD CONSTRAINT "itens_valor_positivo" CHECK ("valor_unitario_centavos" > 0),
  ADD CONSTRAINT "itens_referencia_coerente" CHECK (
    ("tipo" = 'SERVICO' AND "servico_id" IS NOT NULL AND "peca_id" IS NULL) OR
    ("tipo" = 'PECA' AND "peca_id" IS NOT NULL AND "servico_id" IS NULL)
  );

ALTER TABLE "autorizacoes_desconto"
  ADD CONSTRAINT "desconto_solicitado_positivo" CHECK ("desconto_solicitado_centavos" > 0),
  ADD CONSTRAINT "desconto_autorizado_coerente" CHECK (
    "desconto_autorizado_centavos" IS NULL OR
    ("desconto_autorizado_centavos" > 0 AND "desconto_autorizado_centavos" <= "desconto_solicitado_centavos")
  ),
  ADD CONSTRAINT "desconto_decisao_coerente" CHECK (
    ("status" = 'PENDENTE' AND "gerente_id" IS NULL AND "decidido_em" IS NULL) OR
    ("status" <> 'PENDENTE' AND "gerente_id" IS NOT NULL AND "decidido_em" IS NOT NULL)
  );

ALTER TABLE "pecas_usadas"
  ADD CONSTRAINT "pecas_usadas_quantidade_positiva" CHECK ("quantidade" > 0),
  ADD CONSTRAINT "pecas_usadas_valor_positivo" CHECK ("valor_unitario_centavos" > 0);

ALTER TABLE "pagamentos"
  ADD CONSTRAINT "pagamentos_valor_positivo" CHECK ("valor_centavos" > 0);

-- ---------------------------------------------------------------- uma OS ativa por veículo
CREATE UNIQUE INDEX "ordens_servico_uma_ativa_por_veiculo"
  ON "ordens_servico" ("veiculo_id")
  WHERE "status" NOT IN ('ENTREGUE', 'CANCELADA');

-- ---------------------------------------------------------------- tabelas só de inserção
CREATE FUNCTION public.rejeitar_alteracao() RETURNS trigger
  LANGUAGE plpgsql
  SET search_path = ''
AS $$
BEGIN
  RAISE EXCEPTION 'A tabela % é só de inserção: % não é permitido', TG_TABLE_NAME, TG_OP
    USING ERRCODE = '42501';
END;
$$;

CREATE TRIGGER "movimentacoes_estoque_so_insercao"
  BEFORE UPDATE OR DELETE ON "movimentacoes_estoque"
  FOR EACH ROW EXECUTE FUNCTION public.rejeitar_alteracao();
CREATE TRIGGER "movimentacoes_estoque_sem_truncate"
  BEFORE TRUNCATE ON "movimentacoes_estoque"
  FOR EACH STATEMENT EXECUTE FUNCTION public.rejeitar_alteracao();

CREATE TRIGGER "historico_transicoes_so_insercao"
  BEFORE UPDATE OR DELETE ON "historico_transicoes"
  FOR EACH ROW EXECUTE FUNCTION public.rejeitar_alteracao();
CREATE TRIGGER "historico_transicoes_sem_truncate"
  BEFORE TRUNCATE ON "historico_transicoes"
  FOR EACH STATEMENT EXECUTE FUNCTION public.rejeitar_alteracao();

CREATE TRIGGER "pagamentos_so_insercao"
  BEFORE UPDATE OR DELETE ON "pagamentos"
  FOR EACH ROW EXECUTE FUNCTION public.rejeitar_alteracao();
CREATE TRIGGER "pagamentos_sem_truncate"
  BEFORE TRUNCATE ON "pagamentos"
  FOR EACH STATEMENT EXECUTE FUNCTION public.rejeitar_alteracao();

-- ---------------------------------------------------------------- RLS: o app não lê nem escreve
-- Toda tabela de public tem RLS ligada, inclusive a do Prisma. O dono (conexão do backend) não é
-- afetado; `anon` e `authenticated` ficam sem acesso.
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
  END LOOP;
END $$;

-- O Supabase concede tudo a anon e authenticated por padrão; revogar.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON FUNCTIONS FROM anon, authenticated;

-- Única exceção: o usuário lê os próprios avisos (também alimenta o Realtime).
GRANT SELECT ON TABLE public.avisos TO authenticated;
CREATE POLICY "avisos_leitura_propria" ON public.avisos
  FOR SELECT TO authenticated
  USING (destinatario_id = (SELECT auth.uid()));

-- ---------------------------------------------------------------- Realtime só para avisos
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.avisos;
  END IF;
END $$;
