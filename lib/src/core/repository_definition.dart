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

import 'package:jetleaf_lang/lang.dart';

/// {@template jetleaf_repository_definition_type}
/// Represents the different **repository implementation categories** used
/// in Jetleaf's repository architecture.
///
/// These types classify how a repository method is expected to behave,
/// which executor logic to apply, and how the framework should interpret
/// the method during interception, analysis, or code generation.
///
/// ### Types
/// - **CUSTOM** – A user-defined method that does not map to any built-in
///   repository behavior. Typical for methods annotated with custom
///   `@Query` definitions.
/// - **BASE** – A simple repository method that does not involve CRUD or
///   pageable semantics.
/// - **CRUD** – Matches CRUD-style repository methods such as `findById`,
///   `save`, or `delete`.
/// - **LIST_CRUD** – CRUD repository behavior with list-based return
///   semantics (e.g., returning `List<T>`).
/// - **PAGEABLE** – Repository methods supporting sorting or pagination.
/// - **LIST_PAGEABLE** – Pageable behavior but explicitly returning lists.
///
/// ### Usage Example
/// ```dart
/// if (definition.getType() == RepositoryType.CRUD) {
///   // Use CRUD executor
/// }
/// ```
///
/// ### See Also
/// - [RepositoryDefinition]
/// - [Method]
/// {@endtemplate}
enum RepositoryType {
  /// A user-defined method that does not map to any built-in
  /// repository behavior. Typical for methods annotated with custom
  /// `@Query` definitions.
  CUSTOM,

  /// A simple repository method that does not involve CRUD or pageable semantics.
  BASE,

  /// Matches CRUD-style repository methods such as `findById`, `save`, or `delete`.
  CRUD,

  /// CRUD repository behavior with list-based return semantics (e.g., returning `List<T>`).
  LIST_CRUD,

  /// Repository methods supporting sorting or pagination.
  PAGEABLE,

  /// Pageable behavior but explicitly returning lists.
  LIST_PAGEABLE
}

/// {@template jetleaf_repository_definition}
/// Defines the metadata and characteristics of a repository method.
///
/// A [RepositoryDefinition] describes:
/// - The reflected method being intercepted
/// - The repository category ([RepositoryType])
/// - Whether the method is considered *internal* (used internally by the
///   repository framework and not executed via user-level dispatch)
///
/// This definition is used by interceptors such as
/// [RepositoryMethodInterceptor] to determine how repository methods should
/// be executed or handled.
///
/// ### Usage Example
/// ```dart
/// class MyRepositoryDefinition implements RepositoryDefinition {
///   final Method method;
///
///   MyRepositoryDefinition(this.method);
///
///   @override
///   Method getMethod() => method;
///
///   @override
///   RepositoryType getType() => RepositoryType.CUSTOM;
/// }
/// ```
///
/// ### Design Notes
/// - Extends [EqualsAndHashCode] to allow equality comparison based on
///   method metadata.
/// - Every definition must supply the underlying reflection [Method].
/// - `isInternalMethod` can be overridden to flag methods that should not be
///   intercepted or processed by repository executors.
///
/// ### See Also
/// - [RepositoryType]
/// - [RepositoryMethodInterceptor]
/// - [Method]
/// {@endtemplate}
abstract class RepositoryDefinition with EqualsAndHashCode {
  /// Returns the reflected repository [Method] this definition applies to.
  Method getMethod();

  /// Returns the type classification of this repository method.
  ///
  /// Used by repository interceptors and executors to determine execution
  /// semantics.
  RepositoryType getType();

  /// Indicates whether this method is an internal framework method.
  ///
  /// Defaults to `false`. Override this to mark methods that should not be
  /// intercepted or handled as public repository operations.
  bool isInternalMethod() => false;
}