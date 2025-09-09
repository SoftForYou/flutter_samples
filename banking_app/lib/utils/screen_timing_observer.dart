import 'package:flutter/material.dart';
import 'package:obsly_flutter/obsly_sdk.dart';

/// Observer global para medir tiempos de carga de pantallas usando histogram de Obsly
/// Métrica: PageLoadComplete (tiempo técnico de renderizado)
class ScreenTimingObserver extends RouteObserver<ModalRoute<dynamic>> {
  static final ScreenTimingObserver _instance = ScreenTimingObserver._internal();
  factory ScreenTimingObserver() => _instance;
  ScreenTimingObserver._internal();

  static const String _metricName = 'PageLoadComplete';
  static const String _fbl = 'screen_timing';
  static const String _operation = 'technical_render';

  final Map<Route<dynamic>, DateTime> _routeStartTimes = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _startTiming(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _startTiming(newRoute);
    }
    if (oldRoute != null) {
      _endTiming(oldRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _endTiming(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _endTiming(route);
  }

  /// Inicia el timer para una ruta específica
  void _startTiming(Route<dynamic> route) {
    try {
      final routeName = _getRouteName(route);
      if (routeName.isEmpty) return;

      // Registrar el tiempo de inicio para referencia local
      _routeStartTimes[route] = DateTime.now();

      // Iniciar histogram timer de Obsly
      ObslySDK.instance.startHistogramTimer(
        _metricName,
        fbl: _fbl,
        operation: _operation,
        view: routeName,
      );

      // 🎯 Optimización: Medir el tiempo hasta que la pantalla esté completamente renderizada
      // Usar WidgetsBinding para capturar el momento exacto post-frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _endTimingAfterRender(route);
      });
    } catch (e) {
      // Silently ignore errors in timing measurement
    }
  }

  /// Termina el timing después del renderizado completo (más preciso)
  void _endTimingAfterRender(Route<dynamic> route) {
    try {
      final routeName = _getRouteName(route);
      if (routeName.isEmpty) return;

      // Verificar que el timer aún esté activo
      final startTime = _routeStartTimes[route];
      if (startTime == null) return;

      // Terminar histogram timer de Obsly
      ObslySDK.instance.endHistogramTimer(
        _metricName,
        fbl: _fbl,
        operation: _operation,
        view: routeName,
        state: 'rendered',
      );

      final duration = DateTime.now().difference(startTime);
    } catch (e) {
      // Silently ignore errors in timing measurement
    }
  }

  /// Termina el timer para una ruta específica
  void _endTiming(Route<dynamic> route) {
    try {
      final routeName = _getRouteName(route);
      if (routeName.isEmpty) return;

      // Remover de registro local
      final startTime = _routeStartTimes.remove(route);
      if (startTime == null) return;

      // Terminar histogram timer de Obsly
      ObslySDK.instance.endHistogramTimer(
        _metricName,
        fbl: _fbl,
        operation: _operation,
        view: routeName,
        state: 'completed',
      );

      final duration = DateTime.now().difference(startTime);
    } catch (e) {
      // Silently ignore errors in timing measurement
    }
  }

  /// Extrae el nombre de la ruta de forma segura
  String _getRouteName(Route<dynamic> route) {
    try {
      // Intentar obtener el nombre de la ruta
      if (route.settings.name != null && route.settings.name!.isNotEmpty) {
        return route.settings.name!.replaceAll('/', '');
      }

      // Fallback: usar el tipo de la ruta
      final routeType = route.runtimeType.toString();
      if (routeType.contains('MaterialPageRoute')) {
        return 'unknown_material_route';
      }

      return routeType.toLowerCase();
    } catch (e) {
      return 'unknown_route';
    }
  }

  /// Obtiene estadísticas actuales para debugging
  Map<String, dynamic> getStats() {
    return {
      'active_timers': _routeStartTimes.length,
      'active_routes': _routeStartTimes.keys.map((route) => _getRouteName(route)).toList(),
    };
  }

  /// Limpia todos los timers activos (útil para testing)
  void clearAllTimers() {
    _routeStartTimes.clear();
  }

  /// Detecta y mide ruta inicial/deeplink cuando la app se abre directamente en una pantalla
  void detectAndMeasureInitialRoute(BuildContext context) {
    try {
      final route = ModalRoute.of(context);
      if (route != null && !_routeStartTimes.containsKey(route)) {
        // Esta es probablemente una ruta inicial o deeplink - medirla
        _startTiming(route);
      }
    } catch (e) {
      // Silently ignore errors
    }
  }
}

/// Mixin para pantallas que necesiten control manual de timing
/// Úsalo cuando necesites medir tiempo hasta que la pantalla sea usable por el usuario
/// Métrica: PageLoadUsable (tiempo hasta interacción posible)
mixin ScreenTimingMixin<T extends StatefulWidget> on State<T> {
  static const String _metricName = 'PageLoadUsable';
  static const String _fbl = 'screen_timing';

  DateTime? _manualStartTime;
  String? _currentOperation;

  /// Inicia timing manual para una operación específica
  void startManualTiming(String operation, {String? customView}) {
    try {
      _manualStartTime = DateTime.now();
      _currentOperation = operation;

      final viewName = customView ?? widget.runtimeType.toString();

      ObslySDK.instance.startHistogramTimer(
        _metricName,
        fbl: _fbl,
        operation: operation,
        view: viewName,
      );
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Termina timing manual
  void endManualTiming({String? state, String? customView}) {
    try {
      if (_manualStartTime == null || _currentOperation == null) {
        return;
      }

      final viewName = customView ?? widget.runtimeType.toString();
      final duration = DateTime.now().difference(_manualStartTime!);

      ObslySDK.instance.endHistogramTimer(
        _metricName,
        fbl: _fbl,
        operation: _currentOperation!,
        view: viewName,
        state: state ?? 'completed',
      );

      _manualStartTime = null;
      _currentOperation = null;
    } catch (e) {
      // Silently ignore errors
    }
  }

  /// Mide tiempo de una función específica
  Future<T> measureFunction<T>(
    Future<T> Function() function,
    String operation, {
    String? customView,
    String? state,
  }) async {
    startManualTiming(operation, customView: customView);
    try {
      final result = await function();
      endManualTiming(state: state ?? 'success', customView: customView);
      return result;
    } catch (e) {
      endManualTiming(state: 'error', customView: customView);
      rethrow;
    }
  }

  @override
  void dispose() {
    // Limpiar cualquier timing pendiente al destruir el widget
    if (_manualStartTime != null && _currentOperation != null) {
      endManualTiming(state: 'disposed');
    }
    super.dispose();
  }
}
