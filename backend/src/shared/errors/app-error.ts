/**
 * Hierarquia de erros de aplicação com status HTTP e código estável.
 *
 * Serviços lançam estes erros; `shared/http/erros.ts` os converte na resposta JSON padrão
 * `{ erro: { codigo, mensagem, detalhes } }`. Códigos são contrato com o app: mudar um é mudar a API.
 * Validação de entrada devolve 422; transição de estado inválida e conflitos devolvem 409.
 */

export class AppError extends Error {
  constructor(
    public readonly status: number,
    public readonly codigo: string,
    mensagem: string,
    public readonly detalhes?: unknown,
  ) {
    super(mensagem);
    this.name = new.target.name;
  }

  toJSON() {
    return { erro: { codigo: this.codigo, mensagem: this.message, detalhes: this.detalhes } };
  }
}

export class ErroValidacao extends AppError {
  constructor(detalhes: unknown, mensagem = 'Dados inválidos') {
    super(422, 'validacao', mensagem, detalhes);
  }
}

export class NaoAutorizado extends AppError {
  constructor(mensagem = 'Autenticação necessária', detalhes?: unknown) {
    super(401, 'nao_autorizado', mensagem, detalhes);
  }
}

export class Proibido extends AppError {
  constructor(mensagem = 'Sem permissão para esta ação', detalhes?: unknown) {
    super(403, 'proibido', mensagem, detalhes);
  }
}

export class NaoEncontrado extends AppError {
  constructor(recurso = 'Recurso', detalhes?: unknown) {
    super(404, 'nao_encontrado', `${recurso} não encontrado`, detalhes);
  }
}

export class Conflito extends AppError {
  constructor(mensagem: string, detalhes?: unknown) {
    super(409, 'conflito', mensagem, detalhes);
  }
}

/** Regra de negócio violada (transição de estado inválida, saldo insuficiente, etc.). */
export class RegraDeNegocio extends AppError {
  constructor(codigo: string, mensagem: string, detalhes?: unknown) {
    super(409, codigo, mensagem, detalhes);
  }
}

export class ErroLimiteDeTaxa extends AppError {
  constructor(limitador: string, janelaSegundos: number) {
    super(429, 'limite_de_taxa', 'Muitas requisições. Tente novamente em instantes.', {
      limitador,
      janelaSegundos,
    });
  }
}
