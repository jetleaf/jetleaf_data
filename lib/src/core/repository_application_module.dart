// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_core/context.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:jetleaf_logging/logging.dart';
import 'package:jetleaf_pod/pod.dart';

import '../../repository.dart';
import 'repository_context.dart';
import 'repository_context_aware.dart';

/// {@template jetleaf_repository_application_module}
/// An application module that **registers repository-related infrastructure**
/// into the Jetleaf runtime by adding a [RepositoryAwareProcessor] to the
/// [ApplicationContext].
///
/// This module enables automatic wiring of:
/// - [Repository] instances (injects `executor`)
/// - [RepositoryContextAware] instances (injects `RepositoryContext`)
///
/// When included in an application’s module list, it ensures that all repository
/// components receive the correct dependencies during pod initialization.
///
/// ### Usage Example
/// ```dart
/// final app = Application(
///   modules: [
///     const RepositoryApplicationModule(),
///   ],
/// );
///
/// // Application startup will automatically register RepositoryAwareProcessor
/// await app.run();
/// ```
///
/// ### Design Notes
/// - Lightweight and stateless; safe to construct as a constant.
/// - Integrates seamlessly with Jetleaf's auto-configuration pipeline.
/// - Delegates all wiring work to [RepositoryAwareProcessor].
/// - `equalizedProperties` ensures correct module equality behavior.
///
/// ### Example Behavior
/// | Action | Result |
/// |--------|---------|
/// | Module loaded | RepositoryAwareProcessor added to context |
/// | RepositoryContext absent | Processor becomes inactive |
/// | RepositoryContext present | Repositories and aware pods are injected |
///
/// ### See Also
/// - [RepositoryAwareProcessor]
/// - [ApplicationModule]
/// - [ApplicationContext]
/// - [Repository]
/// - [RepositoryContextAware]
/// {@endtemplate}
final class RepositoryApplicationModule implements ApplicationModule {
  /// {@macro jetleaf_repository_application_module}
  const RepositoryApplicationModule();

  @override
  Future<void> configure(ApplicationContext context) async {
    context.addPodProcessor(RepositoryAwareProcessor(context));
  }

  @override
  List<Object?> equalizedProperties() => [RepositoryApplicationModule];
}

/// {@template jetleaf_repository_aware_processor}
/// A [PodInitializationProcessor] that **automatically wires repository-related
/// infrastructure** into pods during the initialization phase.
///
/// This processor integrates with the [ApplicationContext] to:
/// - Inject a [RepositoryExecutor] into all [Repository] pods
/// - Inject a [RepositoryContext] into all [RepositoryContextAware] pods
///
/// It only becomes active when a [RepositoryContext] is present in the
/// application context, ensuring graceful behavior in applications that
/// do not use the repository subsystem.
///
/// ### Activation Logic
/// This processor runs *only if* the application context contains a pod of type
/// [RepositoryContext].  
/// This makes it safe in modular applications or layered systems where the data
/// module may or may not be present.
///
/// ### Usage Example
/// ```dart
/// final processor = RepositoryAwareProcessor(appContext);
///
/// final repo = MyRepository();
/// final processed = await processor.processBeforeInitialization(
///   repo,
///   MyRepository.CLASS,
///   "myRepository",
/// );
///
/// // Repository automatically receives executor
/// print(repo.executor); // Executor from RepositoryContext
///
/// final aware = MyContextAwareComponent();
/// final processed2 = await processor.processBeforeInitialization(
///   aware,
///   MyContextAwareComponent.CLASS,
///   "aware",
/// );
///
/// // Context-aware components also receive RepositoryContext
/// print(aware.context); // RepositoryContext
/// ```
///
/// ### Design Notes
/// - Uses [PriorityOrdered] with `order = 1` to ensure early execution.
/// - Supports two categories of pods:
///   - **[Repository]**: receives an executor
///   - **[RepositoryContextAware]**: receives the repository context directly
/// - Leverages [ApplicationContext] lookups to remain environment-aware.
/// - Avoids unnecessary work when the repository system is not configured.
///
/// ### Example Behavior
/// | Pod Type | Executor Injected | Context Injected | Condition |
/// |----------|------------------|------------------|-----------|
/// | [Repository] | ✅ Yes | ❌ No | RepositoryContext exists |
/// | [RepositoryContextAware] | ❌ No | ✅ Yes | RepositoryContext exists |
/// | Any Other Pod | ❌ No | ❌ No | Processor passes through unchanged |
///
/// ### See Also
/// - [Repository]
/// - [RepositoryContext]
/// - [RepositoryContextAware]
/// - [ApplicationContext]
/// - [PodInitializationProcessor]
/// {@endtemplate}
final class RepositoryAwareProcessor extends PodInitializationProcessor implements PriorityOrdered {
  /// The application context used to resolve and retrieve the active
  /// [RepositoryContext].
  ///
  /// This is the central container responsible for dependency resolution,
  /// pod management, and lifecycle coordination. It is used to look up the
  /// repository context when needed.
  final ApplicationContext _context;

  /// Cached instance of the resolved [RepositoryContext].
  ///
  /// This value is populated lazily on first access via `_getContext()` and
  /// reused for all subsequent operations. If `null`, the context has not yet
  /// been resolved.
  RepositoryContext? _repositoryContext;

  /// Logger used for emitting diagnostic information related to repository
  /// context processing.
  ///
  /// Logs events such as context discovery, injection behavior, and error
  /// conditions. The logger is namespaced to the [RepositoryAwareProcessor]
  /// class for clarity.
  final Log _logger = LogFactory.getLog(RepositoryAwareProcessor);

  /// {@macro jetleaf_repository_aware_processor}
  RepositoryAwareProcessor(this._context);

  @override
  int getOrder() => 1;

  @override
  Future<bool> shouldProcessBeforeInitialization(Object pod, Class podClass, String name) async {
    return await _context.containsType(RepositoryContext.CLASS) && (pod is Repository || pod is RepositoryContextAware);
  }

  @override
  Future<Object?> processBeforeInitialization(Object pod, Class podClass, String name) async {
    final instance = pod;

    if (instance is Repository) {
      final repositoryContext = await _getContext();
      instance.executor = repositoryContext.getExecutor();
    }

    if (instance is RepositoryContextAware) {
      final repositoryContext = await _getContext();
      instance.setRepositoryContext(repositoryContext);
    }

    return instance;
  }

  /// Resolves and returns the active [RepositoryContext] instance.
  ///
  /// This method first checks whether a local context has already been cached
  /// in `_repositoryContext`. If so, it returns that instance immediately.
  ///
  /// If no cached instance exists, the method retrieves the `RepositoryContext`
  /// from the underlying [ApplicationContext] using the registered
  /// [RepositoryContext.CLASS] type token. The resolved instance is then cached
  /// for all subsequent calls.
  ///
  /// ### Behavior
  /// - Lazy-initializes the repository context.
  /// - Ensures the lookup happens only once.
  /// - Guarantees a non-null `RepositoryContext` on successful return.
  ///
  /// ### Returns
  /// A [Future] that completes with the resolved and cached [RepositoryContext].
  ///
  /// ### Throws
  /// Any exception thrown by the underlying application context during
  /// dependency lookup.
  ///
  /// ### Example
  /// ```dart
  /// final context = await _getContext();
  /// final executor = context.getExecutor();
  /// ```
  Future<RepositoryContext> _getContext() async {
    RepositoryContext repositoryContext;
    if (_repositoryContext != null) {
      repositoryContext = _repositoryContext!;
    } else {
      repositoryContext = await _context.get(RepositoryContext.CLASS);
    }

    if (_logger.getIsDebugEnabled()) {
      _logger.trace("Provided $repositoryContext for repository execution");
    }

    return _repositoryContext = repositoryContext;
  }
}