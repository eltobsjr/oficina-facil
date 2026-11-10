import 'documento.dart';
import 'telefone.dart';

/// Linha de contato de um cliente: documento e telefone formatados, separados por " · ".
String contatoFormatado(String documento, String telefone) =>
    '${formatarDocumento(documento)} · ${formatarTelefone(telefone)}';
