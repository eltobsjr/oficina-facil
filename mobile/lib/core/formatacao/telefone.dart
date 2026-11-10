import 'documento.dart';

/// Formata telefone brasileiro com DDD enquanto se digita: (11) 1234-5678 ou (11) 91234-5678.
String formatarTelefone(String texto) {
  var d = somenteDigitos(texto);
  if (d.length > 11) d = d.substring(0, 11);
  if (d.isEmpty) return '';
  if (d.length < 3) return '($d';
  final ddd = d.substring(0, 2);
  final numero = d.substring(2);
  if (numero.length <= 4) return '($ddd) $numero';
  final corte = d.length <= 10 ? 4 : 5;
  return '($ddd) ${numero.substring(0, corte)}-${numero.substring(corte)}';
}

/// DDD mais 8 ou 9 dígitos.
bool telefoneValido(String texto) {
  final tamanho = somenteDigitos(texto).length;
  return tamanho == 10 || tamanho == 11;
}
