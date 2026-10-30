import { readdirSync, readFileSync, statSync } from 'node:fs';
import { dirname, join, relative, resolve, sep } from 'node:path';
import { describe, expect, it } from 'vitest';

/**
 * Regra do monólito modular: um módulo só importa de outro pelo `index.ts` dele.
 * `shared/` e `config/` nunca importam de `modules/`.
 */
const RAIZ = resolve(__dirname, '../../src');
const MODULOS = join(RAIZ, 'modules');

function arquivosTs(dir: string): string[] {
  return readdirSync(dir).flatMap((nome) => {
    const caminho = join(dir, nome);
    if (statSync(caminho).isDirectory()) return nome === 'generated' ? [] : arquivosTs(caminho);
    return nome.endsWith('.ts') ? [caminho] : [];
  });
}

function importsRelativos(arquivo: string): string[] {
  const conteudo = readFileSync(arquivo, 'utf8');
  const regex =
    /(?:import|export)\s[^'"]*?from\s+['"](\.{1,2}\/[^'"]+)['"]|import\s+['"](\.{1,2}\/[^'"]+)['"]/g;
  const encontrados: string[] = [];
  for (const m of conteudo.matchAll(regex)) encontrados.push((m[1] ?? m[2])!);
  return encontrados;
}

function moduloDe(caminho: string): string | null {
  const rel = relative(MODULOS, caminho);
  if (rel.startsWith('..')) return null;
  return rel.split(sep)[0] ?? null;
}

describe('fronteiras entre módulos', () => {
  const violacoes: string[] = [];

  for (const arquivo of arquivosTs(RAIZ)) {
    const origem = moduloDe(arquivo);
    for (const imp of importsRelativos(arquivo)) {
      const alvo = resolve(dirname(arquivo), imp);
      const destino = moduloDe(alvo);
      if (!destino) continue;
      const relArquivo = relative(RAIZ, arquivo);
      const normalizado = alvo.replace(/\\/g, '/');
      const ehIndex =
        /\/modules\/[^/]+\/index(\.js)?$/.test(normalizado) ||
        /\/modules\/[^/]+$/.test(normalizado);
      if (origem === null) {
        const infra = /^(shared|config)\//.test(relArquivo.replace(/\\/g, '/'));
        if (infra) violacoes.push(`${relArquivo} (shared/config) importa modules: ${imp}`);
        else if (!ehIndex) violacoes.push(`${relArquivo} importa interior de '${destino}': ${imp}`);
        continue;
      }
      if (destino !== origem && !ehIndex) {
        violacoes.push(`${relArquivo} importa interior de '${destino}': ${imp}`);
      }
    }
  }

  it('nenhum arquivo importa o interior de outro módulo nem shared importa modules', () => {
    expect(violacoes).toEqual([]);
  });

  it('não há ciclo de dependência entre módulos', () => {
    const grafo = new Map<string, Set<string>>();
    for (const arquivo of arquivosTs(MODULOS)) {
      const origem = moduloDe(arquivo)!;
      for (const imp of importsRelativos(arquivo)) {
        const destino = moduloDe(resolve(dirname(arquivo), imp));
        if (destino && destino !== origem)
          (grafo.get(origem) ?? grafo.set(origem, new Set()).get(origem)!).add(destino);
      }
    }
    const visitando = new Set<string>();
    const feito = new Set<string>();
    const ciclos: string[] = [];
    const visitar = (n: string, trilha: string[]) => {
      if (feito.has(n)) return;
      if (visitando.has(n)) {
        ciclos.push([...trilha, n].join(' → '));
        return;
      }
      visitando.add(n);
      for (const v of grafo.get(n) ?? []) visitar(v, [...trilha, n]);
      visitando.delete(n);
      feito.add(n);
    };
    for (const n of grafo.keys()) visitar(n, []);
    expect(ciclos).toEqual([]);
  });
});
