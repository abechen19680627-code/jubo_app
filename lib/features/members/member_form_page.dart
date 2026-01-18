import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'providers/member_providers.dart';

class MemberFormPage extends ConsumerStatefulWidget {
  const MemberFormPage({super.key, this.memberId});

  final String? memberId;

  @override
  ConsumerState<MemberFormPage> createState() => _MemberFormPageState();
}

class _MemberFormPageState extends ConsumerState<MemberFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  DateTime? _birthday;
  bool _isSubmitting = false;
  bool _didLoad = false;

  bool get _isEditing =>
      widget.memberId != null && widget.memberId!.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial = _birthday ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _birthday = picked;
      _birthdayController.text = _formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      await ref.read(memberActionsProvider).saveMember(
            id: widget.memberId,
            name: _nameController.text.trim(),
            birthday: _birthday!,
          );
      if (!mounted) {
        return;
      }
      context.pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('儲存成員失敗。')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? '編輯成員' : '新增成員';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: _isEditing
            ? _buildEditContent(context)
            : _buildForm(context),
      ),
    );
  }

  Widget _buildEditContent(BuildContext context) {
    final memberId = widget.memberId!;
    final memberAsync = ref.watch(memberByIdProvider(memberId));
    return memberAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => _ErrorView(
        message: '載入成員失敗。',
        onBack: () => context.pop(),
      ),
      data: (member) {
        if (member == null) {
          return _ErrorView(
            message: '找不到成員。',
            onBack: () => context.pop(),
          );
        }
        if (!_didLoad) {
          _didLoad = true;
          _nameController.text = member.name;
          _birthday = member.birthday;
          _birthdayController.text = _formatDate(member.birthday);
        }
        return _buildForm(context);
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '姓名',
                hintText: '請輸入成員姓名',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '請輸入姓名。';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _birthdayController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: '生日',
                hintText: '請選擇日期',
              ),
              onTap: _pickBirthday,
              validator: (_) {
                if (_birthday == null) {
                  return '請選擇生日。';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? '儲存中...' : '儲存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onBack,
            child: const Text('返回'),
          ),
        ],
      ),
    );
  }
}
