/// Só os dígitos do texto.
String somenteDigitos(String texto) => texto.replaceAll(RegExp(r'\D'), '');

/// Aplica a máscara de [grupos] separados por [separadores], só quando há dígito depois do
/// separador (apagar o último dígito não deixa um ponto ou traço sobrando).
String _aplicarMascara(
  String digitos,
  List<int> grupos,
  List<String> separadores,
) {
  final saida = StringBuffer();
  var posicao = 0;
  for (var i = 0; i < grupos.length && posicao < digitos.length; i++) {
    if (i > 0) saida.write(separadores[i - 1]);
    final fim = (posicao + grupos[i]).clamp(0, digitos.length);
    saida.write(digitos.substring(posicao, fim));
    posicao = fim;
  }
  return saida.toString();
}

/// Formata CPF (até 11 dígitos) ou CNPJ (12 a 14 dígitos) enquanto se digita.
String formatarDocumento(String texto) {
  var digitos = somenteDigitos(texto);
  if (digitos.length > 14) digitos = digitos.substring(0, 14);
  if (digitos.length <= 11) {
    return _aplicarMascara(digitos, [3, 3, 3, 2], ['.', '.', '-']);
  }
  return _aplicarMascara(digitos, [2, 3, 3, 4, 2], ['.', '.', '/', '-']);
}

bool _todosIguais(String digitos) => RegExp(r'^(\d)\1+$').hasMatch(digitos);

int _digitoVerificador(String digitos, List<int> pesos) {
  var soma = 0;
  for (var i = 0; i < pesos.length; i++) {
    soma += int.parse(digitos[i]) * pesos[i];
  }
  final resto = soma % 11;
  return resto < 2 ? 0 : 11 - resto;
}

/// CPF com 11 dígitos e dígitos verificadores corretos.
bool cpfValido(String texto) {
  final d = somenteDigitos(texto);
  if (d.length != 11 || _todosIguais(d)) return false;
  return _digitoVerificador(d, [10, 9, 8, 7, 6, 5, 4, 3, 2]) ==
          int.parse(d[9]) &&
      _digitoVerificador(d, [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]) ==
          int.parse(d[10]);
}

/// CNPJ com 14 dígitos e dígitos verificadores corretos.
bool cnpjValido(String texto) {
  final d = somenteDigitos(texto);
  if (d.length != 14 || _todosIguais(d)) return false;
  return _digitoVerificador(d, [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]) ==
          int.parse(d[12]) &&
      _digitoVerificador(d, [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]) ==
          int.parse(d[13]);
}

bool documentoValido(String texto) => cpfValido(texto) || cnpjValido(texto);
