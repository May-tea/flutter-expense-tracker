import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key, this.expense});

  final ExpenseModel? expense;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final ExpenseService _expenseService = .instance;

  final TextEditingController _titleController = .new();
  final TextEditingController _amountController = .new();

  ExpenseCategory _selectedCategory = .other;

  DateTime _selectedDate = .now();

  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    if (expense == null) return;

    _titleController.text = expense.title;

    _amountController.text = expense.amount.toString();

    _selectedCategory = expense.category;

    _selectedDate = expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: .now(),
    );

    if (pickedDate == null) return;

    setState(() => _selectedDate = pickedDate);
  }

  Future<void> _saveExpense() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) return;

    final title = _titleController.text.trim();

    final amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) return;

    final expense = ExpenseModel(
      id: widget.expense?.id ?? '',
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      createdAt: widget.expense?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      await _expenseService.updateExpense(expense);
    } else {
      await _expenseService.addExpense(expense);
    }

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');

                if (amount == null) {
                  return 'Please enter a valid amount.';
                }

                if (amount <= 0) {
                  return 'Amount must be greater than zero.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _selectedCategory,
              items: ExpenseCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
                TextButton(
                  onPressed: _selectDate,
                  child: const Text('Select Date'),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExpense,
                child: Text(_isEditing ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
