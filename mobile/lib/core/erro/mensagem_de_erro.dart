import '../network/api_exception.dart';

/// Texto em português, claro e sem códigos internos, para qualquer erro que chegue à tela.
String mensagemDeErro(Object erro) {
  if (erro is SemConexaoException) {
    return 'Sem conexão com o servidor. Verifique a internet e tente de novo.';
  }
  if (erro is ApiException) {
    return switch (erro.codigo) {
      'usuario_inativo' => 'Este usuário está desativado. Procure o gerente.',
      'usuario_sem_perfil' =>
        'Este usuário não tem perfil cadastrado. Procure o gerente.',
      'ultimo_gerente' => 'Não é possível: este é o último gerente ativo.',
      'conflito' => erro.mensagem,
      'validacao' => 'Alguns dados não são válidos. Confira e tente de novo.',
      'nao_autorizado' => 'Sua sessão expirou. Entre novamente.',
      'proibido' => 'Você não tem permissão para esta ação.',
      'nao_encontrado' => 'Não encontramos o que você procura.',
      'limite_de_taxa' => 'Muitas tentativas. Aguarde um instante.',
      _ =>
        erro.status >= 500
            ? 'O servidor teve um problema. Tente novamente em instantes.'
            : 'Não foi possível concluir a ação.',
    };
  }
  return 'Algo deu errado. Tente novamente.';
}
