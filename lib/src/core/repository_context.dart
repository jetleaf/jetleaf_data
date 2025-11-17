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

import 'package:jetleaf_core/core.dart';
import 'package:jetleaf_lang/lang.dart';

import '../repository/repository_executor.dart';
import 'repository_definition.dart';

/// {@template jetleaf_repository_context}
/// A context interface for managing [Repository] definitions and providing
/// an [Executor][RepositoryExecutor] for repository operations.
///
/// Implementations are responsible for:
/// - Storing and retrieving [RepositoryDefinition] instances
/// - Providing a consistent [RepositoryExecutor] for executing repository logic
/// - Integrating with the [ApplicationEventBus] to support event-driven workflows
///
/// ### Usage Example
/// ```dart
/// RepositoryContext context = MyRepositoryContext();
/// final definition = context.getDefinition(MyRepository.myMethod);
/// final executor = context.getExecutor();
/// ```
///
/// ### Design Notes
/// - Abstract interface, enabling multiple implementations (e.g., in-memory, database-backed).
/// - Designed to decouple repository definitions and executor management from business logic.
/// - Supports integration with Jetleaf’s event-driven architecture.
///
/// ### See Also
/// - [RepositoryDefinition]
/// - [RepositoryExecutor]
/// - [ApplicationEventBusAware]
/// {@endtemplate}
abstract interface class RepositoryContext implements ApplicationEventBusAware {
  /// A typed reference to the [RepositoryContext] class.
  ///
  /// Used by the dependency injection container to locate and inject
  /// `RepositoryContext` implementations. This enables framework components
  /// to request a RepositoryContext without depending on a concrete class.
  static Class<RepositoryContext> CLASS = Class<RepositoryContext>();

  /// Retrieves the registered [RepositoryDefinition] associated with the
  /// specified repository [method].
  ///
  /// A [RepositoryDefinition] contains metadata and execution rules for a
  /// repository method, such as:
  /// - Method-to-query mapping
  /// - Return type behavior
  /// - Result processing rules
  /// - Query parameters and binding information
  ///
  /// Returns `null` if the method is not part of any registered repository
  /// definition.
  ///
  /// This lookup is typically used by interceptors, executors, or method
  /// dispatchers during repository method invocation.
  RepositoryDefinition? getDefinition(Method method);

  /// Returns the configured [RepositoryExecutor] responsible for executing
  /// repository operations.
  ///
  /// The executor performs the actual work of:
  /// - Dispatching repository method calls
  /// - Managing query execution
  /// - Translating results into repository return types
  /// - Coordinating paging, sorting, and projections
  ///
  /// Implementations should guarantee that an executor is available once the
  /// context has fully initialized. If no executor has been configured, this
  /// method should throw an appropriate exception.
  RepositoryExecutor getExecutor();
}

/// {@template jetleaf_configurable_repository_context}
/// A configurable variant of [RepositoryContext] that allows dynamic
/// registration of [RepositoryDefinition]s and setting of the [RepositoryExecutor].
///
/// ### Usage Example
/// ```dart
/// final context = MyConfigurableRepositoryContext();
/// context.setExecutor(myExecutor);
/// context.addDefinition(myRepositoryDefinition);
/// ```
///
/// ### Design Notes
/// - Extends [RepositoryContext] for runtime configurability.
/// - Enables adding or updating repository definitions dynamically.
/// - Supports changing the executor at runtime if necessary.
///
/// ### See Also
/// - [RepositoryContext]
/// - [RepositoryDefinition]
/// - [RepositoryExecutor]
/// {@endtemplate}
abstract interface class ConfigurableRepositoryContext implements RepositoryContext {
  /// Adds a new [RepositoryDefinition] to the context.
  void addDefinition(RepositoryDefinition definition);

  /// Sets the [RepositoryExecutor] for this context.
  void setExecutor(RepositoryExecutor executor);
}