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

import 'crud_repository.dart';
import 'repository_executor.dart';

/// {@template jetleaf_list_crud_repository}
/// A generic **list-based CRUD repository** extending [CrudRepository],
/// ensuring that all multi-entity operations return [List] instead of
/// general [Iterable].
///
/// This is useful when you require concrete list semantics for operations
/// like `findAll`, `findAllById`, and `saveAll`. All other CRUD operations
/// are inherited from [CrudRepository].
///
/// ### Features
/// - Ensures all multi-entity operations return [List].
/// - Retains all single-entity CRUD operations from [CrudRepository].
/// - Delegates execution to the underlying [RepositoryExecutor].
///
/// ### Usage Example
/// ```dart
/// class UserRepository extends ListCrudRepository<User, String> {}
///
/// final repo = UserRepository();
/// final users = await repo.findAll(); // returns List<User>
/// await repo.saveAll([user1, user2]); // returns List<User>
/// ```
///
/// ### Design Notes
/// - Overrides `findAll`, `findAllById`, and `saveAll` to convert results
///   to [List] for consistent list semantics.
/// - Single-entity operations (findById, save, delete, etc.) remain unchanged.
/// - Uses asynchronous execution through [RepositoryExecutor].
///
/// ### See Also
/// - [CrudRepository]
/// - [RepositoryExecutor]
/// {@endtemplate}
@Generic(ListCrudRepository)
abstract class ListCrudRepository<T, ID> extends CrudRepository<T, ID> {
  /// The reflective [Class] handle representing the `ListCrudRepository` interface.
  ///
  /// This class reference allows the framework to:
  /// - Inspect list-based CRUD repository features
  /// - Support type resolution for repositories returning `List<T>`
  /// - Participate in method lookup during interception
  ///
  /// The class belongs to the package defined by [PackageNames.DATA].
  static final Class<ListCrudRepository> CLASS = Class<ListCrudRepository>(null, PackageNames.DATA);

  /// Retrieves all entities as a [List] instead of a generic [Iterable].
  ///
  /// Overrides [CrudRepository.findAll] to convert the result to [List].
  ///
  /// ### Example
  /// ```dart
  /// final users = await repository.findAll(); // List<User>
  /// ```
  @override
  Future<List<T>> findAll() async => List.from(await super.findAll());

  /// Retrieves all entities matching the given [ids] as a [List].
  ///
  /// Overrides [CrudRepository.findAllById] to convert the result to [List].
  ///
  /// ### Example
  /// ```dart
  /// final users = await repository.findAllById(["123", "456"]); // List<User>
  /// ```
  @override
  Future<List<T>> findAllById(Iterable<ID> ids) async => List.from(await super.findAllById(ids));

  /// Saves multiple [entities] and returns the result as a [List].
  ///
  /// Overrides [CrudRepository.saveAll] to convert the result to [List].
  ///
  /// ### Example
  /// ```dart
  /// final savedUsers = await repository.saveAll([user1, user2]); // List<User>
  /// ```
  @override
  Future<List<S>> saveAll<S extends T>(Iterable<S> entities) async => List.from(await super.saveAll(entities));
}