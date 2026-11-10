import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_facil/core/formatacao/documento.dart';
import 'package:oficina_facil/core/formatacao/placa.dart';
import 'package:oficina_facil/core/formatacao/telefone.dart';

// Só números fictícios, gerados pelo algoritmo do dígito verificador (R28).
const _cpfsValidos = ['529.982.247-25', '11144477735', '390.533.447-05'];
const _cnpjsValidos = ['11.222.333/0001-81', '11444777000161'];

void main() {
  group('CPF e CNPJ', () {
    test('aceitam números válidos, com ou sem máscara', () {
      for (final cpf in _cpfsValidos) {
        expect(cpfValido(cpf), isTrue, reason: cpf);
        expect(documentoValido(cpf), isTrue);
      }
      for (final cnpj in _cnpjsValidos) {
        expect(cnpjValido(cnpj), isTrue, reason: cnpj);
        expect(documentoValido(cnpj), isTrue);
      }
    });

    test('recusam dígito verificador errado, repetidos e tamanho errado', () {
      for (final texto in [
        '529.982.247-26',
        '111.111.111-11',
        '1234567890',
        '',
        '11.222.333/0001-82',
        '00.000.000/0000-00',
      ]) {
        expect(documentoValido(texto), isFalse, reason: texto);
      }
    });

    test('um CPF não vale como CNPJ e vice-versa', () {
      expect(cnpjValido('529.982.247-25'), isFalse);
      expect(cpfValido('11.222.333/0001-81'), isFalse);
    });

    test('a máscara de CPF aparece aos poucos, sem sobras ao apagar', () {
      expect(formatarDocumento('5'), '5');
      expect(formatarDocumento('5299'), '529.9');
      expect(formatarDocumento('529982'), '529.982');
      expect(formatarDocumento('529.982.'), '529.982');
      expect(formatarDocumento('52998224725'), '529.982.247-25');
    });

    test('a partir do 12º dígito a máscara vira a de CNPJ e para em 14', () {
      expect(formatarDocumento('112223330001'), '11.222.333/0001');
      expect(formatarDocumento('11222333000181'), '11.222.333/0001-81');
      expect(formatarDocumento('112223330001819999'), '11.222.333/0001-81');
    });

    test('só dígitos', () {
      expect(somenteDigitos('529.982.247-25'), '52998224725');
    });
  });

  group('telefone', () {
    test('máscara de fixo e de celular', () {
      expect(formatarTelefone('1'), '(1');
      expect(formatarTelefone('119'), '(11) 9');
      expect(formatarTelefone('1112345678'), '(11) 1234-5678');
      expect(formatarTelefone('11912345678'), '(11) 91234-5678');
      expect(formatarTelefone('(11) 91234-5678999'), '(11) 91234-5678');
      expect(formatarTelefone(''), '');
    });

    test('exige DDD mais 8 ou 9 dígitos', () {
      expect(telefoneValido('(11) 1234-5678'), isTrue);
      expect(telefoneValido('(11) 91234-5678'), isTrue);
      expect(telefoneValido('(11) 1234-567'), isFalse);
      expect(telefoneValido('91234-5678'), isFalse);
      expect(telefoneValido(''), isFalse);
    });
  });

  group('placa', () {
    test('aceita o padrão antigo e o Mercosul', () {
      for (final placa in ['ABC1234', 'abc-1234', 'ABC1D23', 'bra2e19']) {
        expect(placaValida(placa), isTrue, reason: placa);
      }
    });

    test('recusa formatos que não são placa', () {
      for (final placa in [
        'ABC123',
        'ABC12345',
        '1234567',
        'ABCDEFG',
        'AB12345',
      ]) {
        expect(placaValida(placa), isFalse, reason: placa);
      }
    });

    test('formata em maiúsculas, sem separadores, até 7 caracteres', () {
      expect(formatarPlaca('abc-1d23'), 'ABC1D23');
      expect(formatarPlaca('abc 1234 99'), 'ABC1234');
    });
  });
}
