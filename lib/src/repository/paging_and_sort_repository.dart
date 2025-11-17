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
import 'crud_repository.dart';
import 'list_crud_repository.dart';
import '../../repository.dart';
import 'repository_executor.dart';

/// {@template jetleaf_paging_and_sorting_repository}
/// A generic **repository with paging and sorting capabilities**, extending
/// [Repository] and providing methods to retrieve sorted collections or
/// paginated results.
///
/// This repository is intended for use cases where results need to be
/// ordered or divided into pages for efficient processing and display.
///
/// ### Features
/// - Supports sorting via [Sort] objects.
/// - Supports pagination via [Pageable] objects and returns [Page] results.
/// - Delegates execution to an optional [RepositoryExecutor].
///
/// ### Usage Example
/// ```dart
/// class UserRepository extends PagingAndSortingRepository<User, String> {}
///
/// final repo = UserRepository();
/// final sortedUsers = await repo.findAllSorted(Sort.by("username"));
/// final page = await repo.findPage(Pageable(page: 0, size: 10));
/// ```
///
/// ### Design Notes
/// - Methods return empty iterables or empty pages if executor is null.
/// - Paging and sorting operations remain asynchronous.
/// - Can be combined with [CrudRepository] or [ListCrudRepository] for full CRUD support.
///
/// ### See Also
/// - [RepositoryExecutor]
/// - [Sort]
/// - [Pageable]
/// - [Page]
/// {@endtemplate}
@Generic(PagingAndSortRepository)
abstract class PagingAndSortRepository<T, ID> extends Repository<T, ID> {
  /// The reflective [Class] handle representing the `PagingAndSortingRepository` interface.
  ///
  /// This metadata is used by the paging subsystem to:
  /// - Identify repository types supporting pagination and sorting
  /// - Resolve generic type parameters for paginated queries
  /// - Enable page and sort method interception
  ///
  /// The class is associated with [PackageNames.DATA].
  static final Class<PagingAndSortRepository> CLASS = Class<PagingAndSortRepository>(null, PackageNames.DATA);

  /// Retrieves all entities sorted according to the given [sort].
  ///
  /// Delegates to the executor. Returns an empty iterable if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final sortedUsers = await repository.findAllSorted(Sort.by("username"));
  /// ```
  Future<Iterable<T>> findAllSorted(Sort sort) async => executor?.findAllSorted(sort, this) ?? const [];

  /// Retrieves a page of entities according to [pageable] constraints.
  ///
  /// Delegates to the executor. Returns an empty [Page] if executor is null.
  ///
  /// ### Example
  /// ```dart
  /// final page = await repository.findPage(Pageable(page: 0, size: 10));
  /// ```
  Future<Page<T>> findPage(Pageable pageable) async => executor?.findPage(pageable, this) ?? Page.empty();
}

/// {@template jetleaf_list_paging_and_sort_repository}
/// A generic **list-based paging and sorting repository**, extending
/// [PagingAndSortRepository] and ensuring that sorted results are
/// returned as [List] instead of a generic [Iterable].
///
/// This repository is useful when consumers require **concrete list semantics**
/// for sorting operations, for example when directly binding results to UI
/// components or performing list-specific operations.
///
/// ### Features
/// - Overrides `findAllSorted` to return a [List].
/// - Retains all other paging and sorting functionality from
///   [PagingAndSortRepository].
/// - Delegates execution to an optional [RepositoryExecutor].
///
/// ### Usage Example
/// ```dart
/// class UserRepository extends ListPagingAndSortRepository<User, String> {}
///
/// final repo = UserRepository();
/// final sortedUsers = await repo.findAllSorted(Sort.by("username")); // returns List<User>
/// ```
///
/// ### Design Notes
/// - Only `findAllSorted` is overridden; pagination via [findPage] retains
///   default behavior from [PagingAndSortRepository].
/// - Asynchronous execution through [RepositoryExecutor] is preserved.
/// - Can be combined with other repository types for full CRUD, list, and
///   paging support.
///
/// ### See Also
/// - [PagingAndSortRepository]
/// - [RepositoryExecutor]
/// - [Sort]
/// {@endtemplate}
@Generic(ListPagingAndSortRepository)
abstract class ListPagingAndSortRepository<T, ID> extends PagingAndSortRepository<T, ID> {
  /// The reflective [Class] handle representing the `ListPagingAndSortRepository` interface.
  ///
  /// This class reference allows the framework to:
  /// - Work with repositories that return list-based paginated content
  /// - Detect paging, sorting, and list-materialization semantics
  /// - Resolve generic arguments for page-aware queries
  ///
  /// The class belongs to [PackageNames.DATA].
  static final Class<ListPagingAndSortRepository> CLASS = Class<ListPagingAndSortRepository>(null, PackageNames.DATA);

  /// Retrieves all entities sorted according to the given [sort] as a [List].
  ///
  /// Overrides [PagingAndSortRepository.findAllSorted] to convert the
  /// result from [Iterable] to [List].
  ///
  /// ### Example
  /// ```dart
  /// final sortedUsers = await repository.findAllSorted(Sort.by("username"));
  /// ```
  @override
  Future<List<T>> findAllSorted(Sort sort) async => List.from(await super.findAllSorted(sort));
}