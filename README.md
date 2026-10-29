# OficinaFácil

![OficinaFácil](docs/branding/logo/oficinafacil-app-icon-512.png)

Gestão de ordens de serviço para oficina mecânica. Projeto da disciplina de Análise e Projeto de Sistemas, desenvolvido em Flutter (web e Android).

## Rodar

```bash
flutter pub get
flutter run -d chrome      # web
flutter run -d android     # Android
flutter test
```

## Arquitetura

Clean Architecture por feature, com Riverpod (estado) e go_router (navegação).

```
lib/
├── core/        tema e roteamento
└── features/
    ├── home/
    └── ordem_servico/domain/
```

Diagramas (casos de uso, estados da OS, camadas): [docs/diagramas.md](docs/diagramas.md)
