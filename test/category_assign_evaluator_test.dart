import 'package:flutter_test/flutter_test.dart';
import 'package:jajan_tracker/features/categories/services/category_assign_evaluator.dart';

void main() {
  group('CategoryAssignEvaluator Business Logic Tests', () {
    const targetCat = 'Makanan';

    test('Initial selection accurately includes only transactions matching selectedCategoryId', () {
      final initialMap = {
        1: 'Makanan',
        2: null,
        3: 'Kopi & Minum',
        4: 'Makanan',
      };

      final initialSelected = CategoryAssignEvaluator.buildInitialSelection(
        initialCategories: initialMap,
        selectedCategoryId: targetCat,
      );

      expect(initialSelected, equals({1, 4}));
    });

    test('No-op: Unchanged selections yield empty diff', () {
      final initialMap = {
        1: 'Makanan',
        2: null,
        3: 'Kopi & Minum',
      };

      final diff = CategoryAssignEvaluator.computeDiff(
        initialCategories: initialMap,
        pendingSelectedIds: {1}, // exactly unchanged
        selectedCategoryId: targetCat,
      );

      expect(diff.hasChanges, isFalse);
      expect(diff.totalChanges, 0);
      expect(diff.toAssign, isEmpty);
      expect(diff.toUnassign, isEmpty);
      expect(diff.unchangedCount, 3);
    });

    test('Assign: Checking an uncategorized transaction (null -> Makanan)', () {
      final initialMap = {
        1: null,
        2: null,
      };

      final diff = CategoryAssignEvaluator.computeDiff(
        initialCategories: initialMap,
        pendingSelectedIds: {1}, // user checked id 1
        selectedCategoryId: targetCat,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.toAssign, equals([1]));
      expect(diff.toUnassign, isEmpty);
      expect(diff.unchangedCount, 1);
    });

    test('Re-assign: Checking a transaction belonging to another category (Kopi -> Makanan)', () {
      final initialMap = {
        1: 'Kopi & Minum',
        2: 'Transport',
      };

      final diff = CategoryAssignEvaluator.computeDiff(
        initialCategories: initialMap,
        pendingSelectedIds: {1}, // reassign id 1 to Makanan
        selectedCategoryId: targetCat,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.toAssign, equals([1]));
      expect(diff.toUnassign, isEmpty);
      expect(diff.unchangedCount, 1);
    });

    test('Unassign: Unchecking a transaction currently in this category (Makanan -> null)', () {
      final initialMap = {
        1: 'Makanan',
        2: 'Makanan',
      };

      final diff = CategoryAssignEvaluator.computeDiff(
        initialCategories: initialMap,
        pendingSelectedIds: {2}, // id 1 unchecked
        selectedCategoryId: targetCat,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.toAssign, isEmpty);
      expect(diff.toUnassign, equals([1]));
      expect(diff.unchangedCount, 1);
    });

    test('Complex Multi-transaction Batch: simultaneously assign, reassign, unassign, and keep unchanged', () {
      final initialMap = {
        10: 'Makanan',      // will be unassigned (unchecked)
        20: 'Makanan',      // will stay unchanged (checked)
        30: null,           // will be assigned (checked)
        40: 'Transport',     // will be reassigned (checked)
        50: 'Kopi & Minum', // will stay untouched (unchecked)
        60: null,           // will stay untouched (unchecked)
      };

      final pendingSelection = {20, 30, 40};

      final diff = CategoryAssignEvaluator.computeDiff(
        initialCategories: initialMap,
        pendingSelectedIds: pendingSelection,
        selectedCategoryId: targetCat,
      );

      expect(diff.hasChanges, isTrue);
      expect(diff.totalChanges, 3);
      expect(diff.toAssign, containsAll([30, 40]));
      expect(diff.toUnassign, equals([10]));
      expect(diff.unchangedCount, 3); // 20, 50, 60
    });
  });
}
