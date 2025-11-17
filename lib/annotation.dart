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

library;

import 'package:jetleaf_lang/lang.dart';
import 'package:meta/meta_meta.dart';

import 'src/repository/crud_repository.dart';
import 'src/repository/repository_executor.dart';

/// {@template jetleaf_repository_annotation}
/// Marks a class as a **repository** for use with generic repository
/// patterns, reflection, and code generation.
///
/// This annotation is intended to be applied to classes that serve as
/// repositories for entities, typically extending [Repository],
/// [CrudRepository], or their specialized variants.
///
/// ### Usage Example
/// ```dart
/// @Repository()
/// class UserRepository extends CrudRepository<User, String> {}
/// ```
///
/// ### Design Notes
/// - Used with reflection via `reflectable` for runtime or code-generation
///   operations.
/// - Can be combined with `@Generic` for generic repository types.
/// - The annotation itself does not implement any repository behavior; it
///   simply marks classes for tooling and runtime inspection.
///
/// ### See Also
/// - [ReflectableAnnotation]
/// - [CrudRepository]
/// - [RepositoryExecutor]
/// {@endtemplate}
@Target({TargetKind.classType})
class Repository extends ReflectableAnnotation {
  /// {@macro jetleaf_repository_annotation}
  const Repository();

  @override
  Type get annotationType => Repository;
}