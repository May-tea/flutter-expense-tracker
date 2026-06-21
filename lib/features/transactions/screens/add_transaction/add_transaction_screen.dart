import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../models/expense_category.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/add_transaction/category_grid.dart';
import '../../widgets/add_transaction/form_label.dart';
import '../../widgets/add_transaction/input_card.dart';
import '../../widgets/add_transaction/transaction_type_chip.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this._transaction});

  final TransactionModel? _transaction;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool get _isEditing => widget._transaction != null;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController;
  late final TextEditingController _titleController;

  TransactionType _selectedType = .expense;
  ExpenseCategory _selectedCategory = .food;
  DateTime _selectedDate = .now();

  ExpenseCategory get _effectiveCategory =>
      _selectedType == .income ? .income : _selectedCategory;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _amountController = .new();
    _titleController = .new();

    final tx = widget._transaction;

    if (tx != null) {
      _amountController.text = tx.amount.toString();
      _titleController.text = tx.title;
      _selectedDate = tx.date;
      _selectedType = tx.type;
      _selectedCategory = tx.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() => _selectedDate = pickedDate);
  }

  TransactionModel _buildTransaction() {
    return TransactionModel(
      id: widget._transaction?.id ?? '',
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: _selectedType,
      category: _effectiveCategory,
      date: _selectedDate,
      createdAt: widget._transaction?.createdAt ?? DateTime.now(),
    );
  }

  Future<bool> _persist(TransactionModel transaction) async {
    final service = ref.read(transactionServiceProvider);
    final operation = _isEditing
        ? service.updateTransaction(transaction)
        : service.addTransaction(transaction);

    bool changedSuccessfully = true;

    try {
      await operation.timeout(const .new(milliseconds: 500));
    } catch (_) {
      changedSuccessfully = false;
    }

    return changedSuccessfully;
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final changedSuccessfully = await _persist(_buildTransaction());

      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: !changedSuccessfully,
        message: _isEditing && changedSuccessfully
            ? 'Transaction updated.'
            : _isEditing && !changedSuccessfully
            ? 'Updated locally! (syncs when online).'
            : changedSuccessfully
            ? 'Transaction saved.'
            : 'Saved locally! (syncs when online).',
      );

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: true,
        message: 'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: .new(fontSize: screenWidth * 0.05, fontWeight: .bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: .all(screenWidth * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: .start,
              spacing: screenWidth * 0.04,
              children: [
                const FormLabel(label: 'Amount'),
                InputCard(
                  child: TextFormField(
                    key: const ValueKey('amount'),
                    controller: _amountController,
                    keyboardType: const .numberWithOptions(decimal: true),
                    autovalidateMode: .onUserInteraction,
                    textAlign: .center,
                    style: .new(
                      fontSize: screenWidth * 0.13,
                      fontWeight: .w700,
                      color: colorScheme.onSurface,
                    ),
                    decoration: .new(
                      border: .none,
                      hintText: '0.00',
                      hintStyle: .new(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: .w700,
                      ),
                      prefixText: '\$ ',
                      prefixStyle: .new(
                        fontSize: screenWidth * 0.13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    validator: AppValidators.amount,
                  ),
                ),
                const FormLabel(label: 'Title'),
                InputCard(
                  child: TextFormField(
                    key: const ValueKey('title'),
                    controller: _titleController,
                    autovalidateMode: .onUserInteraction,
                    style: .new(
                      fontSize: screenWidth * 0.05,
                      fontWeight: .w700,
                      color: colorScheme.onSurface,
                    ),
                    decoration: .new(
                      border: .none,
                      hintText: 'What was this for?',
                      hintStyle: .new(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: .w700,
                      ),
                    ),
                    validator: AppValidators.title,
                  ),
                ),
                Row(
                  mainAxisAlignment: .center,
                  spacing: screenWidth * 0.04,
                  children: [
                    TransactionTypeChip(
                      label: 'Expense',
                      type: .expense,
                      selectedType: _selectedType,
                      onSelected: () {
                        setState(() => _selectedType = .expense);
                      },
                    ),
                    TransactionTypeChip(
                      label: 'Income',
                      type: .income,
                      selectedType: _selectedType,
                      onSelected: () {
                        setState(() => _selectedType = .income);
                      },
                    ),
                  ],
                ),
                if (_selectedType == .expense)
                  CategoryGrid(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (cat) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                InputCard(
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Row(
                        spacing: screenWidth * 0.02,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.primary,
                            size: screenWidth * 0.05,
                          ),
                          Text(
                            DateFormat.yMMMd().format(_selectedDate),
                            style: .new(
                              fontSize: screenWidth * 0.04,
                              fontWeight: .w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _selectDate,
                        child: const Text('Select'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: .symmetric(vertical: screenWidth * 0.045),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(screenWidth * 0.03),
                      ),
                    ),
                    child: _isSaving
                        ? AppLoadingIndicator(
                            size: screenWidth * 0.049,
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          )
                        : Text(
                            _isEditing
                                ? 'Update Transaction'
                                : 'Save Transaction',
                            style: .new(
                              fontSize: screenWidth * 0.045,
                              fontWeight: .bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
