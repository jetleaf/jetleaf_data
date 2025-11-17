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

import 'package:jetleaf_core/annotation.dart';
import 'package:jetleaf_lang/lang.dart';
import 'package:jetleaf_pod/pod.dart';

import '../annotation.dart';
import 'core/default_repository_context.dart';
import 'core/repository_context.dart';

/// {@template jetleaf_data_auto_configuration}
/// Auto-configuration pod for **Jetleaf Data module**.
///
/// This configuration registers essential pods for repository
/// management, including:
/// - [RepositoryAwareProcessor] for automatic executor injection
/// - [RepositoryContext] for repository definitions and execution
///
/// ### Usage Example
/// ```dart
/// final config = DataAutoConfiguration();
/// final context = config.repositoryContext();
/// final processor = config.repositoryAwareProcessor(context);
/// ```
///
/// ### Design Notes
/// - Uses [@AutoConfiguration] and [@Named] for declarative pod registration.
/// - All pods are marked with [DesignRole.INFRASTRUCTURE].
/// - [RepositoryContext] is registered conditionally if missing, ensuring
///   a singleton default context is available.
///
/// ### See Also
/// - [RepositoryAwareProcessor]
/// - [RepositoryContext]
/// - [DefaultRepositoryContext]
/// {@endtemplate}
@AutoConfiguration()
@Named(DataAutoConfiguration.NAME)
@ComponentScan(includeFilters: [ComponentScanFilter(FilterType.ANNOTATION, classes: [ClassType<Repository>()])])
final class DataAutoConfiguration {
  /// The name of this data configuration pod.
  ///
  /// Used internally for identification and logging purposes.
  static const String NAME = "jetleaf.data.configuration";

  /// The pod name for the repository context.
  ///
  /// Used to register and retrieve the [RepositoryContext] from the
  /// application context. This ensures a singleton context is available
  /// for repository operations.
  static const String REPOSITORY_CONTEXT_POD_NAME = "jetleaf.data.repositoryContext";

  /// Registers a [RepositoryContext] pod if none exists.
  ///
  /// Uses [DefaultRepositoryContext] as the fallback implementation.
  /// Marked as [DesignRole.INFRASTRUCTURE] for internal use.
  @Role(DesignRole.INFRASTRUCTURE)
  @Pod(value: REPOSITORY_CONTEXT_POD_NAME)
  @ConditionalOnMissingPod(values: [RepositoryContext])
  RepositoryContext repositoryContext() => DefaultRepositoryContext();
}