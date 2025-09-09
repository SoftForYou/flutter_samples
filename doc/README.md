# Obsly Flutter Library Documentation

## Overview

Obsly is a comprehensive observability library for Flutter applications that provides automatic event capture, performance monitoring, user behavior analytics, and real-time debugging tools. This documentation covers the complete API and integration guide for the Obsly Flutter library.

## Documentation Index

- [📋 Library Overview](#library-overview)
- [🏗️ Architecture](architecture.md)
- [📚 API Reference](api-reference.md)
- [🚀 Integration Guide](integration-guide.md)
- [💡 Usage Examples](examples.md)
- [🔧 Advanced Features](advanced-features.md)

## Library Overview

The Obsly Flutter library provides comprehensive observability capabilities for Flutter applications through automatic event interception, performance monitoring, and advanced analytics.

### Core Features

#### 🎯 Automatic Event Interception
- **UI Events**: Taps, swipes, gestures, and user interactions
- **Lifecycle Events**: App state changes, screen navigation, and user flows
- **Navigation Events**: Route changes and navigation patterns
- **Console Events**: Debug logs, warnings, errors, and console output
- **Crash Events**: Unhandled exceptions and error reporting
- **HTTP Events**: Network requests, responses, and API interactions

#### 📊 Performance Monitoring & Analytics
- **Performance Metrics**: Operation timing and performance tracking
- **Custom Metrics**: Counters, gauges, and histograms
- **User Behavior Analytics**: User journey and interaction patterns
- **Session Management**: Intelligent session tracking and analysis

#### 🛠️ Rules Engine & Processing
- **Dynamic Rules**: Server-side rule configuration without app updates
- **Event Processing**: Real-time event filtering and transformation
- **Alerts & Notifications**: Automated alerting based on custom conditions
- **Business Logic**: Custom rules for business-specific event handling

#### 🔍 Development Tools
- **Debug Interface**: Real-time event viewer and configuration
- **Event Inspector**: Detailed event visualization and analysis
- **Performance Monitor**: Live performance analysis and optimization

### Supported Platforms

- ✅ **iOS** (iPhone/iPad)
- ✅ **Android** (Phone/Tablet)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **macOS** (Desktop)
- ✅ **Linux** (Desktop)  
- ✅ **Windows** (Desktop)

### Version & Compatibility

- **Current version**: 0.2.0
- **Flutter**: >= 3.4.0
- **Dart**: >= 3.0.0
- **iOS**: >= 12.0
- **Android**: API Level 21+
- **Kotlin**: Compatible with modern versions
- **Swift**: Compatible with modern versions

## Casos de Uso Típicos

### 🏦 Aplicaciones Bancarias
```dart
// Monitorización de transacciones críticas
await ObslySDK.instance.performance.startTransaction('PAYMENT', 'Process Payment');
await ObslySDK.instance.addTag([
  Tag(key: 'payment_method', value: 'credit_card'),
  Tag(key: 'amount', value: '150.00')
], 'Payment Context');
```

### 🛒 E-commerce
```dart
// Captura de eventos de compra
await ObslySDK.instance.metrics.incCounter(
  'ADD_TO_CART', 'Shopping', 'Add', 'ProductPage', 'SUCCESS'
);
```

### 📱 Apps Móviles Generales
```dart
// Configuración simple para captura automática
await ObslySDK.instance.init(InitParameters(
  obslyKey: 'YOUR_API_KEY',
  instanceURL: 'https://api.obsly.com',
  config: const ObslyConfig(
    enableUI: true,
    enableRequestLog: true,
    enableCrashes: true,
    enableDebugTools: true, // Solo en desarrollo
  ),
));
```

## Arquitectura Simplificada

```
┌─────────────────────────────────────────────────┐
│                 Flutter App                     │
├─────────────────────────────────────────────────┤
│               Obsly SDK Wrapper                 │
├─────────────────────────────────────────────────┤
│  UI Integration │ HTTP Integration │ Navigation  │
├─────────────────────────────────────────────────┤
│       Event Controller │ Performance Monitor    │
├─────────────────────────────────────────────────┤
│          Storage Layer │ Network Layer          │
├─────────────────────────────────────────────────┤
│                 Obsly Platform                  │
└─────────────────────────────────────────────────┘
```

## Instalación Rápida

1. **Agregar dependencia**:
```yaml
dependencies:
  obsly_flutter: ^0.2.0
```

2. **Inicializar SDK**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ObslySDK.instance.init(InitParameters(
    obslyKey: 'YOUR_OBSLY_KEY',
    instanceURL: 'https://api.obsly.com',
    appName: 'Mi App Flutter',
    appVersion: '1.0.0',
  ));
  
  runApp(MyApp());
}
```

3. **Envolver la aplicación**:
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ObslySDK.instance.wrapApp(
      app: MaterialApp(
        title: 'Mi App',
        home: HomePage(),
      ),
    );
  }
}
```

## Documentación Detallada

### Para Desarrolladores Nuevos
- [Guía de Integración](integration-guide.md) - Setup paso a paso
- [Ejemplos de Uso](examples.md) - Casos prácticos
- [API Reference](api-reference.md) - Métodos disponibles

### Para Desarrolladores Avanzados
- [Arquitectura](architecture.md) - Diseño interno
- [Características Avanzadas](advanced-features.md) - Configuración avanzada
- [Debug Tools](debug-tools.md) - Herramientas de desarrollo

### Para Equipos DevOps
- Configuración de Rate Limiting
- Gestión de Headers y Body Capture
- Configuración de Entornos

## Soporte y Recursos

- 📧 **Email**: info@obsly.tech
- 🌐 **Website**: https://obsly.tech
- 📖 **Documentación**: Este directorio
- 🐛 **Issues**: GitHub Issues
- 💬 **Discussions**: GitHub Discussions

## Licencia

MIT License - Ver archivo [LICENSE](../LICENSE) para detalles completos.
