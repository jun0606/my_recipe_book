---
description: Agent OS integration for consistent development standards and workflows
alwaysApply: true
---

# Agent OS Integration

This project uses Agent OS for structured, spec-driven development. All AI agents should follow these established patterns and standards.

## Core Standards Integration

- **Tech Stack**: Reference [tech-stack.md](.agent-os/product/tech-stack.md) for project-specific technology decisions
- **Code Style**: Follow [code-style.md](.agent-os/standards/code-style.md) for consistent formatting and conventions
- **Best Practices**: Implement patterns from [best-practices.md](.agent-os/standards/best-practices.md)

## Flutter/Dart Specific Guidelines

- **Dart Style**: Follow [dart-style.md](.agent-os/standards/code-style/dart-style.md) for language-specific conventions
- **Flutter Patterns**: Implement [flutter-style.md](.agent-os/standards/code-style/flutter-style.md) for widget and UI best practices

## Development Workflow

### Before Starting Any Task
1. Review relevant standards from `.agent-os/standards/`
2. Check project-specific tech stack in `.agent-os/product/tech-stack.md`
3. Ensure code follows established patterns

### During Implementation
- Apply consistent naming conventions (camelCase for variables, PascalCase for classes)
- Use Provider pattern for state management
- Follow Flutter widget best practices
- Implement proper error handling

### Code Quality Checks
- Use const constructors where possible
- Implement proper disposal of resources
- Follow null safety guidelines
- Add meaningful comments for complex logic

## Architecture Patterns

### File Organization
```
lib/
├── models/          # Data models (PascalCase classes)
├── providers/       # State management (Provider pattern)
├── screens/         # Full-screen widgets
├── services/        # Business logic
├── utils/           # Helper functions
└── widgets/         # Reusable components
    ├── common/      # Shared widgets
    └── feature/     # Feature-specific widgets
```

### State Management
- Use Provider pattern consistently
- Keep providers focused on single responsibilities
- Implement proper ChangeNotifier usage
- Handle async operations with proper error handling

### Error Handling Strategy
- Use custom exception classes for domain errors
- Provide meaningful user feedback
- Log errors for debugging
- Implement graceful degradation

## Quality Standards

### Performance
- Use ListView.builder for large lists
- Implement proper widget keys
- Optimize with const constructors
- Monitor memory usage

### Accessibility
- Provide semantic labels
- Ensure color contrast compliance
- Support keyboard navigation
- Test with accessibility tools

### Testing
- Write unit tests for business logic
- Create widget tests for UI components
- Mock external dependencies
- Use descriptive test names

## Integration with Existing Tools

This Agent OS setup works alongside:
- **Taskmaster**: For task management and workflow
- **MCP Servers**: For enhanced development capabilities
- **Kiro Steering**: For project-specific guidance

## Consistency Enforcement

All code changes should:
1. Follow the established patterns in `.agent-os/standards/`
2. Maintain consistency with existing codebase
3. Include proper documentation
4. Pass quality checks before submission

## References

- [Agent OS Documentation](https://buildermethods.com/agent-os)
- [Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)