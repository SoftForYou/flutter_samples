# Contributing to Obsly Flutter Examples

Thank you for your interest in contributing to the Obsly Flutter Examples repository! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Contribution Types](#contribution-types)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Issue Guidelines](#issue-guidelines)

## 🤝 Code of Conduct

This project follows a Code of Conduct to ensure a welcoming environment for all contributors:

### Our Pledge
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

### Unacceptable Behavior
- Harassment or discriminatory language
- Personal attacks or trolling
- Publishing private information without permission
- Any conduct that would be inappropriate in a professional setting

## 🚀 How to Contribute

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_samples.git
   cd flutter_samples
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Types of Contributions Welcome

- 🐛 **Bug fixes** - Fix issues in existing examples
- ✨ **New examples** - Add new integration patterns
- 📚 **Documentation** - Improve guides and explanations
- 🧪 **Tests** - Add or improve test coverage
- 🎨 **UI improvements** - Better user interfaces
- ⚡ **Performance** - Optimize existing code
- 🔒 **Security** - Fix security vulnerabilities

## 🛠️ Development Setup

### Prerequisites

- Flutter 3.4.0 or higher
- Dart 3.0.0 or higher
- Git
- Your preferred IDE (VS Code, Android Studio, etc.)

### Local Development

1. **Install dependencies** for both apps:
   ```bash
   # Banking app
   cd banking_app
   flutter pub get
   cd ..
   
   # Demo app
   cd obsly_demo_app
   flutter pub get
   cd ..
   ```

2. **Set up your API key** (for testing):
   ```bash
   # Create environment file
   echo "OBSLY_API_KEY=your_test_key_here" > banking_app/.env
   echo "OBSLY_API_KEY=your_test_key_here" > obsly_demo_app/.env
   ```

3. **Run the examples**:
   ```bash
   cd banking_app
   flutter run
   ```

### Development Tools

We recommend using these tools:

- **Flutter Inspector** - For UI debugging
- **Dart DevTools** - For performance analysis
- **Git hooks** - For code quality (see setup below)

#### Git Hooks Setup

```bash
# Install pre-commit hooks
cp scripts/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit
```

## 🎯 Contribution Types

### 1. Bug Fixes

**Before submitting:**
- Ensure the bug is reproducible
- Check if an issue already exists
- Include steps to reproduce
- Test your fix thoroughly

**Bug fix checklist:**
- [ ] Issue clearly describes the problem
- [ ] Fix addresses the root cause
- [ ] Tests added/updated to prevent regression
- [ ] Documentation updated if needed

### 2. New Examples

**Guidelines for new examples:**
- Must demonstrate a specific Obsly SDK feature
- Should include comprehensive comments
- Must follow existing code style
- Include README with setup instructions

**New example checklist:**
- [ ] Clear learning objective
- [ ] Well-commented code
- [ ] README with setup guide
- [ ] Tests included
- [ ] Screenshots/GIFs if UI-focused

### 3. Documentation Improvements

**Types of documentation contributions:**
- Fix typos or unclear explanations
- Add missing information
- Improve code examples
- Translate documentation
- Add troubleshooting guides

**Documentation checklist:**
- [ ] Information is accurate and up-to-date
- [ ] Examples are tested and working
- [ ] Writing is clear and concise
- [ ] Follows existing style guidelines

### 4. Performance Improvements

**Performance contribution guidelines:**
- Benchmark before and after changes
- Document performance gains
- Ensure changes don't break functionality
- Consider impact on different platforms

## 📝 Coding Standards

### Dart/Flutter Style

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// Good
class UserService {
  Future<User> getUser(String userId) async {
    // Implementation
  }
}

// Bad
class user_service {
  Future<User> get_user(String user_id) async {
    // Implementation
  }
}
```

### Code Organization

```
lib/
├── models/          # Data models
├── services/        # Business logic services
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── utils/           # Utility functions
└── config/          # Configuration files
```

### Obsly Integration Patterns

**Event Tracking:**
```dart
// Good - Descriptive event names with metadata
await ObslySDK.instance.trackEvent(
  'user_login_attempt',
  metadata: {
    'auth_method': 'email',
    'user_type': 'returning',
  },
  category: 'authentication',
);

// Bad - Generic names without context
await ObslySDK.instance.trackEvent('click');
```

**Error Handling:**
```dart
// Good - Proper error context and metadata
try {
  await performAction();
} catch (error, stackTrace) {
  await ObslySDK.instance.trackError(
    error,
    stackTrace: stackTrace,
    category: 'user_action',
    metadata: {
      'action': 'login',
      'user_id': userId,
    },
  );
  rethrow;
}
```

### Comments and Documentation

```dart
/// Service for handling user authentication with Obsly tracking.
/// 
/// This service automatically tracks authentication events including
/// login attempts, successes, and failures.
class AuthService {
  /// Attempts to log in a user with email and password.
  /// 
  /// Tracks login attempts and outcomes automatically.
  /// Throws [AuthException] on authentication failure.
  Future<User> login(String email, String password) async {
    // Implementation with tracking
  }
}
```

## 🧪 Testing Requirements

### Test Coverage

All contributions must maintain or improve test coverage:

- **Unit tests** - For business logic and services
- **Widget tests** - For UI components
- **Integration tests** - For complete user flows
- **Golden tests** - For visual regression testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Check coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Structure

```dart
// Good test structure
group('AuthService', () {
  late AuthService authService;
  late MockObslySDK mockObsly;
  
  setUp(() {
    mockObsly = MockObslySDK();
    authService = AuthService(obslySDK: mockObsly);
  });
  
  group('login', () {
    test('should track login attempt', () async {
      // Arrange
      when(mockObsly.trackEvent(any, metadata: anyNamed('metadata')))
          .thenAnswer((_) async {});
      
      // Act
      await authService.login('test@example.com', 'password');
      
      // Assert
      verify(mockObsly.trackEvent(
        'user_login_attempt',
        metadata: any,
        category: 'authentication',
      )).called(1);
    });
  });
});
```

### Test Requirements

- [ ] All new code has tests
- [ ] Tests pass on all platforms
- [ ] Integration tests cover user flows
- [ ] Mock external dependencies
- [ ] Test both success and failure scenarios

## 📚 Documentation Standards

### README Requirements

Each app must have a comprehensive README with:

```markdown
# App Name

Brief description of what the app demonstrates.

## Features Demonstrated
- Feature 1 with brief explanation
- Feature 2 with brief explanation

## Quick Start
1. Install dependencies
2. Configure API key
3. Run the app

## Code Examples
Key integration patterns shown with code snippets.

## Learning Objectives
What developers will learn from this example.
```

### Code Comments

```dart
// Good - Explains the why, not just the what
// Track user session start to measure engagement duration
// and identify user behavior patterns
await ObslySDK.instance.startSession(userId: user.id);

// Bad - States the obvious
// Start session
await ObslySDK.instance.startSession(userId: user.id);
```

### API Documentation

Use dartdoc comments for public APIs:

```dart
/// Tracks a user action with automatic metadata enrichment.
/// 
/// This method automatically adds common metadata like timestamp,
/// screen name, and user context to the tracked event.
/// 
/// Example:
/// ```dart
/// await trackUserAction(
///   'button_pressed',
///   metadata: {'button_id': 'login'},
/// );
/// ```
/// 
/// See also:
/// * [trackEvent] for basic event tracking
/// * [trackError] for error tracking
Future<void> trackUserAction(
  String action, {
  Map<String, dynamic>? metadata,
}) async {
  // Implementation
}
```

## 🔄 Pull Request Process

### Before Submitting

1. **Ensure your code follows our standards**
2. **Run all tests and ensure they pass**
3. **Update documentation** as needed
4. **Add/update tests** for your changes
5. **Rebase on the latest main branch**

### PR Description Template

```markdown
## Description
Brief description of the changes and why they're needed.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that breaks existing functionality)
- [ ] Documentation update

## Changes Made
- Specific change 1
- Specific change 2
- Specific change 3

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Screenshots/videos attached (if UI changes)

## Checklist
- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes or documented if necessary
```

### Review Process

1. **Automated checks** must pass (CI/CD)
2. **Code review** by maintainers
3. **Testing** on multiple platforms
4. **Documentation review** if applicable
5. **Final approval** and merge

### PR Guidelines

- Keep PRs focused and atomic
- Write clear, descriptive commit messages
- Include screenshots for UI changes
- Reference related issues
- Be responsive to feedback

## 🐛 Issue Guidelines

### Before Creating an Issue

1. **Search existing issues** to avoid duplicates
2. **Try the latest version** of the examples
3. **Check documentation** for known solutions
4. **Prepare reproduction steps**

### Issue Templates

#### Bug Report

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- OS: [e.g. iOS 15, Android 12]
- Flutter version: [e.g. 3.4.0]
- Obsly SDK version: [e.g. 0.2.0]
- Device: [e.g. iPhone 12, Pixel 6]

**Additional context**
Any other context about the problem.
```

#### Feature Request

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Additional context**
Any other context or screenshots about the feature request.
```

### Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to docs
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `question` - Further information requested

## 🏆 Recognition

Contributors will be recognized through:

- **GitHub contributors list**
- **Changelog mentions** for significant contributions
- **Special thanks** in release notes
- **Contributor badges** for regular contributors

## 📞 Getting Help

Need help contributing?

- 💬 **Discord**: [Join our community](https://discord.gg/obsly)
- 📧 **Email**: contributors@obsly.com
- 🐛 **Issues**: Create a GitHub issue with the `question` label
- 📖 **Docs**: Check our comprehensive documentation

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Obsly Flutter Examples! 🚀**

Every contribution, no matter how small, helps make Flutter development better for everyone.
