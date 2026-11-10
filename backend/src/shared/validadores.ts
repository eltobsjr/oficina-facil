/**
 * Validadores e normalizadores de documento (CPF/CNPJ) e placa de veículo.
 *
 * Funções puras: aceitam o texto como o usuário digitou (com máscara) e a normalização devolve
 * o formato guardado no banco (documento só com dígitos, placa em maiúsculas sem hífen).
 */

export function somenteDigitos(texto: string): string {
  return texto.replace(/\D/g, '');
}

function todosIguais(digitos: string): boolean {
  return /^(\d)\1+$/.test(digitos);
}

function digitoVerificador(digitos: string, pesos: number[]): number {
  const soma = pesos.reduce((acc, peso, i) => acc + Number(digitos[i]) * peso, 0);
  const resto = soma % 11;
  return resto < 2 ? 0 : 11 - resto;
}

const PESOS_CPF_1 = [10, 9, 8, 7, 6, 5, 4, 3, 2];
const PESOS_CPF_2 = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2];
const PESOS_CNPJ_1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
const PESOS_CNPJ_2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

export function cpfValido(texto: string): boolean {
  const d = somenteDigitos(texto);
  if (d.length !== 11 || todosIguais(d)) return false;
  return (
    digitoVerificador(d, PESOS_CPF_1) === Number(d[9]) &&
    digitoVerificador(d, PESOS_CPF_2) === Number(d[10])
  );
}

export function cnpjValido(texto: string): boolean {
  const d = somenteDigitos(texto);
  if (d.length !== 14 || todosIguais(d)) return false;
  return (
    digitoVerificador(d, PESOS_CNPJ_1) === Number(d[12]) &&
    digitoVerificador(d, PESOS_CNPJ_2) === Number(d[13])
  );
}

/** CPF (11 dígitos) ou CNPJ (14 dígitos), com dígito verificador. */
export function documentoValido(texto: string): boolean {
  return cpfValido(texto) || cnpjValido(texto);
}

/** Documento só com dígitos, como é guardado. */
export function normalizarDocumento(texto: string): string {
  return somenteDigitos(texto);
}

/** Placa em maiúsculas, sem hífen, espaço ou outro separador. */
export function normalizarPlaca(texto: string): string {
  return texto.replace(/[^A-Za-z0-9]/g, '').toUpperCase();
}

const PLACA_ANTIGA = /^[A-Z]{3}[0-9]{4}$/;
const PLACA_MERCOSUL = /^[A-Z]{3}[0-9][A-Z][0-9]{2}$/;

/** Padrão antigo (ABC1234) ou Mercosul (ABC1D23). */
export function placaValida(texto: string): boolean {
  const placa = normalizarPlaca(texto);
  return PLACA_ANTIGA.test(placa) || PLACA_MERCOSUL.test(placa);
}
