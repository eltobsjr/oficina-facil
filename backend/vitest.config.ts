/**
 * Configuração do Vitest: testes em `test/` e `src/`, ambiente Node.
 * Os testes unitários e HTTP não usam banco; os de integração só rodam com TEST_* definidas.
 */

import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['test/**/*.test.ts', 'src/**/*.test.ts'],
    environment: 'node',
    clearMocks: true,
    setupFiles: ['test/setup.ts'],
  },
});
