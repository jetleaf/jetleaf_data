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

/// 🗄 **JetLeaf Data Library**
///
/// Provides repository and data access abstractions for JetLeaf
/// applications, including CRUD operations, paging, sorting, and
/// repository lifecycle management.
///
/// This library supports annotation-driven repository definitions,
/// event handling, and automatic configuration for standard data
/// access patterns.
///
///
/// ## 🔑 Core Components
///
/// ### 🏛 Repository Context
/// - `abstract_repository_context.dart` — base abstraction for a
///   repository execution context
/// - `default_repository_context.dart` — default implementation of
///   repository context
/// - `repository_application_module.dart` — application-level
///   module configuration for repositories
/// - `repository_context.dart` — main repository context interface
/// - `repository_context_aware.dart` — mixin for repository context
///   awareness in objects
/// - `repository_definition.dart` — metadata and definition of
///   repository interfaces
/// - `repository_method_interceptor.dart` — method interception for
///   repository calls
///
///
/// ### ⚡ Event Handling
/// - `repository_event.dart` — base class for repository lifecycle
///   events, such as entity creation, update, deletion
///
///
/// ### 📄 Paging & Sorting
/// Supports paginated and sorted queries across repositories:
/// - `abstract_page_request.dart` — base interface for page requests
/// - `page_request.dart` — concrete page request
/// - `page.dart` — represents a paged result
/// - `slice.dart`, `sliced_chunk.dart` — partial result sets
/// - `scroll_position.dart` — track pagination scroll positions
/// - `limit.dart` — page size constraints
/// - `pageable.dart` — abstraction for pageable queries
/// - `sort.dart` — sorting metadata
/// - `unpaged.dart` — sentinel object representing no pagination
///
///
/// ### 📚 Repository Interfaces
/// - `crud_repository.dart` — standard CRUD operations
/// - `list_crud_repository.dart` — list-based CRUD repository
/// - `paging_and_sort_repository.dart` — repository supporting
///   paging and sorting
/// - `repository_executor.dart` — executor for repository operations
///
///
/// ### ⚙ Auto-Configuration
/// - `data_auto_configuration.dart` — sets up default repository
///   context, repository scanning, and repository lifecycle handling
///
///
/// ## 🎯 Intended Usage
///
/// Import this library to implement data repositories in a JetLeaf
/// project:
/// ```dart
/// import 'package:jetleaf_data/jetleaf_data.dart';
///
/// class UserRepository extends CrudRepository<User, String> {
///   // CRUD operations are automatically available
/// }
///
/// final repositoryContext = DefaultRepositoryContext();
/// ```
///
/// Provides a standard foundation for repository-based data access,
/// paging, sorting, and event-driven repository monitoring.
///
///
/// © 2025 Hapnium & JetLeaf Contributors
library;

export 'src/core/abstract_repository_context.dart';
export 'src/core/default_repository_context.dart';
export 'src/core/repository_application_module.dart';
export 'src/core/repository_context.dart';
export 'src/core/repository_context_aware.dart';
export 'src/core/repository_definition.dart';
export 'src/core/repository_method_interceptor.dart';

export 'src/event/repository_event.dart';

export 'src/paging/abstract_page_request.dart';
export 'src/paging/limit.dart';
export 'src/paging/page.dart';
export 'src/paging/page_request.dart';
export 'src/paging/pageable.dart';
export 'src/paging/scroll_position.dart';
export 'src/paging/slice.dart';
export 'src/paging/sliced_chunk.dart';
export 'src/paging/sort.dart';
export 'src/paging/unpaged.dart';

export 'src/repository/crud_repository.dart';
export 'src/repository/list_crud_repository.dart';
export 'src/repository/paging_and_sort_repository.dart';
export 'src/repository/repository_executor.dart';

export 'src/data_auto_configuration.dart';