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

import 'dart:collection';

import 'package:jetleaf_lang/lang.dart';

/// {@template scroll_direction}
/// Represents the direction of a **scrolling action**, such as navigating
/// through paginated results, lists, or timeline-like structures.
///
/// This enum is commonly used in cursor-based pagination, UI navigation,  
/// request traversal, and streaming APIs.
///
/// ### Directions
/// - **[ScrollDirection.FORWARD]** → Moves toward later/next items  
/// - **[ScrollDirection.BACKWARD]** → Moves toward earlier/previous items  
///
/// ### Usage Example
/// ```dart
/// ScrollDirection direction = ScrollDirection.FORWARD;
///
/// // Reverse scrolling (FORWARD → BACKWARD)
/// direction = direction.reverse();
/// ```
///
/// ### Behavior Notes
/// - The enum is intentionally minimal and highly ergonomic for pagination use.
/// - [reverse] always swaps to the opposite direction.
/// - No-op states do not exist; both values always toggle deterministically.
/// {@endtemplate}
enum ScrollDirection {
  /// Scrolls **forward**, usually meaning:
  /// - toward next elements in a list
  /// - advancing a cursor or page
  /// - moving chronologically forward
  FORWARD,

  /// Scrolls **backward**, usually meaning:
  /// - toward previous elements
  /// - moving to an earlier cursor or page
  /// - navigating to older items
  BACKWARD;

  /// Returns the **opposite** scroll direction.
  ///
  /// - `FORWARD → BACKWARD`  
  /// - `BACKWARD → FORWARD`
  ///
  /// ```dart
  /// final reversed = ScrollDirection.FORWARD.reverse(); // BACKWARD
  /// ```
  ScrollDirection reverse() => this == FORWARD ? BACKWARD : FORWARD;
}

/// {@template scroll_position}
/// Represents a **position in a scrollable or paginated collection**.
///
/// This abstract interface provides a common abstraction for different types
/// of scrolling strategies, including:
/// - **Key-set based scrolling** (cursor-based)
/// - **Offset-based scrolling** (index-based)
///
/// ### Usage Example
/// ```dart
/// // Key-set initial position
/// final initialKeyset = ScrollPosition.keySet();
///
/// // Key-set forward scrolling
/// final nextPage = ScrollPosition.forward({"id": 123});
///
/// // Offset-based scrolling
/// final offsetPos = ScrollPosition.offSet(10);
/// ```
///
/// ### Design Notes
/// - Implementations must provide [isInitial] to indicate whether the scroll
///   position represents the start of the collection.
/// - Static factory methods provide a convenient way to create commonly used
///   positions.
/// - Suitable for repository queries, API pagination, or UI scroll tracking.
///
/// ### See Also
/// - [KeysetScrollPosition]
/// - [OffsetScrollPosition]
/// - [ScrollDirection]
/// {@endtemplate}
abstract interface class ScrollPosition with EqualsAndHashCode {
  /// Returns `true` if this scroll position represents the **initial position**
  /// of the collection or dataset.
  ///
  /// ### Example
  /// ```dart
  /// final pos = ScrollPosition.keySet();
  /// print(pos.isInitial()); // true
  /// ```
  bool isInitial();

  /// Creates a **key-set scroll position at the initial position**.
  ///
  /// ### Example
  /// ```dart
  /// final initial = ScrollPosition.keySet();
  /// ```
  static KeysetScrollPosition keySet() => KeysetScrollPosition.initial();

  /// Creates a **key-set scroll position moving forward** from the given [keys].
  ///
  /// ### Example
  /// ```dart
  /// final next = ScrollPosition.forward({"id": 100});
  /// ```
  static KeysetScrollPosition forward(Map<String, Object> keys) => KeysetScrollPosition.of(ScrollDirection.FORWARD, keys);

  /// Creates a **key-set scroll position moving backward** from the given [keys].
  ///
  /// ### Example
  /// ```dart
  /// final previous = ScrollPosition.backward({"id": 50});
  /// ```
  static KeysetScrollPosition backward(Map<String, Object> keys) => KeysetScrollPosition.of(ScrollDirection.BACKWARD, keys);

  /// Creates an **offset-based scroll position** at the given [offset].
  ///
  /// If [offset] is `null`, returns the initial offset (0).
  ///
  /// ### Example
  /// ```dart
  /// final initial = ScrollPosition.offSet();
  /// final offset10 = ScrollPosition.offSet(10);
  /// ```
  static OffsetScrollPosition offSet([int? offset]) {
    if (offset == null) {
      return OffsetScrollPosition.initial();
    }

    return OffsetScrollPosition.of(offset);
  }
}

/// {@template key_set_scroll_position}
/// Represents a **key-set (cursor-based) scroll position** in a collection.
///
/// Each instance contains:
/// - a map of `keys` representing the current cursor position  
/// - a `direction` indicating whether the scroll is **forward** or **backward**
///
/// This class is used in **cursor-based pagination** or any context where
/// navigating a dataset relies on the last known key values rather than an offset.
///
/// ### Usage Example
/// ```dart
/// // Initial position (forward)
/// final initial = KeysetScrollPosition.initial();
///
/// // Forward scroll from a specific key
/// final nextPage = KeysetScrollPosition.of(
///   ScrollDirection.FORWARD,
///   {"id": 123},
/// );
///
/// // Reverse scrolling
/// final previousPage = nextPage.reverse();
/// ```
///
/// ### Design Notes
/// - Immutable once created (keys are wrapped in [UnmodifiableMapView])  
/// - `EMPTY_FORWARD` and `EMPTY_BACKWARD` singletons optimize empty key sets  
/// - Provides convenient helpers for scrolling and reversing direction  
/// - Works seamlessly with [ScrollPosition] abstraction
/// {@endtemplate}
final class KeysetScrollPosition implements ScrollPosition {
  /// Singleton representing an empty forward scroll position.
  static final KeysetScrollPosition EMPTY_FORWARD = KeysetScrollPosition(ScrollDirection.FORWARD, {});

  /// Singleton representing an empty backward scroll position.
  static final KeysetScrollPosition EMPTY_BACKWARD = KeysetScrollPosition(ScrollDirection.BACKWARD, {});

  /// The cursor keys representing the current scroll position.
  final Map<String, Object> keys;

  /// The direction of the scroll.
  final ScrollDirection direction;

  /// {@macro key_set_scroll_position}
  KeysetScrollPosition(this.direction, this.keys);

  /// Returns the **initial forward scroll position**.
  ///
  /// Equivalent to an empty cursor moving forward.
  ///
  /// ```dart
  /// final initial = KeysetScrollPosition.initial();
  /// print(initial.isInitial()); // true
  /// ```
  static KeysetScrollPosition initial() => EMPTY_FORWARD;

  /// Creates a [KeysetScrollPosition] from the given [direction] and [keys].
  ///
  /// If [keys] is empty, returns the corresponding singleton ([EMPTY_FORWARD] or
  /// [EMPTY_BACKWARD]) to optimize memory usage.
  ///
  /// ### Example
  /// ```dart
  /// final pos = KeysetScrollPosition.of(
  ///   ScrollDirection.FORWARD,
  ///   {"id": 42},
  /// );
  /// ```
  static KeysetScrollPosition of(ScrollDirection direction, Map<String, Object> keys) {
    if (keys.isEmpty) {
      return direction == ScrollDirection.FORWARD ? EMPTY_FORWARD : EMPTY_BACKWARD;
    }

    return KeysetScrollPosition(direction, UnmodifiableMapView(keys));
  }

  /// Returns `true` if this position scrolls **forward**.
  ///
  /// ```dart
  /// print(position.scrollsForward()); // true or false
  /// ```
  bool scrollsForward() => direction == ScrollDirection.FORWARD;

  /// Returns `true` if this position scrolls **backward**.
  ///
  /// ```dart
  /// print(position.scrollsBackward()); // true or false
  /// ```
  bool scrollsBackward() => direction == ScrollDirection.BACKWARD;

  /// Returns a new scroll position moving **forward**.
  ///
  /// If already forward, returns `this`.
  KeysetScrollPosition scrollForward() => direction == ScrollDirection.FORWARD 
    ? this
    : KeysetScrollPosition(ScrollDirection.FORWARD, keys);

  /// Returns a new scroll position moving **backward**.
  ///
  /// If already backward, returns `this`.
  KeysetScrollPosition scrollBackward() => direction == ScrollDirection.BACKWARD 
    ? this
    : KeysetScrollPosition(ScrollDirection.BACKWARD, keys);

  /// Returns a new [KeysetScrollPosition] with **reversed direction**.
  ///
  /// ```dart
  /// final reversed = position.reverse();
  /// ```
  KeysetScrollPosition reverse() => KeysetScrollPosition(direction.reverse(), keys);

  @override
  bool isInitial() => keys.isEmpty;

  @override
  List<Object?> equalizedProperties() => [direction, keys];
}

/// {@template offset_scroll_position}
/// Represents an **offset-based scroll position**, commonly used for
/// index-based pagination (e.g., SQL `LIMIT/OFFSET`, list slicing,
/// sequential pagination).
///
/// This model is complementary to cursor-based pagination and is useful
/// when:
/// - items are addressable by numeric index  
/// - consistent ordering is guaranteed  
/// - simple “skip N items” semantics are needed  
///
/// An offset of `-1` indicates the **initial position**, meaning no scroll
/// has yet occurred.
///
/// ### Usage Example
/// ```dart
/// // Initial position
/// final pos = OffsetScrollPosition.initial();
///
/// // Advance by 20 items
/// final next = pos.advanceBy(20);
///
/// // Directly construct offset 40
/// final at40 = OffsetScrollPosition.of(40);
/// ```
///
/// ### Design Notes
/// - Offsets must always be non-negative when created via [of].  
/// - The initial offset is internally represented as -1.  
/// - Increasing the offset is done via [advanceBy], which returns a new instance.  
/// - Implements [ScrollPosition] for interoperability with keyset pagination.  
///
/// ### See Also
/// - [ScrollPosition]  
/// - [KeySetScrollPosition]  
/// - [ScrollDirection]  
/// {@endtemplate}
final class OffsetScrollPosition implements ScrollPosition {
  /// The singleton instance representing the **initial** offset.
  ///
  /// Internal value: -1
  static final OffsetScrollPosition INITIAL = OffsetScrollPosition(-1);

  /// Internal raw offset value.
  ///
  /// - `-1` represents the initial state  
  /// - any other value represents the actual offset  
  final int _offset;

  /// {@macro offset_scroll_position}
  OffsetScrollPosition(this._offset);

  /// Returns the **initial** [OffsetScrollPosition].
  ///
  /// ```dart
  /// final pos = OffsetScrollPosition.initial();
  /// print(pos.isInitial()); // true
  /// ```
  static OffsetScrollPosition initial() => INITIAL;

  /// Creates a new [OffsetScrollPosition] with the given positive [offset].
  ///
  /// Throws an assertion error if [offset] is negative.
  ///
  /// ```dart
  /// final pos = OffsetScrollPosition.of(30);
  /// ```
  static OffsetScrollPosition of(int offset) {
    assert(offset >= 0, "Offset cannot be negative");
    return OffsetScrollPosition(offset);
  }

  /// Returns the current offset value.
  ///
  /// This method throws an assertion error if called on the initial position.
  /// Always check [isInitial] before calling:
  ///
  /// ```dart
  /// if (!pos.isInitial()) {
  ///   print(pos.getOffset());
  /// }
  /// ```
  int getOffset() {
    assert(_offset >= 0, "Offset cannot be negative. When using initial, always check isInitial() first.");
    return _offset;
  }

  /// Advances the current offset by the given [advance] amount.
  ///
  /// If the position is *initial*, the new offset becomes the advance amount.
  ///
  /// Ensures the resulting offset is never negative.
  ///
  /// ```dart
  /// final pos = OffsetScrollPosition.of(10);
  /// final next = pos.advanceBy(15); // offset = 25
  /// ```
  OffsetScrollPosition advanceBy(int advance) {
    final value = isInitial() ? advance : _offset.plus(advance);
    return OffsetScrollPosition(value.isLessThan(0) ? 0 : value);
  }

  @override
  bool isInitial() => this == INITIAL || _offset == -1;

  @override
  List<Object?> equalizedProperties() => [_offset];
}