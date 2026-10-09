# IF Goiano – Campus Urutaí

## Bacharelado em Sistemas de Informação
**Projeto Integrador III – Gerenciamento Auxiliar de Saúde Pública Online (GASPO)**

# Plano e Cronograma de Execução: Front-end Flutter

- **Período de execução:** 23/09/2026 a 18/12/2026
- **Tecnologias envolvidas:** Flutter (Dart), Spring Boot 3.4 (Java 21), Docker / Docker Compose e PostgreSQL.

## 1. Mapeamento de Responsabilidades do Front-end (Figma)

Com base na distribuição das interfaces do aplicativo móvel e do painel de administração no Figma, a divisão de trabalho por integrante ficou estruturada da seguinte maneira:

| Membro | Escopo de telas e responsabilidades | Módulo / Endpoints API |
|---|---|---|
| Charley | Splash Screen / Seleção de Perfil | AuthService |
| Letícia | Login e Cadastro (Cidadão e Funcionário); Informações da Unidade de Saúde; Feed de Avisos Gerais (Paciente); Gestão de Avisos (Painel Admin) | UsuarioRepository; UnidadeSaudeService; AvisoService |
| Marcus | Tela de Início / Dashboard; Shell Bar e Navegação Global | Integração Base/Roteamento; AvaliacaoService |
| João Kevin | — | AgendaService; ConsultaService; ProfissionalService |
| Pedro | Busca e Filtro de Médicos; Avaliação e Feedback do Atendimento; Agendamento de Consultas; Cadastro de Horários (Admin) | AgendaService; ConsultaService; ProfissionalService |
| Deyvson Queiroz | Histórico de Consultas; Consultas Marcadas / Status; Central de Notificações / Alertas | NotificacaoService; ConsultaService; CidadaoService |

> **Observação:** a tabela original distribui algumas responsabilidades e endpoints em células compartilhadas. A organização acima foi transcrita para Markdown para facilitar a leitura.

## 2. Cronograma Geral de Execução (Setembro a Dezembro de 2026)

| Meta | Especificação | Indicador qualitativo | Quantidade | Período | Responsáveis |
|---:|---|---|---|---|---|
| 1 | Dockerização e Setup | Estabilidade do Docker e repositório | 1 API/App | 23/09 a 07/10 | Deyvson, Pedro, Marcus |
| 2 | Autenticação e Core | Telas responsivas de login e dashboard | 5 telas | 08/10 a 21/10 | Charley, Letícia, Queiroz, Marcus |
| 3 | Infos e Avisos | Visualização de avisos e notificações | 6 telas | 22/10 a 04/11 | Letícia, Queiroz, Charley |
| 4 | Agenda e Consultas | Busca de médicos e agendamentos | 6 telas | 05/11 a 18/11 | João Kevin, Pedro, Deyvson |
| 5 | Integração API | Consumo REST e tratamento de erros | 100% | 19/11 a 27/11 | Toda a equipe |
| 6 | Testes / Usabilidade | Conformidade WCAG 2.1 em mobiles | 1 APK | 28/11 a 05/12 | Toda a equipe |
| 7 | Apresentação Final | Homologação em ambiente simulado | 1 apresentação | 06/12 a 18/12 | Toda a equipe |

## 3. Detalhamento Semanal das Atividades

### 3.1 Sprints 1 e 2: Infraestrutura, Docker e Setup (23/09/2026 – 07/10/2026)

- Criar o `Dockerfile` otimizado para Spring Boot (Java 21) e `docker-compose.yml` com PostgreSQL.
- Subir os contêineres e validar a API e o Swagger UI em `localhost:8080/swagger-ui.html`.
- Criar o repositório `gaspo-mobile` no GitHub com a estrutura de pastas do Flutter.
- Capacitação da equipe para requisições HTTP e armazenamento seguro de tokens JWT.

**Entregável:** API executando via Docker e projeto Flutter configurado.

### 3.2 Sprints 3 e 4: Autenticação e Core da Navegação (08/10/2026 – 21/10/2026)

- **Charley:** Splash Screen, Escolha de Perfil, Tela de Login e Tela de Cadastro.
- **Marcus:** Tela de Início / Dashboard Principal e menu de navegação inferior.

**Entregável:** fluxo de login e cadastro navegável com salvamento do token.

### 3.3 Sprints 5 e 6: Módulo Informativo, Avisos e Perfis (22/10/2026 – 04/11/2026)

- **Letícia:** Feed de Avisos e tela de Cadastrar/Gerenciar Avisos no painel Admin.
- **Queiroz:** Telas de Perfil do Cidadão, Perfil do Profissional e Notificações.
- **Charley:** Tela de Informações da Unidade de Saúde (localização e horários).

**Entregável:** módulo de comunicação oficial e avisos da UBS funcional.

### 3.4 Sprints 7 e 8: Agendamento, Médicos e Histórico (05/11/2026 – 18/11/2026)

- **João Kevin:** Tela de Especialistas/Busca de Médicos e Avaliação do Atendimento.
- **Pedro:** Tela de Agendamento e Cadastro de Grade de Horários (Painel Admin).
- **Deyvson:** Tela de Histórico de Consultas e Gestão de Consultas Marcadas.

**Entregável:** fluxo principal de agendamento de consultas concluído.

### 3.5 Sprint 9: Integração Geral HTTP/REST (19/11/2026 – 27/11/2026)

- Conectar todos os formulários e listagens aos endpoints da API Spring Boot.
- Implementar indicadores de carregamento (*loading spinners*), tratamento offline e mensagens de erro amigáveis.

**Entregável:** aplicativo integrado à API backend.

### 3.6 Sprint 10: Testes, Usabilidade e Ajustes Finais (28/11/2026 – 05/12/2026)

- Realizar testes de usabilidade com base na WCAG 2.1 (contraste e fontes acessíveis).
- Corrigir falhas de layout e validar as regras de negócio.

**Entregável:** APK gerado e testado em múltiplos dispositivos Android.

### 3.7 Sprints 11 e 12: Implantação e Apresentação Final (06/12/2026 – 18/12/2026)

- Simular o uso em ambiente real de uma Unidade Básica de Saúde (UBS).
- Elaborar o relatório final e preparar os slides de apresentação.

**Entregável:** projeto GASPO concluído, implantado e apresentado à banca.

## 4. Justificativa da Readequação do Planejamento

Com a conclusão das etapas de modelagem do banco de dados e desenvolvimento dos serviços centrais da API Spring Boot, tornou-se essencial detalhar a fase final do projeto, focada na construção da interface móvel em Flutter e na containerização dos serviços via Docker.

A distribuição das atividades foi calibrada respeitando o domínio técnico acumulado por cada integrante, garantindo coesão entre o Figma e o código-fonte. O cronograma estende-se até dezembro para comportar a homologação do sistema em ambiente simulado de UBS.
