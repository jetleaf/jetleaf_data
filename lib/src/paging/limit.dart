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

/// {@template limiting}
/// Marker mixin indicating that a type provides limiting behavior.
///
/// This mixin itself defines no behavior. It is used purely as a semantic
/// indicator so that frameworks and utilities can detect whether a type
/// participates in limiting operations (for example, pagination limits,
/// maximum result sizes, or query bounds).
///
/// Typically, this is implemented by classes such as [Limit], which define
/// the actual semantics of limits.
///
/// ### Example
/// ```dart
/// class MyLimiter with Limiting {
///   final int maxItems;
///   MyLimiter(this.maxItems);
/// }
///
/// bool hasLimit(Limiting object) {
///   return object is Limiting;
/// }
/// ```
///
/// ### Notes
/// - This mixin is intentionally empty.
/// - It acts similar to a “marker interface” in Java.
/// - Use it to tag classes that conceptually impose limits.
/// {@endtemplate}
abstract mixin class Limiting {}

/// {@template limit}
/// A value object representing an upper bound (limit) typically used in
/// pagination, query constraints, or result-size restrictions.
///
/// A [Limit] expresses either:
/// - a **finite limit**: created via [Limit.of], representing a concrete
///   non-negative maximum, or
/// - an **unbounded state**: created via [Limit.unlimited], representing no
///   restriction.
///
/// This abstraction helps unify pagination and bounded queries while
/// maintaining immutability and type safety.
///
/// ### Creation Examples
/// ```dart
/// final limited = Limit.of(10);     // Max 10 items
/// final unlimited = Limit.unlimited(); // No maximum
///
/// print(limited.isLimited()); // true
/// print(unlimited.isUnlimited()); // true
/// ```
///
/// ### Design Notes
/// - Negative values are not allowed; enforcing correctness at construction.
/// - Subtypes must implement [max] and [isLimited].
/// - Use [isUnlimited] to check for unbounded conditions instead of
///   manually comparing values.
///
/// ### Example Behavior
/// | Input             | Result Type   | isLimited | max()    |
/// |-------------------|---------------|-----------|----------|
/// | `Limit.of(5)`     | `_Limited`    | `true`    | `5`      |
/// | `Limit.unlimited()` | `_Unlimited` | `false`   | n/a      |
///
/// ### See Also
/// - [Limiting]
/// - pagination utilities or query builders that depend on limits.
/// {@endtemplate}
sealed class Limit extends Limiting implements EqualsAndHashCode {
  /// Creates an unlimited (unbounded) limit.
  ///
  /// Equivalent to:  
  /// ```dart
  /// final limit = Limit.unlimited();
  /// ```
  static Limit unlimited() => _Unlimited._();

  /// Creates a finite limit with the given [max] value.
  ///
  /// The number **must be non-negative** and represents the maximum number
  /// of items or elements allowed.
  ///
  /// ### Example
  /// ```dart
  /// final limit = Limit.of(20);
  /// print(limit.max()); // 20
  /// ```
  static Limit of(int max) => _Limited(max);

  /// Returns the concrete maximum number of elements allowed by this limit.
  ///
  /// This method **must only** be invoked when [isLimited] is `true`.  
  /// Calling this on an unlimited instance is invalid and may result in an
  /// exception, since unlimited limits do not define a numeric upper bound.
  int max();

  /// Returns `true` if this limit represents a concrete, non-negative maximum.
  ///
  /// When this returns `true`, [max] is guaranteed to be callable and meaningful.
  bool isLimited() => this is _Limited;

  /// Returns `true` if this limit has no upper bound.
  ///
  /// Unlimited limits impose no numeric constraint, and therefore do **not**
  /// support calls to [max].
  bool isUnlimited() => !isLimited();
}

/// {@template limited}
/// Internal implementation of a finite [Limit] representing a concrete,
/// non-negative maximum value.
///
/// Instances of `_Limited` are created exclusively through the public
/// factory method [Limit.of]. This ensures that:
/// - values are validated at construction time,
/// - user code interacts only with the abstract [Limit] type,
/// - the type hierarchy remains encapsulated.
///
/// ### Example
/// ```dart
/// final limit = Limit.of(10);
///
/// if (limit.isLimited()) {
///   print(limit.max()); // 10
/// }
/// ```
///
/// ### Design Notes
/// - `_Limited` is immutable.
/// - `_max` must always be non-negative.
/// - Equality is delegated to the value of `_max`.
///
/// {@endtemplate}
final class _Limited extends Limit {
  /// The concrete maximum value represented by this limit.
  final int _max;

  /// {@macro limited}
  _Limited(this._max);

  @override
  List<Object?> equalizedProperties() => [_max];
  
  @override
  int max() => _max;

  @override
  bool isLimited() => true;
}

/// {@template unlimited}
/// Internal implementation of an unbounded [Limit] that represents the absence
/// of any maximum constraint.
///
/// Instances of `_Unlimited` are created exclusively through
/// [Limit.unlimited], ensuring that external code interacts only with the
/// abstract [Limit] type rather than the internal implementation.
///
/// This class models a “no limit” scenario, commonly used in query builders,
/// pagination systems, or result constraints where unbounded retrieval is
/// allowed.
///
/// ### Example
/// ```dart
/// final limit = Limit.unlimited();
///
/// print(limit.isUnlimited()); // true
/// print(limit.isLimited());   // false
///
/// // Calling max() is invalid:
/// // limit.max(); // ❌ throws UnsupportedOperationException
/// ```
///
/// ### Design Notes
/// - Calling [max] is unsupported and will always throw.
/// - Equality is based solely on the runtime type.
/// - `_Unlimited` is a singleton-style class (created only via a private
///   constructor).
/// {@endtemplate}
final class _Unlimited extends Limit {
  /// {@macro unlimited}
  _Unlimited._();

  @override
  List<Object?> equalizedProperties() => [runtimeType];

  @override
  bool isLimited() => false;

  @override
  int max() => throw UnsupportedOperationException("Always check isLimited() because unlimited limits do not define a max value");
}