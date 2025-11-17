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

/// JetLeaf Data Library
///
/// This library provides the core infrastructure, repository abstractions,
/// paging utilities, and event support for JetLeaf data access.
///
/// It includes:
/// - **Repository Context and Executor**: Classes for managing repository
///   lifecycle, context awareness, and execution.
/// - **Repository Abstractions**: CRUD and paging repositories, method
///   interceptors, and repository definitions.
/// - **Paging and Sorting**: Page requests, pageable interfaces, limits,
///   slices, sorting, and unpaged utilities.
/// - **Events**: Repository-related events and event bus integration.
/// - **Auto-Configuration**: Default repository context and processor beans
///   for dependency injection.
///
/// Typical usage:
/// ```dart
/// import 'package:jetleaf_data/jetleaf_data.dart';
///
/// final repoContext = repositoryContext();
/// final pageRequest = PageRequest.of(0, 20, SortDirection.asc, ['name']);
/// ```
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