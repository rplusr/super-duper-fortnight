import 'package:flutter/material.dart';

import '../services/error_handler.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails error, VoidCallback retry)? errorBuilder;
  final void Function(dynamic error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    // Set up Flutter error handler
    FlutterError.onError = (details) {
      ErrorHandler.logError(details.exception, details.stack);
      widget.onError?.call(details.exception, details.stack ?? StackTrace.empty);
      setState(() => _error = details);
    };
  }

  void _retry() {
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }
      return _DefaultErrorWidget(
        error: _error!,
        onRetry: _retry,
      );
    }

    return widget.child;
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We encountered an unexpected error. Please try again.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A generic error view for async operations
class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryLabel;

  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon,
    this.retryLabel,
  });

  factory ErrorView.network({VoidCallback? onRetry}) {
    return ErrorView(
      message: 'No internet connection.\nPlease check your network and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }

  factory ErrorView.server({VoidCallback? onRetry}) {
    return ErrorView(
      message: 'Server error.\nPlease try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      retryLabel: 'Retry',
    );
  }

  factory ErrorView.fromException(AppException exception, {VoidCallback? onRetry}) {
    IconData icon;
    switch (exception.type) {
      case ErrorType.network:
      case ErrorType.timeout:
        icon = Icons.wifi_off;
        break;
      case ErrorType.server:
        icon = Icons.cloud_off;
        break;
      case ErrorType.authentication:
        icon = Icons.lock_outline;
        break;
      default:
        icon = Icons.error_outline;
    }

    return ErrorView(
      message: exception.message,
      icon: icon,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Something went wrong',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget to show offline indicator
class OfflineIndicator extends StatelessWidget {
  final bool isOffline;
  final Widget child;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOffline ? 32 : 0,
          color: Theme.of(context).colorScheme.errorContainer,
          child: isOffline
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 16,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : null,
        ),
        Expanded(child: child),
      ],
    );
  }
}
