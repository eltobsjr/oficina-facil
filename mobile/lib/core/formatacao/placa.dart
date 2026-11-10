/// Placa em maiúsculas, só letras e números, no máximo 7 caracteres.
String formatarPlaca(String texto) {
  final limpa = _limpar(texto);
  return limpa.length > 7 ? limpa.substring(0, 7) : limpa;
}

String _limpar(String texto) =>
    texto.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

final _placaAntiga = RegExp(r'^[A-Z]{3}[0-9]{4}$');
final _placaMercosul = RegExp(r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$');

/// Padrão antigo (ABC1234) ou Mercosul (ABC1D23).
bool placaValida(String texto) {
  final placa = _limpar(texto);
  return _placaAntiga.hasMatch(placa) || _placaMercosul.hasMatch(placa);
}
