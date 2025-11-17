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

import '../paging/page.dart';
import '../paging/pageable.dart';
import '../paging/sort.dart';
import '../../repository.dart';

/// {@template jetleaf_repository_executor}
/// An **abstract executor** for performing CRUD and query operations on
/// [Repository] instances in a uniform, asynchronous manner.
///
/// This class provides default, no-op implementations for repository
/// operations, returning `null`, empty collections, or default values. It
/// is intended to be **extended** by concrete executor implementations
/// that interact with actual data stores.
///
/// The executor handles operations such as:
/// - Finding entities by ID or property
/// - Checking existence
/// - Saving and deleting entities
/// - Pagination and sorting
///
/// ### Usage Example
/// ```dart
/// class MyRepositoryExecutor extends RepositoryExecutor {
///   @override
///   Future<T?> findById<T, ID>(ID id, Repository<T, ID> repository) async {
///     // Implement custom logic
///     return repository.find(id);
///   }
/// }
///
/// final executor = MyRepositoryExecutor();
/// final user = await executor.findById<User, String>("123", userRepository);
/// ```
///
/// ### Design Notes
/// - Provides asynchronous API for all repository operations
/// - Default implementations are safe no-ops for testing or stubbing
/// - Should be extended to implement actual persistence behavior
/// - Includes support for pagination ([Pageable]) and sorting ([Sort])
///
/// ### Example Behavior
/// | Method | Return (default) |
/// |--------|-----------------|
/// | `execute<T>()` | `null` |
/// | `findAll<T, ID>()` | `[]` |
/// | `existsById<T, ID>()` | `false` |
/// | `getCount<T, ID>()` | `0` |
/// | `save<T, ID, S extends T>()` | entity itself |
/// | `findPage<T, ID>()` | empty [Page] |
///
/// ### See Also
/// - [Repository]
/// - [Pageable]
/// - [Page]
/// - [Sort]
/// {@endtemplate}
abstract class RepositoryExecutor {
  /// {@macro jetleaf_repository_executor}
  const RepositoryExecutor();

  /// {@template repository_executor_class}
  /// Holds the [Class] metadata for the [RepositoryExecutor] type.
  ///
  /// This is used for reflection, type lookup, or registration purposes
  /// within the framework. It allows framework components to refer
  /// to the `RepositoryExecutor` class in a type-safe way without
  /// needing a concrete instance.
  ///
  /// ### Usage
  /// ```dart
  /// final clazz = RepositoryExecutor.CLASS;
  /// print(clazz.name); // prints class name if available
  /// ```
  /// {@endtemplate}
  static Class<RepositoryExecutor> CLASS = Class<RepositoryExecutor>(null, PackageNames.WEB);

  /// Executes a generic repository operation and returns a single result of type [T].
  ///
  /// This method can be overridden to implement custom query or command execution
  /// logic for any type. The default implementation always returns `null`.
  ///
  /// ### Example
  /// ```dart
  /// final result = await executor.execute<MyEntity>();
  /// // result is null by default
  /// ```
  Future<T?> execute<T>() async => null;

  /// Executes a generic repository operation and returns multiple results of type [T].
  ///
  /// This is useful when expecting multiple entities from a query. The default
  /// implementation always returns an empty iterable.
  ///
  /// ### Example
  /// ```dart
  /// final results = await executor.executeIterable<MyEntity>();
  /// // results is []
  /// ```
  Future<Iterable<T>> executeIterable<T>() async => const [];

  /// Finds an entity by its [id] using the provided [repository].
  ///
  /// Returns `null` if no entity is found. Override this method to provide
  /// actual retrieval logic from the repository.
  ///
  /// ### Example
  /// ```dart
  /// final user = await executor.findById<User, String>("123", userRepository);
  /// // user is null by default
  /// ```
  Future<T?> findById<T, ID>(ID id, Repository<T, ID> repository) async => null;

  /// Finds a single entity by a given [property] with optional case-insensitive matching.
  ///
  /// Returns `null` if no entity matches. Override this method to implement
  /// property-based lookups in your repositories.
  ///
  /// ### Example
  /// ```dart
  /// final admin = await executor.findByProperty<User, String>(
  ///   "username",
  ///   true,
  ///   userRepository,
  /// );
  /// // admin is null by default
  /// ```
  Future<T?> findByProperty<T, ID>(String property, bool ignoreCase, Repository<T, ID> repository) async => null;

  /// Checks whether an entity with the given [id] exists in the repository.
  ///
  /// Returns `false` by default. Override to implement actual existence checks.
  ///
  /// ### Example
  /// ```dart
  /// final exists = await executor.existsById<User, String>("123", userRepository);
  /// // exists is false by default
  /// ```
  Future<bool> existsById<T, ID>(ID id, Repository<T, ID> repository) async => false;

  /// Retrieves all entities from the given [repository].
  ///
  /// Default implementation returns an empty iterable. Override to fetch actual
  /// entities.
  ///
  /// ### Example
  /// ```dart
  /// final allUsers = await executor.findAll<User, String>(userRepository);
  /// // allUsers is [] by default
  /// ```
  Future<Iterable<T>> findAll<T, ID>(Repository<T, ID> repository) async => const [];

  /// Retrieves all entities matching the given [ids] from the repository.
  ///
  /// Returns an empty iterable by default. Override to fetch entities by IDs.
  ///
  /// ### Example
  /// ```dart
  /// final users = await executor.findAllById<User, String>(["123", "456"], userRepository);
  /// // users is [] by default
  /// ```
  Future<Iterable<T>> findAllById<T, ID>(Iterable<ID> ids, Repository<T, ID> repository) async => const [];

  /// Returns the total number of entities in the repository.
  ///
  /// Default implementation returns `0`. Override to return actual count.
  ///
  /// ### Example
  /// ```dart
  /// final count = await executor.getCount<User, String>(userRepository);
  /// // count is 0 by default
  /// ```
  Future<int> getCount<T, ID>(Repository<T, ID> repository) async => 0;

  /// Saves the given [entity] to the repository.
  ///
  /// Returns the entity itself by default. Override to implement actual save
  /// logic.
  ///
  /// ### Example
  /// ```dart
  /// final savedUser = await executor.save<User, String, User>(user, userRepository);
  /// // savedUser is user itself by default
  /// ```
  Future<S> save<T, ID, S extends T>(S entity, Repository<T, ID> repository) async => entity;

  /// Saves multiple [entities] to the repository.
  ///
  /// Returns an empty iterable by default. Override to implement batch save logic.
  ///
  /// ### Example
  /// ```dart
  /// final savedUsers = await executor.saveAll<User, String, User>([user1, user2], userRepository);
  /// // savedUsers is [] by default
  /// ```
  Future<Iterable<S>> saveAll<T, ID, S extends T>(Iterable<S> entities, Repository<T, ID> repository) async => const [];
  
  /// Deletes an entity by its identifier.
  ///
  /// - [id]: The identifier of the entity to delete.
  /// - [repository]: The repository managing the entity type `T`.
  ///
  /// Throws an exception if the deletion fails.
  Future<void> deleteById<T, ID>(ID id, Repository<T, ID> repository) async {}

  /// Deletes the given entity instance.
  ///
  /// - [entity]: The entity instance to delete.
  /// - [repository]: The repository managing the entity type `T`.
  ///
  /// Throws an exception if the deletion fails.
  Future<void> deleteEntity<T, ID>(T entity, Repository<T, ID> repository) async {}

  /// Deletes multiple entities by their identifiers.
  ///
  /// - [ids]: The identifiers of the entities to delete.
  /// - [repository]: The repository managing the entity type `T`.
  ///
  /// Performs batch deletion if supported by the repository.
  Future<void> deleteAllById<T, ID>(Iterable<ID> ids, Repository<T, ID> repository) async {}

  /// Deletes multiple entity instances.
  ///
  /// - [entities]: The entity instances to delete.
  /// - [repository]: The repository managing the entity type `T`.
  ///
  /// Performs batch deletion if supported by the repository.
  Future<void> deleteAllEntities<T, ID>(Iterable<T> entities, Repository<T, ID> repository) async {}

  /// Deletes all entities managed by the repository.
  ///
  /// - [repository]: The repository managing the entity type `T`.
  ///
  /// Use with caution as this will remove all records of the type.
  Future<void> deleteAll<T, ID>(Repository<T, ID> repository) async {}

  /// Returns all entities sorted according to the given [sort].
  ///
  /// Default implementation returns an empty iterable. Override to implement
  /// actual sorting logic.
  ///
  /// ### Example
  /// ```dart
  /// final sortedUsers = await executor.findAllSorted<User, String>(
  ///   Sort.by("username"),
  ///   userRepository,
  /// );
  /// // sortedUsers is [] by default
  /// ```
  Future<Iterable<T>> findAllSorted<T, ID>(Sort sort, Repository<T, ID> repository) async => const [];

  /// Returns a page of entities according to [pageable] constraints.
  ///
  /// Default implementation returns an empty [Page]. Override to provide
  /// actual paginated queries.
  ///
  /// ### Example
  /// ```dart
  /// final page = await executor.findPage<User, String>(
  ///   Pageable(page: 0, size: 10),
  ///   userRepository,
  /// );
  /// // page is empty by default
  /// ```
  Future<Page<T>> findPage<T, ID>(Pageable pageable, Repository<T, ID> repository) async => Page.empty();
}