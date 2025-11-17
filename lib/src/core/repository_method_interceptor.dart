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

import 'dart:async';

import 'package:jetleaf_core/context.dart';
import 'package:jetleaf_core/intercept.dart';
import 'package:jetleaf_lang/lang.dart';

import '../../annotation.dart';
import '../event/repository_event.dart';
import 'repository_definition.dart';

/// {@template jetleaf_repository_method_interceptor}
/// A **method interceptor** for repository classes annotated with [Repository].
///
/// This interceptor allows you to hook into repository method executions,
/// emitting events and performing pre-invocation logic. It combines both
/// [MethodInterceptor] and [MethodBeforeInterceptor] functionality.
///
/// ### Features
/// - Intercepts methods on classes annotated with [Repository].
/// - Emits [InterceptedRepositoryMethodEvent] via the application event bus
///   before method execution.
/// - Provides hooks to retrieve repository method definitions ([RepositoryDefinition])
///   and the [ApplicationEventBus].
///
/// ### Usage Example
/// ```dart
/// class LoggingInterceptor extends RepositoryMethodInterceptor {
///   @override
///   RepositoryDefinition? getDefinition(Method method) {
///     // Return the repository definition for the method
///     return RepositoryDefinitionRegistry.get(method);
///   }
///
///   @override
///   ApplicationEventBus getEventBus() => MyApp.eventBus;
/// }
/// ```
///
/// ### Design Notes
/// - Uses reflection to detect repository methods (`@Repository` annotated classes).
/// - `beforeInvocation` is asynchronous and triggers an event for external
///   listeners or logging mechanisms.
/// - `getDefinition` and `getEventBus` must be implemented by concrete
///   subclasses to provide actual repository metadata and event bus.
///
/// ### See Also
/// - [MethodInterceptor]
/// - [MethodBeforeInterceptor]
/// - [Repository]
/// - [RepositoryDefinition]
/// - [InterceptedRepositoryMethodEvent]
/// {@endtemplate}
abstract class RepositoryMethodInterceptor implements MethodInterceptor, MethodBeforeInterceptor {
  /// Determines if the given [method] can be intercepted.
  ///
  /// Returns `true` if the declaring class of the method is annotated with [Repository].
  @override
  bool canIntercept(Method method) => method.getDeclaringClass().hasDirectAnnotation<Repository>();

  @override
  FutureOr<void> beforeInvocation<T>(MethodInvocation<T> invocation) async {
    final definition = getDefinition(invocation.getMethod());
    if (definition == null) {
      return; // No definition found for the method.
    }

    final eventBus = getEventBus();
    await eventBus.onEvent(InterceptedRepositoryMethodEvent(definition, invocation));
  }

  /// Returns the repository-method definition associated with the given [method].
  ///
  /// This provides metadata describing how the repository method is configured,
  /// including details such as:
  /// - Derived or explicitly declared query information  
  /// - Method semantics (e.g., modifying, deleting, selecting, exists-check)  
  /// - Parameter mappings  
  /// - Return-type rules  
  ///
  /// Subclasses must implement this to supply repository-specific metadata used
  /// by interceptors, execution engines, and query builders.
  ///
  /// ### Returns
  /// - A [RepositoryDefinition] describing how the method should be executed,
  ///   or `null` if no definition exists.
  ///
  /// ### Use Cases
  /// - Resolving repository query strategies  
  /// - Determining execution paths (sync, async, modifying, paging, etc.)  
  /// - Supporting method-level annotations that affect behavior
  RepositoryDefinition? getDefinition(Method method);


  /// Returns the application's event bus used to publish repository-related events.
  ///
  /// Subclasses must implement this to supply the event bus instance responsible
  /// for propagating lifecycle and data-access events such as:
  /// - Entity creation, update, and deletion  
  /// - Query execution events  
  /// - Transactional or retry-related notifications  
  ///
  /// ### Purpose
  /// - Enables integration with application-level observability, auditing,
  ///   caching, domain event dispatching, and asynchronous listeners.
  ///
  /// ### Notes
  /// - The returned [ApplicationEventBus] must be stable for the lifespan of
  ///   the repository infrastructure.
  /// - Implementations are free to use synchronous or asynchronous event
  ///   dispatching models as appropriate for the application architecture.
  ApplicationEventBus getEventBus();
}