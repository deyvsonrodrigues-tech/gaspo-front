import '../servicos/agenda_service.dart';
import '../servicos/api/cliente_api.dart';
import '../servicos/api/servicos_api.dart';
import '../servicos/auth_service.dart';
import '../servicos/avaliacao_consulta_service.dart';
import '../servicos/avaliacao_service.dart';
import '../servicos/aviso_service.dart';
import '../servicos/consulta_service.dart';
import '../servicos/notificacao_service.dart';
import '../servicos/profissional_service.dart';

/// `--dart-define=MODO_LOCAL=true` roda o app sem a API, com dados de exemplo
/// em memória (os testes também usam esse modo).
const bool modoLocal = bool.fromEnvironment('MODO_LOCAL');

/// Faz todos os serviços usarem a Gaspo-api.
void usarApi([ClienteApi? cliente]) {
  final api = cliente ?? ClienteApi.instancia;
  AuthService.instancia = AuthServiceApi(api);
  ProfissionalService.instancia = ProfissionalServiceApi(api);
  AgendaService.instancia = AgendaServiceApi(api);
  ConsultaService.instancia = ConsultaServiceApi(api);
  AvisoService.instancia = AvisoServiceApi(api);
  AvaliacaoService.instancia = AvaliacaoServiceApi(api);
  AvaliacaoConsultaService.instancia = AvaliacaoConsultaServiceApi(api);
  NotificacaoService.instancia = NotificacaoServiceApi(api);
}
