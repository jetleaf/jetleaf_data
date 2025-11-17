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

import 'pageable.dart';
import 'sliced_chunk.dart';

/// {@template page}
/// Represents a **full page of data** in a paginated dataset.
///
/// A [Page] extends [SlicedChunk] and provides additional metadata such as:
/// - the total number of pages
/// - the total number of elements in the dataset
///
/// Pages are typically returned by repository or service layers when querying
/// paginated data. They combine content, paging metadata, and sorting information.
///
/// ### Usage Example
/// ```dart
/// final page = repository.findUsers(PageRequest.ofSize(20));
///
/// print(page.getNumber());          // current page number
/// print(page.getSize());            // page size
/// print(page.getTotalPages());      // total pages
/// print(page.getTotalElements());   // total elements
/// print(page.getContent());         // list of users in current page
/// print(page.hasNext());            // true if there is a next page
///
/// // Mapping page content to another type
/// final idsPage = page.slice((user) => user.id);
/// print(idsPage.getContent()); // List<int>
/// ```
///
/// ### Design Notes
/// - [Page] instances are **immutable** and fully describe a page in the dataset.
/// - Navigation helpers (from [SlicedChunk]) work seamlessly with `Pageable`.
/// - Use [empty] to create an empty page for default or placeholder responses.
/// {@endtemplate}
@Generic(Page)
abstract class Page<T> extends SlicedChunk<T> {
  /// Constructs a [Page] with the given stream of [source] elements
  /// and the associated [Pageable] for pagination metadata.
  /// 
  /// {@macro page}
  Page(super.source, super.pageable);

  /// Returns an **empty page** with the optional [pageable] metadata.
  ///
  /// Useful as a placeholder or default response when no data is available.
  ///
  /// Example:
  /// ```dart
  /// final emptyPage = Page.empty<User>();
  /// print(emptyPage.getContent()); // []
  /// print(emptyPage.isFirst());    // true
  /// ```
  static Page<T> empty<T>([Pageable? pageable]) => SimplePage([], pageable ?? Pageable.unpaged());

  /// Returns the **total number of pages** in the dataset.
  ///
  /// Typically calculated as `ceil(totalElements / pageSize)`.
  ///
  /// Example:
  /// ```dart
  /// final totalPages = page.getTotalPages();
  /// print("Total pages: $totalPages");
  /// ```
  int getTotalPages();

  /// Returns the **total number of elements** across all pages.
  ///
  /// Example:
  /// ```dart
  /// final totalElements = page.getTotalElements();
  /// print("Total elements: $totalElements");
  /// ```
  int getTotalElements();

  @override
  Page<U> map<U>(U Function(T item) mapper);
}

/// {@template simple_page}
/// Concrete implementation of [Page<T>] representing a **page of elements**
/// with an optional total element count.
///
/// [SimplePage] stores the page content, pagination metadata from [Pageable],
/// and the total number of elements across the dataset. It calculates
/// total pages and provides navigation helpers accordingly.
///
/// ### Usage Example
/// ```dart
/// final pageRequest = PageRequest.ofSize(10);
/// final page = SimplePage(usersStream, pageRequest, 35);
///
/// print(page.getTotalElements()); // 35
/// print(page.getTotalPages());    // 4
/// print(page.hasNext());          // true
/// print(page.getContent());       // list of users
///
/// // Mapping page content to another type
/// final idPage = page.map((user) => user.id);
/// print(idPage.getContent()); // List<int>
/// ```
/// 
/// {@endtemplate}
@Generic(SimplePage)
class SimplePage<T> extends Page<T> {
  /// The total number of elements in the dataset.
  final int total;

  /// Constructs a [SimplePage] with the given [source] elements, [pageable]
  /// metadata, and optional [total] element count.
  ///
  /// If [total] is not provided, it will be calculated from the pageable's
  /// offset and the number of elements in [source], if applicable.
  ///
  /// ### Example
  /// ```dart
  /// final page = SimplePage(usersStream, pageRequest, 42);
  /// print(page.getTotalElements()); // 42
  /// ```
  /// 
  /// {@macro simple_page}
  SimplePage(super.source, super.pageable, [int total = 0])
      : total = pageable.optional()
          .filter((pg) => source.isNotEmpty)
          .filter((pg) => pg.getOffset().plus(pg.getPageSize()).isGreaterThan(total))
          .map((pg) => pg.getOffset().plus(source.length))
          .orElse(total);

  /// Creates a [SimplePage] containing the given [content] and marks it as unpaged.
  ///
  /// This is useful for cases where you have a complete list of items and do not
  /// want to apply any pagination.
  ///
  /// - [content]: The list of elements to include in this page.
  /// 
  /// Returns a [SimplePage] with:
  /// - `pageable` set to [Pageable.unpaged()],
  /// - `total` equal to the length of [content].
  ///
  /// Example:
  /// ```dart
  /// final page = SimplePage.withContent([1, 2, 3]);
  /// print(page.getTotalElements()); // 3
  /// print(page.getPageable().isUnpaged()); // true
  /// ```
  factory SimplePage.withContent(List<T> content) => SimplePage(content, Pageable.unpaged(), content.length);

  @override
  int getTotalElements() => total;

  @override
  int getTotalPages() => isEmpty() ? 1 : total.divideBy(getSize()).ceil();

  @override
  bool hasNext() => getNumber() + 1 < getTotalPages();

  @override
  Page<U> map<U>(U Function(T item) mapper) => SimplePage(convert(mapper), getPageable(), total);
}