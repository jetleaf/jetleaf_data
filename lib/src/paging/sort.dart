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

/// Represents the direction in which results should be sorted.
///
/// Commonly used for database queries, API filters, and collection
/// utilities that require specifying ascending or descending order.
enum SortDirection {
  /// Sort values from smallest → largest (A → Z, 0 → 9).
  ASC,

  /// Sort values from largest → smallest (Z → A, 9 → 0).
  DESC;

  /// Returns `true` if this direction is ascending.
  ///
  /// Equivalent to checking `this == SortDirection.ASC`.
  bool isAscending() => equals(ASC);

  /// Returns `true` if this direction is descending.
  ///
  /// Equivalent to checking `this == SortDirection.DESC`.
  bool isDescending() => equals(DESC);

  /// Parses a string into a [SortDirection].
  ///
  /// The comparison is case-insensitive.
  ///
  /// ### Example
  /// ```dart
  /// final dir1 = SortDirection.fromString("asc");  // SortDirection.ASC
  /// final dir2 = SortDirection.fromString("DESC"); // SortDirection.DESC
  /// ```
  ///
  /// Throws an [IllegalStateException] if the value does not match `"asc"`
  /// or `"desc"`.
  static SortDirection fromString(String value) {
    return switch (value.toUpperCase()) {
      "ASC" => ASC,
      "DESC" => DESC,
      _ => throw IllegalStateException("Unknown value passed. Value must either be 'desc' or 'asc'."),
    };
  }
}

/// {@template sort_order}
/// Represents a **single sorting instruction** consisting of:
/// - a **property** (field name),
/// - a **direction** ([SortDirection]),
/// - and whether the sort should be **case-insensitive**.
///
/// This class is part of the fluent sorting API used to construct declarative,
/// immutable sort configurations for queries, collections, or persistence
/// frameworks.
///
/// ### Usage Example
/// ```dart
/// // Basic ascending order
/// final order = SortOrder('username');
///
/// // Descending order
/// final order = SortOrder.desc('createdAt');
///
/// // Case-insensitive ordering
/// final order = SortOrder('email', ignoreCase: true);
///
/// // Fluent modification
/// final reversed = order.reverse();
/// ```
///
/// ### Behavior Notes
/// - `property` must be non-empty.
/// - Defaults to ascending order if no direction is provided.
/// - Instances are **immutable**; transformation methods return new instances.
/// - Implements equality through [EqualsAndHashCode].
///
/// ### See Also
/// - [Sort]
/// - [SortDirection]
/// {@endtemplate}
final class SortOrder with EqualsAndHashCode {
  /// The default direction used when none is provided: ascending.
  static final SortDirection DEFAULT_DIRECTION = SortDirection.ASC;

  /// The sorting direction (ascending or descending).
  final SortDirection direction;

  /// The property (field) name to be sorted by.
  final String property;

  /// Whether sorting should be case-insensitive.
  final bool ignoreCase;

  /// {@macro sort_order}
  SortOrder(this.property, {SortDirection? direction, bool? ignoreCase})
    : direction = direction ?? DEFAULT_DIRECTION,
      ignoreCase = ignoreCase ?? false,
      assert(property.isNotEmpty, "Property cannot be empty");

  // ---------------------------------------------------------------------------
  // Static Constructors
  // ---------------------------------------------------------------------------

  /// Creates a new ascending order for the given [property].
  ///
  /// ```dart
  /// final o = SortOrder.by('age');
  /// ```
  static SortOrder by(String property) => SortOrder(property);

  /// Creates an ascending sort order for [property].
  ///
  /// ```dart
  /// final o = SortOrder.asc('name');
  /// ```
  static SortOrder asc(String property) => SortOrder(property, direction: DEFAULT_DIRECTION);

  /// Creates a descending sort order for [property].
  ///
  /// ```dart
  /// final o = SortOrder.desc('createdAt');
  /// ```
  static SortOrder desc(String property) => SortOrder(property, direction: SortDirection.DESC);

  // ---------------------------------------------------------------------------
  // Transformations (Fluent API)
  // ---------------------------------------------------------------------------

  /// Returns a copy of this order with the given [direction].
  ///
  /// ```dart
  /// final o = SortOrder('age').withDirection(SortDirection.DESC);
  /// ```
  SortOrder withDirection(SortDirection direction) => copyWith(direction: direction);

  /// Reverses the sort direction.
  ///
  /// - ASC → DESC  
  /// - DESC → ASC
  ///
  /// ```dart
  /// final reversed = SortOrder.asc('age').reverse(); // DESC
  /// ```
  SortOrder reverse() => withDirection(direction.isAscending() ? SortDirection.DESC : DEFAULT_DIRECTION);

  /// Returns a copy of this order with the given [property].
  ///
  /// ```dart
  /// final o = SortOrder('name').withProperty('email');
  /// ```
  SortOrder withProperty(String property) => copyWith(property: property);

  /// Returns a copy of this order with case-insensitive sorting enabled.
  ///
  /// ```dart
  /// final o = SortOrder('email').withIgnoreCase();
  /// ```
  SortOrder withIgnoreCase() => copyWith(ignoreCase: true);

  /// Creates a new [Sort] using this order’s direction and the given
  /// list of [properties].
  ///
  /// ```dart
  /// final sort = SortOrder('name').withProperties(['name', 'email']);
  /// ```
  Sort withProperties(List<String> properties) => Sort.withDirection(direction, properties);

  // ---------------------------------------------------------------------------
  // Copy
  // ---------------------------------------------------------------------------

  /// Creates a new [SortOrder] with the optionally overridden values.
  ///
  /// ```dart
  /// final updated = order.copyWith(ignoreCase: true);
  /// ```
  SortOrder copyWith({SortDirection? direction, String? property, bool? ignoreCase}) {
    return SortOrder(
      property ?? this.property,
      direction: direction ?? this.direction,
      ignoreCase: ignoreCase ?? this.ignoreCase,
    );
  }

  @override
  List<Object?> equalizedProperties() => [direction, property, ignoreCase];

  @override
  String toString() => "SortOrder(property: $property, direction: $direction, ignoreCase: $ignoreCase)";
}

/// {@template sort}
/// Represents an **ordered collection of sorting instructions**, each expressed
/// as a [SortOrder].  
///
/// A [Sort] instance models a declarative sorting strategy typically used in
/// database queries, repository abstractions, or in-memory sorting operations.
///
/// ### Core Characteristics
/// - Immutable collection of [SortOrder] elements  
/// - Supports fluent transformations (ascending, descending, reverse, merge)  
/// - Provides helper methods to inspect sorting state  
/// - Implements [GenericStream] for iterable-like APIs  
///
/// ### Usage Example
/// ```dart
/// // A simple ascending sort by "username"
/// final s1 = Sort.by([SortOrder.asc('username')]);
///
/// // Multiple-field sorting
/// final s2 = Sort.withDirection(
///   SortDirection.DESC,
///   ['createdAt', 'id'],
/// );
///
/// // Combine sorts
/// final merged = s1.and(s2);
///
/// // Reverse existing sort
/// final reversed = merged.reverse(merged);
/// ```
///
/// ### Design Notes
/// - `Sort.UNSORTED` is a singleton representing no sorting.  
/// - Empty sorts are always treated as unsorted.  
/// - Transformations return **new instances**, never modifying the original.  
/// - A sort is considered *active* when it contains at least one [SortOrder].  
///
/// ### See Also
/// - [SortOrder]  
/// - [SortDirection]  
/// - [GenericStream]  
/// {@endtemplate}
final class Sort extends StandardGenericStream<SortOrder> with EqualsAndHashCode implements GenericStream<SortOrder> {
  /// A singleton representing the absence of sorting.
  ///
  /// This is used whenever an empty list of [SortOrder] objects is provided.
  static final Sort UNSORTED = Sort.by([]);

  /// {@macro sort}
  Sort(super.source);

  /// Creates a [Sort] using a list of property names and a shared [direction].
  ///
  /// Each property is converted into a corresponding [SortOrder] instance.
  ///
  /// ```dart
  /// final sort = Sort.withDirection(
  ///   SortDirection.ASC,
  ///   ['name', 'email'],
  /// );
  /// ```
  ///
  /// Throws an assertion error if [properties] is empty.
  Sort.withDirection(SortDirection direction, List<String> properties)
    : assert(properties.isNotEmpty, "You must provide atleast, one property"),
      super(properties.map((property) => SortOrder(property, direction: direction)));

  /// Creates a new [Sort] using the provided list of [orders].
  ///
  /// If the list is empty, returns [UNSORTED].
  ///
  /// ```dart
  /// final sort = Sort.by([
  ///   SortOrder.asc('username'),
  ///   SortOrder.desc('createdAt'),
  /// ]);
  /// ```
  static Sort by(List<SortOrder> orders) => orders.isEmpty ? UNSORTED : Sort(orders);

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  /// Internal method that applies the given [direction] to all existing orders.
  ///
  /// Used by [ascending] and [descending].
  Sort _withDirection(SortDirection direction) {
    final orders = toList();
    final newList = <SortOrder>[];

    for (final order in orders) {
      newList.add(order.withDirection(direction));
    }

    return Sort.by(orders);
  }

  // ---------------------------------------------------------------------------
  // Transformations
  // ---------------------------------------------------------------------------

  /// Returns a copy of this [Sort] with all orders set to **descending**.
  ///
  /// ```dart
  /// final desc = sort.descending();
  /// ```
  Sort descending() => _withDirection(SortDirection.DESC);

  /// Returns a copy of this [Sort] with all orders set to **ascending**.
  ///
  /// ```dart
  /// final asc = sort.ascending();
  /// ```
  Sort ascending() => _withDirection(SortDirection.ASC);

  // ---------------------------------------------------------------------------
  // Introspection
  // ---------------------------------------------------------------------------

  /// Returns `true` if this sort contains at least one [SortOrder].
  ///
  /// ```dart
  /// if (sort.isSorted()) {
  ///   print("Sort is active");
  /// }
  /// ```
  bool isSorted() => toList().isNotEmpty;

  /// Returns `true` if this sort contains no orders.
  ///
  /// ```dart
  /// if (sort.isEmpty()) print("No sorting applied");
  /// ```
  bool isEmpty() => toList().isEmpty;

  // ---------------------------------------------------------------------------
  // Combination & Reversal
  // ---------------------------------------------------------------------------

  /// Combines this sort with another [sort], returning a new [Sort].
  ///
  /// Orders from the provided [sort] are appended.
  ///
  /// ```dart
  /// final combined = sort1.and(sort2);
  /// ```
  Sort and(Sort sort) {
    final current = toList();
    for (final order in sort.toList()) {
      current.add(order);
    }

    return Sort.by(current);
  }

  /// Produces a new [Sort] where each [SortOrder] has its direction reversed.
  ///
  /// ```dart
  /// final reversed = sort.reverse(sort);
  /// ```
  Sort reverse(Sort sort) {
    final reversed = <SortOrder>[];
    for (final order in toList()) {
      reversed.add(order.reverse());
    }

    return Sort.by(reversed);
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// Retrieves the [SortOrder] associated with the given [property],
  /// or returns `null` if no matching order exists.
  ///
  /// ```dart
  /// final order = sort.getFor("username");
  /// ```
  SortOrder? getFor(String property) => toList().find((order) => order.property.equals(property));

  @override
  List<Object?> equalizedProperties() => [toList()];

  @override
  String toString() {
    if (isEmpty()) {
      return "Sort(UNSORTED)";
    }
    return "Sort(${toList()})";
  }
}