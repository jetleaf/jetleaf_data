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

import '../../repository.dart';
import 'repository_executor.dart';

/// {@template jetleaf_crud_repository}
/// A generic **CRUD repository interface** extending [Repository], providing
/// standard create, read, update, and delete operations for entities of type [T]
/// identified by [ID].
///
/// This class delegates all operations to an optional [RepositoryExecutor],
/// which performs the actual data access. Default implementations are safe
/// no-ops or return default values, making this class suitable for stubbing,
/// testing, or extending with real persistence logic.
///
/// ### Features
/// - Standard CRUD operations: find, save, delete, and count.
/// - Supports batch operations on lists or iterables of entities.
/// - Delegates execution to [RepositoryExecutor] for uniform behavior.
/// - Can be extended for database-, memory-, or API-backed repositories.
///
/// ### Usage Example
/// ```dart
/// class UserRepository extends CrudRepository<User, String> {}
///
/// final repo = UserRepository();
/// final user = await repo.findById("123");
/// final allUsers = await repo.findAll();
/// await repo.save(User("Alice"));
/// ```
///
/// ### Design Notes
/// - All query methods are asynchronous and return Futures.
/// - Methods returning iterables default to empty collections when executor is null.
/// - Methods returning single entities default to `null` when executor is null.
/// - Methods returning `bool` or `int` default to `false` or `0` respectively.
/// - Methods returning an entity default to returning the entity itself.
///
/// ### See Also
/// - [Repository]
/// - [RepositoryExecutor]
/// {@endtemplate}
@Generic(CrudRepository)
abstract class CrudRepository<T, ID> extends Repository<T, ID> {
  /// The reflective [Class] handle representing the `CrudRepository` interface.
  ///
  /// This metadata object is used by the repository infrastructure to:
  /// - Identify whether a given type implements `CrudRepository`
  /// - Resolve inherited generic parameters (entity + ID types)
  /// - Detect CRUD-specific method signatures
  ///
  /// The class is associated with the package defined by [PackageNames.DATA].
  static final Class<CrudRepository> CLASS = Class<CrudRepository>(null, PackageNames.DATA);

  /// Finds an entity by its [id].
  ///
  /// Delegates to the executor. Returns `null` if not found or executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final user = await repository.findById("123");
  /// ```
  Future<T?> findById(ID id) async => executor?.findById(id, this);

  /// Finds a single entity by a given [property], optionally ignoring case.
  ///
  /// Delegates to the executor. Returns `null` if not found or executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final admin = await repository.findByProperty("username", true);
  /// ```
  Future<T?> findByProperty(String property, [bool ignoreCase = false]) async => executor?.findByProperty(property, ignoreCase, this);
  
  /// Checks if an entity with the given [id] exists.
  ///
  /// Delegates to the executor. Returns `false` if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final exists = await repository.existsById("123");
  /// ```
  Future<bool> existsById(ID id) async => executor?.existsById(id, this) ?? false;

  /// Retrieves all entities from the repository.
  ///
  /// Delegates to the executor. Returns an empty iterable if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final users = await repository.findAll();
  /// ```
  Future<Iterable<T>> findAll() async => executor?.findAll(this) ?? const [];

  /// Retrieves all entities matching the given [ids].
  ///
  /// Delegates to the executor. Returns an empty iterable if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final users = await repository.findAllById(["123", "456"]);
  /// ```
  Future<Iterable<T>> findAllById(Iterable<ID> ids) async => executor?.findAllById(ids, this) ?? const [];

  /// Returns the total number of entities in the repository.
  ///
  /// Delegates to the executor. Returns `0` if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final count = await repository.getCount();
  /// ```
  Future<int> getCount() async => executor?.getCount(this) ?? 0;

  /// Saves a single [entity] to the repository.
  ///
  /// Delegates to the executor. Returns the entity itself if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final savedUser = await repository.save(User("Alice"));
  /// ```
  Future<S> save<S extends T>(S entity) async => executor?.save<T, ID, S>(entity, this) ?? entity;

  /// Saves multiple [entities] to the repository.
  ///
  /// Delegates to the executor. Returns an empty iterable if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final savedUsers = await repository.saveAll([user1, user2]);
  /// ```
  Future<Iterable<S>> saveAll<S extends T>(Iterable<S> entities) async => executor?.saveAll<T, ID, S>(entities, this) ?? const [];

  /// Deletes an entity by its [id].
  ///
  /// Delegates to the executor. No-op if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// await repository.deleteById("123");
  /// ```
  Future<void> deleteById(ID id) async => await executor?.deleteById(id, this);

  /// Deletes a specific [entity] from the repository.
  ///
  /// Delegates to the executor. No-op if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// await repository.delete(user);
  /// ```
  Future<void> delete(T entity) async => await executor?.deleteEntity(entity, this);

  /// Deletes multiple entities by their [ids].
  ///
  /// Delegates to the executor. No-op if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// await repository.deleteAllById(["123", "456"]);
  /// ```
  Future<void> deleteAllById(Iterable<ID> ids) async => await executor?.deleteAllById(ids, this);

  /// Deletes multiple [entities] from the repository.
  ///
  /// Delegates to the executor. No-op if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// await repository.deleteAllByEntities([user1, user2]);
  /// ```
  Future<void> deleteAllByEntities(Iterable<T> entities) async => await executor?.deleteAllEntities(entities, this);

  /// Deletes all entities in the repository.
  ///
  /// Delegates to the executor. No-op if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// await repository.deleteAll();
  /// ```
  Future<void> deleteAll() async => await executor?.deleteAll(this);
}