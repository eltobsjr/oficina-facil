import { describe, expect, it } from 'vitest';
import {
  cnpjValido,
  cpfValido,
  documentoValido,
  normalizarDocumento,
  normalizarPlaca,
  placaValida,
  somenteDigitos,
} from '../../src/shared/validadores.js';

// Só números fictícios, gerados pelo algoritmo do dígito verificador (R28).
const CPFS_VALIDOS = ['529.982.247-25', '11144477735', '390.533.447-05', '123.456.789-09'];
const CNPJS_VALIDOS = ['11.222.333/0001-81', '11444777000161', '45.723.174/0001-10'];

describe('CPF', () => {
  it.each(CPFS_VALIDOS)('aceita %s, com ou sem máscara', (cpf) => {
    expect(cpfValido(cpf)).toBe(true);
  });

  it.each([
    ['dígito verificador errado', '529.982.247-26'],
    ['primeiro dígito errado', '52998224715'],
    ['todos os dígitos iguais', '111.111.111-11'],
    ['curto demais', '1234567890'],
    ['longo demais', '123456789012'],
    ['vazio', ''],
    ['com letras', 'abc.def.ghi-jk'],
  ])('recusa: %s', (_motivo, cpf) => {
    expect(cpfValido(cpf)).toBe(false);
  });
});

describe('CNPJ', () => {
  it.each(CNPJS_VALIDOS)('aceita %s, com ou sem máscara', (cnpj) => {
    expect(cnpjValido(cnpj)).toBe(true);
  });

  it.each([
    ['dígito verificador errado', '11.222.333/0001-82'],
    ['todos os dígitos iguais', '00.000.000/0000-00'],
    ['curto demais', '1122233300018'],
    ['vazio', ''],
  ])('recusa: %s', (_motivo, cnpj) => {
    expect(cnpjValido(cnpj)).toBe(false);
  });

  it('um CPF não é CNPJ e vice-versa', () => {
    expect(cnpjValido('529.982.247-25')).toBe(false);
    expect(cpfValido('11.222.333/0001-81')).toBe(false);
  });
});

describe('documento', () => {
  it('aceita CPF ou CNPJ válidos e recusa o resto', () => {
    expect(documentoValido('529.982.247-25')).toBe(true);
    expect(documentoValido('11.222.333/0001-81')).toBe(true);
    expect(documentoValido('529.982.247-26')).toBe(false);
  });

  it('normaliza para só dígitos', () => {
    expect(normalizarDocumento('529.982.247-25')).toBe('52998224725');
    expect(normalizarDocumento('11.222.333/0001-81')).toBe('11222333000181');
    expect(somenteDigitos(' (11) 91234-5678 ')).toBe('11912345678');
  });
});

describe('placa', () => {
  it.each(['ABC1234', 'abc-1234', 'ABC 1234', 'ABC1D23', 'abc1d23', 'BRA2E19'])(
    'aceita %s',
    (placa) => {
      expect(placaValida(placa)).toBe(true);
    },
  );

  it.each([
    ['curta', 'ABC123'],
    ['longa', 'ABC12345'],
    ['sem letras', '1234567'],
    ['só letras', 'ABCDEFG'],
    ['letra no lugar errado do padrão antigo', 'AB12345'],
    ['Mercosul com letra fora do lugar', 'ABC12D3'],
    ['vazia', ''],
  ])('recusa: %s', (_motivo, placa) => {
    expect(placaValida(placa)).toBe(false);
  });

  it('normaliza para maiúsculas sem separadores', () => {
    expect(normalizarPlaca('abc-1d23')).toBe('ABC1D23');
    expect(normalizarPlaca(' abc 1234 ')).toBe('ABC1234');
  });
});
