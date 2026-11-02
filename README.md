# gaspo-front
Esse repositório é destinado a criação do front-end da aplicação gaspo, projeto integrador 3.
Flutter



                 ┌──────────────────────────┐
                 │       GASPO API          │
                 │ Spring Boot + MySQL      │
                 └────────────┬─────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ 1. REVISAR API   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ 2. DOCKERIZAR API│
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ 3. SUBIR/TESTAR  │
                    │ Docker + Banco   │
                    └────────┬─────────┘
                             │
                             ▼
                 ┌─────────────────────────┐
                 │ 4. CAPACITAÇÃO FLUTTER  │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │ 5. ESTRUTURA BASE FLUTTER│
                 │ Rotas + Tema + API      │
                 └────────────┬────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
       CHARLEY             LETÍCIA            JOÃO KVEIN
       5 telas             2 telas             2 telas
          │                   │                   │
          ▼                   ▼                   ▼
     JOÃO PEDRO             MARCUS             DEYVSON
     2 telas                2 telas             2 telas
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                              ▼
                            PEDRO
                           2 telas
                              │
                              ▼
                 ┌─────────────────────────┐
                 │ 6. INTEGRAÇÃO COM API   │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │ 7. TESTES + CODE REVIEW │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │ 8. INTEGRAÇÃO FINAL     │
                 └────────────┬────────────┘
                              │
                              ▼
                 ┌─────────────────────────┐
                 │      GASPO FINAL         │
                 └─────────────────────────┘

## Estrutura do app (após a integração das telas)

As telas desenvolvidas separadamente (repositórios `Telas-Projeto-Integrador`
e `GASPO`, e o projeto `gaspo` enviado em arquivo) foram unificadas aqui.

```
lib/
├── main.dart                  # GaspoApp: tema + rotas
├── app/
│   ├── rotas.dart             # Rotas nomeadas (Rotas.home, Rotas.perfil, ...)
│   └── tema.dart              # GaspoCores (paleta única) + ThemeData
├── modelos/                   # Usuario, Profissional (+ StatusProfissional)
├── dados/dados_exemplo.dart   # Dados fixos até a integração com a API
├── utils/mensagens.dart       # SnackBars padrão
├── widgets/
│   ├── gaspo_header.dart      # Seta de voltar + logo
│   ├── gaspo_bottom_nav.dart  # Menu inferior único
│   └── avaliacao_widgets.dart # Estrelas, caixa de comentário, botão secundário
└── telas/
    ├── autenticacao/          # Splash, Entrada, Login, Cadastro     (projeto gaspo)
    ├── inicio/                # Início / categorias                  (repo GASPO)
    ├── especialistas/         # Lista e detalhes do profissional     (repo GASPO)
    ├── avaliacao/             # Avaliação da consulta e profissional (repo GASPO)
    ├── unidade/               # Localização da unidade               (projeto gaspo)
    ├── notificacoes/          # Notificações                         (repo Telas-Projeto-Integrador)
    └── perfil/                # Perfil                               (repo Telas-Projeto-Integrador)
```

### Navegação

```
Splash → Entrada ─┬─ Usuário / Funcionário → Login → Início
                  └─ Cadastrar-se → Cadastro ⇄ Login

Início ─┬─ Especialistas → Detalhes do profissional
        ├─ Avaliação → Avaliação do profissional → Início
        ├─ Localização
        ├─ Notificações (ícone do cabeçalho)
        └─ Comunicados (em desenvolvimento)

Menu inferior: Início · Agendar (em desenvolvimento) · Histórico (em desenvolvimento) · Perfil
```

### Convenções

- Arquivos em `snake_case` terminando em `_tela.dart`; classes `NomeTela`.
- Novas telas: criar em `lib/telas/<modulo>/`, registrar em `lib/app/rotas.dart`
  e navegar com `Navigator.pushNamed(context, Rotas.x)`.
- Cores sempre por `GaspoCores`; telas internas usam `GaspoHeader` e `GaspoBottomNav`.

### Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
