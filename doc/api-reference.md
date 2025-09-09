# Referencia API Corregida - Obsly Flutter SDK

⚠️ **ESTA ES LA VERSIÓN CORREGIDA BASADA EN EL CÓDIGO FUENTE REAL**

## Configuración Real - ObslyConfig

### Propiedades Disponibles (según código fuente)

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `enableScreenshotOnUi` | `bool?` | Screenshots en eventos UI |
| `requestBlacklist` | `List<String>?` | Lista de URLs a ignorar |
| `requestBodyWhitelist` | `List<RequestBodyConfig>?` | Configuración para capturar request/response body |
| `requestHeadersWhitelist` | `List<RequestHeadersConfig>?` | Configuración para capturar headers específicos |
| `tagsBlacklist` | `TagsBlacklistConfig?` | Configuración de filtros para tags |
| `rageClick` | `RageClickConfig?` | Configuración de rage click detection |
| `enableCrashes` | `bool?` | Captura de crashes |
| `enableLifeCycleLog` | `bool?` | Eventos de ciclo de vida |
| `enableRequestLog` | `bool?` | Logging de requests HTTP |
| `enableTagger` | `bool?` | Sistema de tags |
| `enablePerformance` | `bool?` | Métricas de performance |
| `enableMetrics` | `bool?` | Sistema de métricas |
| `enableUI` | `bool?` | Eventos de UI |
| `automaticViewDetection` | `bool?` | Detección automática de vistas |
| `sessionMaxLengthMins` | `int?` | Duración máxima de sesión |
| `bufferSize` | `int?` | Tamaño del buffer de eventos |
| `captureConsole` | `bool?` | Captura de console logs |
| `captureBodyOnError` | `bool?` | Capturar body en errores HTTP |
| `messengerInterval` | `int?` | Intervalo de envío (mín: 10 segundos) |
| `enableDebugTools` | `bool?` | Herramientas debug |
| `release` | `String?` | Identificador de release |
| `obslyTools` | `ObslyTools?` | Configuración de herramientas Obsly |

### Ejemplo de Configuración Real

```dart
const config = ObslyConfig(
  // Características principales
  enableUI: true,
  enableRequestLog: true,
  enableCrashes: true,
  enablePerformance: true,
  enableMetrics: true,
  enableTagger: true,
  
  // Configuración de UI
  enableScreenshotOnUi: false,
  automaticViewDetection: true,
  
  // Configuración de console
  captureConsole: true,
  
  // Configuración de sesión
  sessionMaxLengthMins: 60,
  
  // Configuración de red
  captureBodyOnError: true,
  messengerInterval: 30,
  bufferSize: 100,
  
  // Debug (solo desarrollo)
  enableDebugTools: false,
  
  // Rage click detection
  rageClick: RageClickConfig(
    active: true,
    screenshot: true,
    screenshotPercent: 0.1,
  ),
  
  // Filtros de requests
  requestBlacklist: [
    'https://analytics.google.com/*',
    'https://firebase.googleapis.com/*',
  ],
  
  // Captura selectiva de headers
  requestHeadersWhitelist: [
    RequestHeadersConfig(
      url: 'https://api.miapp.com/*',
      fromStatus: 400,
      toStatus: 599,
      headers: ['content-type', 'x-request-id'],
    ),
  ],
  
  // Captura selectiva de body
  requestBodyWhitelist: [
    RequestBodyConfig(
      url: 'https://api.miapp.com/errors/*',
      fromStatus: 500,
      toStatus: 599,
      captureRequestBody: true,
      captureResponseBody: true,
    ),
  ],
);
```

## Clases de Configuración Auxiliares

### RageClickConfig
```dart
class RageClickConfig {
  final bool? active;
  final bool? screenshot;
  final double? screenshotPercent;
}
```

### RequestHeadersConfig
```dart
class RequestHeadersConfig {
  final String url;           // URL pattern (soporta wildcards)
  final int fromStatus;       // Status code mínimo
  final int toStatus;         // Status code máximo  
  final List<String> headers; // Headers a capturar
}
```

### RequestBodyConfig
```dart
class RequestBodyConfig {
  final String url;                    // URL pattern
  final int fromStatus;                // Status code mínimo
  final int toStatus;                  // Status code máximo
  final bool captureRequestBody;       // Capturar request body
  final bool captureResponseBody;      // Capturar response body
}
```

### TagsBlacklistConfig
```dart
class TagsBlacklistConfig {
  final List<String>? categories;  // Categorías a filtrar
  final List<String>? keys;        // Keys a filtrar
  
  // Soporta wildcards como "APPCBK.*" o "fc*"
}
```

## ❌ Lo que NO Existe (y eliminé de la documentación)

- ~~`RateLimits` class~~ 
- ~~`RateLimitConfig` class~~
- ~~`enableAutomaticCapture` property~~
- ~~Sistema complejo de rate limiting~~

## ✅ Lo que SÍ Funciona

1. **Control básico de frecuencia**: `messengerInterval` y `bufferSize`
2. **Filtros de captura**: Blacklists y whitelists
3. **Configuración granular**: Por tipo de evento (UI, requests, crashes, etc.)
4. **Debug tools**: Para desarrollo
5. **Screenshot capture**: Configuración de rage clicks

Esta es la API real basada en el código fuente actual.
