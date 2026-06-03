import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/screen_utils.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../models/expense_category.dart';
import '../../models/transaction_model.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/add_transaction/category_grid.dart';
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

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    try {
      final transactionService = ref.read(transactionServiceProvider);

      final isValid = _formKey.currentState!.validate();

      if (!isValid) return;

      setState(() => _isSaving = true);

      final amount = double.tryParse(_amountController.text.trim());

      if (amount == null || amount <= 0) {
        setState(() => _isSaving = false);
        return;
      }

      final title = _titleController.text.trim();

      final transaction = TransactionModel(
        id: widget._transaction?.id ?? '',
        title: title,
        amount: amount,
        type: _selectedType,
        category: _selectedType == .income ? .income : _selectedCategory,
        date: _selectedDate,
        createdAt: widget._transaction?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        await transactionService.updateTransaction(transaction);
      } else {
        await transactionService.addTransaction(transaction);
      }

      if (!mounted) return;

      AppSnackBar.show(
        context,
        isError: false,
        message: _isEditing
            ? 'Transaction updated successfully.'
            : 'Transaction added successfully.',
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
      if (mounted) {
        setState(() => _isSaving = false);
      }
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
                const _FormLabel(label: 'Amount'),
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
                const _FormLabel(label: 'Title'),
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
                    child: Text(
                      _isEditing ? 'Update Transaction' : 'Save Transaction',
                      style: TextStyle(
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

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenUtils.width(context);

    return Text(
      label,
      style: .new(fontSize: screenWidth * 0.05, fontWeight: .w500),
    );
  }
}
