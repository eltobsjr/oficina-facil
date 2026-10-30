/**
 * Gera `openapi.json` sem subir o servidor (CI e geração de client).
 */

import { writeFileSync } from 'node:fs';
// Importar os módulos registra os paths no registry.
import '../modules/usuarios/index.js';
import { gerarDocumentoOpenApi } from '../shared/openapi/registry.js';

const documento = gerarDocumentoOpenApi('http://localhost:3000/api/v1');
writeFileSync('openapi.json', JSON.stringify(documento, null, 2) + '\n');
const total = Object.values(documento.paths ?? {}).reduce(
  (n, p) => n + Object.keys(p ?? {}).length,
  0,
);
console.log(`openapi.json gerado com ${total} operações`);
