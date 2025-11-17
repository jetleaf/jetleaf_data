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

import 'src/repository/crud_repository.dart';
import 'src/repository/repository_executor.dart';

/// {@template jetleaf_repository}
/// A generic **repository interface** providing basic query and type
/// information for entities of type [T] identified by [ID].
///
/// This abstract class is meant to be extended by concrete repositories,
/// such as `CrudRepository`, to provide additional query methods and
/// persistence operations. Queries are delegated to an optional
/// [RepositoryExecutor], which can be used to implement database- or
/// memory-backed operations.
///
/// ### Features
/// - Delegates query execution to a [RepositoryExecutor].
/// - Supports multiple query result types: single entity, `Iterable`, `List`, `Set`.
/// - Provides type metadata for [T] and [ID].
///
/// ### Usage Example
/// ```dart
/// @Repository()
/// class UserRepository extends Repository<User, String> {
///   Future<User?> getByUsername(String username) async => query();
///   Future<List<User>> getAllActive() async => queryList();
/// }
///
/// final repo = UserRepository();
/// final user = await repo.query<User>();
/// final users = await repo.queryList<User>();
/// ```
///
/// ### Design Notes
/// - This class itself does not implement persistence; it relies on an
///   optional [RepositoryExecutor] to perform operations.
/// - All query methods are asynchronous and return Futures.
/// - Supports `Iterable`, `List`, and `Set` conversions for flexible usage.
///
/// ### See Also
/// - [RepositoryExecutor]
/// - [CrudRepository]
/// {@endtemplate}
@Generic(Repository)
abstract class Repository<T, ID> {
  /// The reflective [Class] handle representing the base `Repository` interface.
  ///
  /// This definition is used for:
  /// - Detecting general repository contracts
  /// - Resolving shared behavior across all repository types
  /// - Acting as the root type for repository introspection
  ///
  /// The class is linked to the package defined by [PackageNames.DATA].
  static final Class<Repository> CLASS = Class<Repository>(null, PackageNames.DATA);

  /// Optional executor used to perform repository operations.
  ///
  /// If null, query methods return default values (null, empty list, empty set, etc.).
  RepositoryExecutor? executor;

  /// Executes a query returning a single result of type [U].
  ///
  /// Delegates execution to the assigned [executor]. Returns `null` if no
  /// executor is set.
  ///
  /// ### Example
  /// ```dart
  /// final user = await repository.query<User>();
  /// ```
  Future<U?> query<U>() async {
    final executor = this.executor;
    if (executor == null) {
      return null;
    }
    return executor.execute();
  }

  /// Executes a query returning multiple results as an [Iterable] of [U].
  ///
  /// Delegates execution to the assigned [executor]. Returns an empty
  /// iterable if no executor is set.
  ///
  /// ### Example
  /// ```dart
  /// final users = await repository.queryIterable<User>();
  /// ```
  Future<Iterable<U>> queryIterable<U>() async {
    final executor = this.executor;
    if (executor == null) {
      return [];
    }
    return executor.executeIterable();
  }

  /// Executes a query returning results as a [List] of [U].
  ///
  /// Converts the result of [queryIterable] into a [List]. Returns an
  /// empty list if no executor is set.
  ///
  /// ### Example
  /// ```dart
  /// final userList = await repository.queryList<User>();
  /// ```
  Future<List<U>> queryList<U>() async => List.from(await queryIterable());

  /// Executes a query returning results as a [Set] of [U].
  ///
  /// Converts the result of [queryIterable] into a [Set]. Returns an
  /// empty set if no executor is set.
  ///
  /// ### Example
  /// ```dart
  /// final userSet = await repository.querySet<User>();
  /// ```
  Future<Set<U>> querySet<U>() async => Set.from(await queryIterable());

  /// Returns the [Class] representing the entity type [T].
  ///
  /// Useful for reflection, type checks, or generic operations.
  ///
  /// ### Example
  /// ```dart
  /// final type = repository.getDartType(); // Class<User>
  /// ```
  Class<T> getDartType() => Class<T>();

  /// Returns the [Class] representing the ID type [ID].
  ///
  /// Useful for reflection, type checks, or generic operations.
  ///
  /// ### Example
  /// ```dart
  /// final idType = repository.getIdType(); // Class<String>
  /// ```
  Class<ID> getIdType() => Class<ID>();

    /// Returns the Dart runtime [Type] of the entity [T].
  ///
  /// This is useful for runtime type checks, reflective operations, or
  /// generic handling of entities without needing an instance.
  ///
  /// ### Example
  /// ```dart
  /// final type = repository.getType(); // User
  /// if (type == User) { ... }
  /// ```
  Type getType() => T;

  /// Returns the Dart runtime [Type] of the entity identifier [ID].
  ///
  /// Provides runtime information about the ID type used by this repository.
  ///
  /// ### Example
  /// ```dart
  /// final idType = repository.getId(); // String
  /// if (idType == String) { ... }
  /// ```
  Type getId() => ID;
}