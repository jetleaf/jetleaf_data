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
import 'package:jetleaf_core/core.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:jetleaf_logging/logging.dart';
import 'package:jetleaf_pod/pod.dart';

import '../../annotation.dart';
import '../repository/repository_executor.dart';
import 'abstract_repository_context.dart';

/// {@template jetleaf_default_repository_context}
/// The default runtime implementation of [RepositoryContext], responsible for
/// **discovering repository classes**, **building repository method definitions**,
/// and **providing the active [RepositoryExecutor]** for repository operations.
///
/// This implementation integrates deeply with the Jetleaf application runtime:
///
/// - Implements [ApplicationContextAware] to access pods, definitions, metadata,
///   and annotations.
/// - Implements [InitializingPod] to perform discovery after the application
///   context is ready.
/// - Automatically detects pods annotated with `@Repository` and registers
///   method-level [RepositoryDefinition]s.
/// - Lazily resolves a [RepositoryExecutor] from the application context.
///
/// ### Automatic Repository Discovery
/// On initialization, this context:
/// 1. Scans all pod definitions in the [ApplicationContext].  
/// 2. Identifies classes directly annotated with `@Repository`.  
/// 3. Retrieves their instances.  
/// 4. Creates and registers a [RepositoryDefinition] for each method.  
///
/// This provides full runtime repository support without requiring
/// explicit configuration.
///
/// ### Usage Example
/// ```dart
/// final context = DefaultRepositoryContext();
///
/// // Application framework injects context + event bus
/// context.setApplicationContext(appContext);
/// context.setApplicationEventBus(eventBus);
///
/// await context.onReady(); // Discovers repositories and definitions
///
/// final executor = context.getExecutor();
/// final definition = context.getDefinition(myMethod);
/// ```
///
/// ### Design Notes
/// - Falls back to explicit configuration if no [RepositoryExecutor] is found;
///   calling [getExecutor] without an executor throws an [IllegalStateException].
/// - Logs discovery steps when debug logging is enabled.
/// - Treats repository discovery as dynamic and annotation-driven.
/// - Uses [AbstractRepositoryContext] as the base for definition storage.
///
/// ### Example Behavior
/// | Situation | Behavior |
/// |-----------|----------|
/// | RepositoryExecutor exists in context | Executor assigned during `onReady()` |
/// | No RepositoryExecutor | `getExecutor()` throws `IllegalStateException` |
/// | Pod annotated with `@Repository` | All methods registered as repository operations |
///
/// ### See Also
/// - [RepositoryContext]
/// - [AbstractRepositoryContext]
/// - [RepositoryExecutor]
/// - [ApplicationContext]
/// - [InitializingPod]
/// - [Repository]
/// {@endtemplate}
final class DefaultRepositoryContext extends AbstractRepositoryContext implements ApplicationContextAware, InitializingPod {
  /// The application-wide event bus used for publishing and listening to
  /// repository-related events.
  ///
  /// This bus enables the repository subsystem to emit lifecycle events such as:
  /// - Repository method invoked
  /// - Query executed
  /// - Result returned
  /// - Errors or retries
  ///
  /// It is injected by the application context during initialization.
  late ApplicationEventBus _eventBus;

  /// The owning [ApplicationContext] that manages pods, lifecycle callbacks,
  /// dependency resolution, and configuration.
  ///
  /// The repository context uses this to:
  /// - Look up the `RepositoryExecutor`
  /// - Access other infrastructure components
  /// - Discover repository-annotated beans during initialization
  late ApplicationContext _applicationContext;

  /// The executor responsible for performing actual repository operations.
  ///
  /// This may be:
  /// - Automatically discovered from the application context
  /// - Manually provided through configuration
  ///
  /// It is optional until initialization; callers of [getExecutor] must ensure
  /// it is set, otherwise an exception will be thrown.
  RepositoryExecutor? _executor;

  /// Logger instance used for emitting diagnostic and lifecycle information
  /// related to repository context initialization, execution, and event handling.
  ///
  /// The logger is namespaced as `"repositoryContext"` to make filtering and
  /// analysis easier in log aggregation tools.
  final Log _logger = LogFactory.getLog("repositoryContext");

  /// {@macro jetleaf_default_repository_context}
  DefaultRepositoryContext();

  @override
  String getPackageName() => PackageNames.DATA;

  @override
  List<Object?> equalizedProperties() => [_executor, runtimeType];

  @override
  ApplicationEventBus getEventBus() => _eventBus;

  @override
  RepositoryExecutor getExecutor() {
    final executor = _executor;

    if (executor == null) {
      throw IllegalStateException(
        "No RepositoryExecutor available. You must provide a RepositoryExecutor "
        "via the application context before accessing it."
      );
    }

    return executor;
  }

  @override
  Future<void> onReady() async {
    if (await _applicationContext.containsType(RepositoryExecutor.CLASS)) {
      _executor = await _applicationContext.get(RepositoryExecutor.CLASS);
    }

    await _discoverAndBuildDefinition();
  }

  /// Scans the application context for pods annotated as [Repository] and
  /// builds their corresponding repository method definitions.
  ///
  /// This method performs the following steps:
  /// 1. Retrieves all pod names from the [_applicationContext].
  /// 2. Iterates over each pod:
  ///    - Obtains its class type and instance.
  ///    - Checks if the class has a direct [Repository] annotation.
  ///    - For each method in the annotated class, generates a repository
  ///      method definition using [buildDefinition] and registers it via
  ///      [addDefinition].
  ///
  /// ### Notes
  /// - Only classes directly annotated with [Repository] are processed.
  /// - This method dynamically inspects all methods of eligible repository
  ///   classes, allowing runtime discovery and registration of repository
  ///   operations.
  /// - It relies on the application context to provide pod instances and
  ///   metadata.
  Future<void> _discoverAndBuildDefinition() async {
    final names = _applicationContext.getDefinitionNames();
    for (final name in names) {
      final definition = _applicationContext.getDefinition(name);
      final cls = definition.type;

      if (cls.hasDirectAnnotation<Repository>()) {
        if (_logger.getIsTraceEnabled()) {
          _logger.trace("Found a repository annotated class ${cls.getQualifiedName()}");
        }

        final target = await _applicationContext.getPod(name);

        for (final method in cls.getMethods()) {
          if (MethodUtils.getDefaultMethodNames().contains(method.getName())) {
            continue;
          }

          if (target is EqualsAndHashCode && ["equalizedProperties"].contains(method.getName())) {
            continue;
          }

          if (target is ToString && ["toStringOptions"].contains(method.getName())) {
            continue;
          }

          addDefinition(buildDefinition(method, target));

          if (_logger.getIsTraceEnabled()) {
            _logger.trace("Added RepositoryDefinition for ${method.getName()} in ${cls.getQualifiedName()}");
          }
        }
      }
    }
  }

  @override
  void setApplicationContext(ApplicationContext applicationContext) {
    _applicationContext = applicationContext;
  }

  @override
  void setApplicationEventBus(ApplicationEventBus applicationEventBus) {
    _eventBus = applicationEventBus;
  }

  @override
  void setExecutor(RepositoryExecutor executor) {
    _executor = executor;
  }
}