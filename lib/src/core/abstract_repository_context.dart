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

import '../repository/crud_repository.dart';
import '../repository/list_crud_repository.dart';
import '../repository/paging_and_sort_repository.dart';
import '../../repository.dart';
import 'repository_context.dart';
import 'repository_definition.dart';
import 'repository_method_interceptor.dart';

/// An abstract base implementation of a repository context that stores and
/// provides metadata ([RepositoryDefinition]) for repository methods.
///
/// This context participates in the interception pipeline via
/// [RepositoryMethodInterceptor], allowing it to:
///
/// - Identify repository methods before invocation.
/// - Publish interception events.
/// - Resolve definitions for methods based on their declaring repository type.
/// - Maintain a synchronized registry of known repository method definitions.
///
/// Concrete subclasses are expected to provide event bus access through
/// [getEventBus] and possibly extend definition rules if necessary.
///
/// ### Responsibilities
/// - Acts as a central registry for repository method metadata.
/// - Ensures thread-safety through `synchronized` operations.
/// - Builds new definitions via [buildDefinition] when needed.
/// - Distinguishes between internal framework repository methods and
///   custom user-defined ones.
///
/// ### Thread Safety
/// All access to `_definitions` is synchronized on the map itself.  
/// This ensures deterministic behavior in concurrent environments.
///
/// ### Definition Lifecycle
/// - Definitions may be preloaded or added lazily during interception.
/// - `addDefinition()` always replaces existing entries for the same method.
///
/// ### See Also
/// - [RepositoryDefinition]
/// - [RepositoryMethodInterceptor]
/// - [DataRepositoryDefinition]
/// - [RepositoryType]
abstract class AbstractRepositoryContext extends RepositoryMethodInterceptor implements ConfigurableRepositoryContext {
  /// Internal registry mapping:
  /// ```
  /// "<qualified-class>#<method-name>" → RepositoryDefinition
  /// ```
  final Map<String, RepositoryDefinition> _definitions = {};

  @override
  RepositoryDefinition? getDefinition(Method method) {
    return synchronized(_definitions, () {
      final key = _buildKey(method);
      return _definitions[key];
    });
  }

  @override
  void addDefinition(RepositoryDefinition definition) {
    return synchronized(_definitions, () {
      final key = _buildKey(definition.getMethod());

      // Replace any existing definition for the same method
      _definitions.remove(key);
      _definitions.add(key, definition);
    });
  }

  /// {@template build_key}
  /// Constructs a unique cache key for the given [method] based on its declaring
  /// class and method name.
  ///
  /// The resulting key follows the format:
  /// ```
  /// — <qualified-class-name>#<method-name>
  /// ```
  ///
  /// This convention ensures that methods with the same name but different
  /// declaring types (or packages) are properly distinguished.
  ///
  /// ### Example
  /// ```dart
  /// final key = _buildKey(method);
  /// print(key); // "com.example.service.UserService#saveUser"
  /// ```
  ///
  /// ### Parameters
  /// - [method]: The reflective representation of a class method.
  ///
  /// ### Returns
  /// - A unique key string suitable for use in internal registries or caches.
  /// {@endtemplate}
  String _buildKey(Method method) => "${method.getDeclaringClass().getQualifiedName()}#${method.getName()}";

  /// Builds a new [RepositoryDefinition] for the given reflected [method]
  /// and repository object [target].
  ///
  /// This method determines:
  /// - Whether the method is considered an **internal framework method**.
  /// - What [RepositoryType] it belongs to (CRUD, LIST_CRUD, PAGEABLE, etc.).
  ///
  /// Internal methods are those inherited from framework-provided repository
  /// base classes (e.g., `CrudRepository`, `ListCrudRepository`).
  ///
  /// Custom user-defined methods default to:
  /// ```
  /// isInternal = false
  /// type = RepositoryType.CUSTOM
  /// ```
  ///
  /// ### Resolution Rules
  /// The method is matched in the following order:
  /// 1. `ListCrudRepository`
  /// 2. `CrudRepository`
  /// 3. `ListPagingAndSortRepository`
  /// 4. `PagingAndSortingRepository`
  /// 5. `Repository`
  ///
  /// The first match determines the type and internal flag.
  ///
  /// ### Returns
  /// A fully constructed [DataRepositoryDefinition].
  RepositoryDefinition buildDefinition(Method method, Object target) {
    bool isInternal = false;
    RepositoryType type = RepositoryType.CUSTOM;

    if (ListCrudRepository.CLASS.getMethod(method.getName()) != null && target is ListCrudRepository) {
      isInternal = true;
      type = RepositoryType.LIST_CRUD;
    } else if (CrudRepository.CLASS.getMethod(method.getName()) != null && target is CrudRepository) {
      isInternal = true;
      type = RepositoryType.CRUD;
    } else if (ListPagingAndSortRepository.CLASS.getMethod(method.getName()) != null && target is ListPagingAndSortRepository) {
      isInternal = true;
      type = RepositoryType.LIST_PAGEABLE;
    } else if (PagingAndSortRepository.CLASS.getMethod(method.getName()) != null && target is PagingAndSortRepository) {
      isInternal = true;
      type = RepositoryType.PAGEABLE;
    } else if (Repository.CLASS.getMethod(method.getName()) != null && target is Repository) {
      isInternal = true;
      type = RepositoryType.BASE;
    }

    return DataRepositoryDefinition(isInternal, method, type);
  }
}

/// {@template jetleaf_data_repository_definition}
/// A concrete implementation of [RepositoryDefinition] that stores metadata
/// about a repository method, including its type, reflection metadata,
/// and whether it should be treated as an internal framework method.
///
/// This definition is typically produced during repository analysis or
/// code-generation phases, then consumed by interceptors such as
/// [RepositoryMethodInterceptor] to determine how a repository method
/// should be executed.
///
/// ### Features
/// - Stores the underlying reflected [Method].
/// - Specifies the repository behavior category via [RepositoryType].
/// - Indicates whether the method is internal (not user-facing).
/// - Implements structural equality via `equalizedProperties`.
///
/// ### Usage Example
/// ```dart
/// final definition = DataRepositoryDefinition(
///   false,
///   method,
///   RepositoryType.CRUD,
/// );
///
/// if (!definition.isInternalMethod()) {
///   print('Repository method: ${definition.getMethod().getName()}');
/// }
/// ```
///
/// ### Design Notes
/// - Immutable and marked `const` for compile-time construction when possible.
/// - Internal methods allow frameworks to distinguish between user-defined
///   repository operations and helper or generated methods.
/// - Equality is based on internal state: `_isInternal`, `_method`, `_type`.
///
/// ### See Also
/// - [RepositoryDefinition]
/// - [RepositoryType]
/// - [Method]
/// - [RepositoryMethodInterceptor]
/// {@endtemplate}
final class DataRepositoryDefinition implements RepositoryDefinition {
  /// Indicates whether the method is considered internal.
  final bool _isInternal;

  /// The reflected repository method this definition describes.
  final Method _method;

  /// The classification for this repository method.
  final RepositoryType _type;

  /// Creates a new repository method definition.
  ///
  /// - [_isInternal] defines whether this method should be treated as a
  ///   non-user-facing internal method.
  /// - [_method] is the reflection metadata for the repository method.
  /// - [_type] indicates the repository behavior category.
  /// 
  /// {@macro jetleaf_data_repository_definition}
  const DataRepositoryDefinition(this._isInternal, this._method, this._type);

  @override
  List<Object?> equalizedProperties() => [_isInternal, _method, _type];

  @override
  Method getMethod() => _method;

  @override
  RepositoryType getType() => _type;

  @override
  bool isInternalMethod() => _isInternal;
}