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
import 'package:jetleaf_core/intercept.dart';
import 'package:jetleaf_lang/lang.dart';

import '../core/repository_definition.dart';

/// {@template jetleaf_repository_event}
/// Base event class for **repository-related application events**.
///
/// All repository events extend [RepositoryEvent] and are associated with a
/// [RepositoryDefinition] as the source.
///
/// ### Usage Example
/// ```dart
/// final event = RepositoryEvent(myRepositoryDefinition);
/// print(event.getSource()); // RepositoryDefinition instance
/// print(event.getPackageName()); // "data"
/// ```
///
/// ### Design Notes
/// - Extends [ApplicationEvent] to integrate with Jetleaf’s event system.
/// - Associates events with repository definitions for context-aware handling.
/// - Overrides `getPackageName()` to return [PackageNames.DATA].
///
/// ### See Also
/// - [ApplicationEvent]
/// - [RepositoryDefinition]
/// - [PackageNames]
/// {@endtemplate}
abstract class RepositoryEvent extends ApplicationEvent {
  /// {@macro jetleaf_repository_event}
  const RepositoryEvent(RepositoryDefinition super.source, super.timestamp);

  @override
  String getPackageName() => PackageNames.DATA;
}

/// {@template jetleaf_intercepted_repository_method_event}
/// Event triggered when a **repository method is intercepted** by Jetleaf’s
/// method interception system.
///
/// Encapsulates a [MethodInvocation] to provide access to the intercepted call.
///
/// ### Usage Example
/// ```dart
/// final event = InterceptedRepositoryMethodEvent(myRepoDef, invocation);
/// final invocation = event.getInvocation();
/// final result = invocation.proceed();
/// ```
///
/// ### Design Notes
/// - Extends [RepositoryEvent] to retain repository context.
/// - Provides direct access to [MethodInvocation] for pre- or post-processing.
/// - Useful for logging, auditing, or dynamic behavior injection in repository methods.
///
/// ### Example Behavior
/// | Event Type | Invocation Access |
/// |------------|-----------------|
/// | InterceptedRepositoryMethodEvent | ✅ Provides [MethodInvocation] for method execution |
///
/// ### See Also
/// - [RepositoryEvent]
/// - [MethodInvocation]
/// - [RepositoryDefinition]
/// {@endtemplate}
@Generic(InterceptedRepositoryMethodEvent)
final class InterceptedRepositoryMethodEvent<T> extends RepositoryEvent {
  /// The intercepted method invocation.
  final MethodInvocation<T> _invocation;

  /// {@macro jetleaf_intercepted_repository_method_event}
  const InterceptedRepositoryMethodEvent(super.source, this._invocation, super.timestamp);

  /// Returns the [MethodInvocation] associated with this intercepted event.
  MethodInvocation<T> getInvocation() => _invocation;
}