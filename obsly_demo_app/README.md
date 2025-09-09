# Demo App - Obsly Flutter SDK

A clean, minimal example demonstrating the core features of the Obsly Flutter SDK. Perfect for understanding basic integration patterns and getting started with app monitoring and analytics.

## 🎯 Purpose

This demo app focuses on clarity and simplicity, showing you:

- ✅ **Basic SDK setup** - Minimal configuration to get started
- ✅ **Core event tracking** - Essential user interaction monitoring
- ✅ **Simple debugging** - Basic tools to verify SDK functionality
- ✅ **Clean architecture** - Well-structured, easy-to-follow code

## 🚀 Quick Start

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Run the app**

   ```bash
   flutter run
   ```

3. **Explore the features**
   - Tap buttons to generate events
   - Navigate between screens
   - View tracked events in the debug panel

## 📱 App Structure

```
lib/
├── main.dart              # App entry point and SDK initialization
├── screens/
│   ├── home_screen.dart   # Main demo screen with trackable actions
│   ├── detail_screen.dart # Secondary screen for navigation tracking
│   └── debug_screen.dart  # Simple event viewer
├── services/
│   └── demo_service.dart  # Example service with event tracking
└── widgets/
    └── demo_button.dart   # Button widget with automatic tracking
```

## 🔧 SDK Integration

### Basic Setup

```dart
import 'package:obsly_flutter/obsly_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Simple Obsly initialization
  await Obsly.initialize(
    config: ObslyConfig(
      enableCrashReporting: true,
      enableUITracking: true,
      debugMode: true, // Enable for development
    ),
  );

  runApp(DemoApp());
}
```

### Event Tracking Examples

#### Button Clicks

```dart
ElevatedButton(
  onPressed: () async {
    // Track button press
    await Obsly.trackEvent('button_pressed', metadata: {
      'button_type': 'primary',
      'screen': 'home',
    });

    // Your button logic here
  },
  child: Text('Track This Click'),
)
```

#### Screen Navigation

```dart
class HomeScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();

    // Track screen view
    Obsly.trackEvent('screen_view', metadata: {
      'screen_name': 'home',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

#### Custom Events

```dart
// Track user actions
await Obsly.trackEvent('user_action', metadata: {
  'action': 'data_loaded',
  'duration_ms': stopwatch.elapsedMilliseconds,
  'items_count': items.length,
});

// Track errors
try {
  await someRiskyOperation();
} catch (error, stackTrace) {
  await Obsly.trackError(
    error,
    stackTrace: stackTrace,
    category: 'data_processing',
  );
}
```

## 📊 Features Demonstrated

### 1. Basic Event Tracking

- Button click events
- Screen view tracking
- Custom user actions
- Automatic metadata collection

### 2. Navigation Monitoring

- Route changes
- Screen transition timing
- User flow analysis

### 3. Error Handling

- Exception tracking
- Stack trace collection
- Error categorization

### 4. Debug Interface

- Real-time event list
- Event metadata inspection
- SDK status monitoring

## 🎨 Debug Panel

The demo includes a simple debug panel accessible via the floating action button:

```dart
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DebugScreen()),
    );
  },
  child: Icon(Icons.bug_report),
)
```

### Debug Features

- **Event List** - See all tracked events in chronological order
- **Event Details** - Inspect metadata and timestamps
- **SDK Status** - Verify SDK initialization and health
- **Clear Events** - Reset event history for testing

## 🧪 Testing the Integration

### Manual Testing Steps

1. **Launch the app**

   - Verify SDK initializes without errors
   - Check debug logs for initialization messages

2. **Generate events**

   - Tap different buttons
   - Navigate between screens
   - Trigger intentional errors

3. **Verify tracking**
   - Open debug panel
   - Confirm events are being captured
   - Check event metadata accuracy

### Automated Testing

```bash
# Run all tests
flutter test

# Test with coverage
flutter test --coverage
```

## 📱 Platform Compatibility

| Platform    | Status   | Notes                  |
| ----------- | -------- | ---------------------- |
| **iOS**     | ✅ Full  | All features supported |
| **Android** | ✅ Full  | All features supported |
| **Web**     | ✅ Full  | All features supported |
| **macOS**   | ⚠️ Basic | Core tracking only     |
| **Windows** | ⚠️ Basic | Core tracking only     |
| **Linux**   | ⚠️ Basic | Core tracking only     |

## 🔗 Next Steps

After exploring this demo:

1. **Check out the Banking App** - See advanced integration patterns
2. **Read the SDK Documentation** - Learn about all available features
3. **Integrate into your app** - Apply these patterns to your project

### Related Examples

- [`../banking_app/`](../banking_app/) - Advanced, production-ready example
- [SDK Documentation](../doc/)
- [API Reference](https://pub.dev/documentation/obsly_flutter/latest/)

## 💡 Tips for Your Integration

### Start Simple

Begin with basic event tracking like this demo, then gradually add more advanced features as needed.

### Test Early

Use the debug panel to verify events are being tracked correctly during development.

### Performance

The SDK is designed to be lightweight, but monitor your app's performance during initial integration.

### Privacy

Even in simple apps, consider what data you're tracking and implement appropriate filtering.

## 📞 Support

- 📖 [Documentation](../doc/)
- 🐛 [Report Issues](https://github.com/SoftForYou/flutter_samples/issues)
- 💬 [Community Discord](https://discord.gg/obsly)
- 📧 [Email Support](mailto:support@obsly.com)

---

**Happy tracking! 🚀**
