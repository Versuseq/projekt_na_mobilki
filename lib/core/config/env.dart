import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPEN_METEO_BASE_URL', obfuscate: true)
  static final String openMeteoBaseUrl = _Env.openMeteoBaseUrl;
}