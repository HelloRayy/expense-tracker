/// Result representing the minimal atomic database delta for category assignments.
class CategoryDiffResult {
  /// Transaction IDs that must be assigned/reassigned to the selected category.
  final List<int> toAssign;

  /// Transaction IDs that must be unassigned (set categoryId = null).
  final List<int> toUnassign;

  /// Count of transactions whose category status remains untouched.
  final int unchangedCount;

  const CategoryDiffResult({
    required this.toAssign,
    required this.toUnassign,
    required this.unchangedCount,
  });

  bool get hasChanges => toAssign.isNotEmpty || toUnassign.isNotEmpty;

  int get totalChanges => toAssign.length + toUnassign.length;
}

/// Pure Dart business logic evaluator for Category-to-Transaction assignment.
/// Computes isolated diffs between initial database states and pending client-side selections.
class CategoryAssignEvaluator {
  CategoryAssignEvaluator._();

  /// Computes the minimal set of database updates required.
  ///
  /// - [initialCategories]: Mapping of `transactionId` -> current `categoryId` in DB.
  /// - [pendingSelectedIds]: Set of `transactionId`s currently checked by the user.
  /// - [selectedCategoryId]: The target category identifier being assigned.
  static CategoryDiffResult computeDiff({
    required Map<int, String?> initialCategories,
    required Set<int> pendingSelectedIds,
    required String selectedCategoryId,
  }) {
    final List<int> toAssign = [];
    final List<int> toUnassign = [];
    int unchanged = 0;

    for (final entry in initialCategories.entries) {
      final int id = entry.key;
      final String? initialCat = entry.value;
      final bool isChecked = pendingSelectedIds.contains(id);

      if (isChecked) {
        if (initialCat == selectedCategoryId) {
          // Already assigned to this category and still checked -> No-Op
          unchanged++;
        } else {
          // Newly checked (was null or in another category) -> Assign / Re-assign
          toAssign.add(id);
        }
      } else {
        if (initialCat == selectedCategoryId) {
          // Was previously in this category, but now unchecked -> Unassign to null
          toUnassign.add(id);
        } else {
          // Was not in this category and remains unchecked -> No-Op
          unchanged++;
        }
      }
    }

    return CategoryDiffResult(
      toAssign: toAssign,
      toUnassign: toUnassign,
      unchangedCount: unchanged,
    );
  }

  /// Derives initial checked set based on whether transaction belongs to [selectedCategoryId].
  static Set<int> buildInitialSelection({
    required Map<int, String?> initialCategories,
    required String selectedCategoryId,
  }) {
    final Set<int> initial = {};
    for (final entry in initialCategories.entries) {
      if (entry.value == selectedCategoryId) {
        initial.add(entry.key);
      }
    }
    return initial;
  }
}
