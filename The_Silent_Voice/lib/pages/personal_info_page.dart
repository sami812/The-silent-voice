import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_silent_voice/sign/user_cache.dart';

/// # Personal Info Page
///
/// Lets the user store a preferred name, pronouns, phone number, and
/// address. These values can be referenced by the AI suggestion service
/// using placeholders ({{name}}, {{pronoun}}, {{phone}}, {{address}}) so
/// suggested responses can include real personal info without the user
/// typing it out every time - e.g. the AI can suggest "My name is {{name}}"
/// and the app fills in the real value locally before showing/speaking it.
///
/// Any field left blank just won't get filled in if the AI happens to
/// reference it - nothing forces the user to share all of these.
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late final TextEditingController _preferredName;
  String? _gender; // 'male' or 'female'
  late final TextEditingController _phone;
  late final TextEditingController _address;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = userCache ?? {};
    _preferredName = TextEditingController(text: data['preferredName'] ?? '');
    _gender = data['gender'] as String?;
    _phone = TextEditingController(text: data['phone'] ?? '');
    _address = TextEditingController(text: data['address'] ?? '');
  }

  @override
  void dispose() {
    _preferredName.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final updates = {
        'preferredName': _preferredName.text.trim(),
        'gender': _gender ?? '',
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(updates, SetOptions(merge: true));

      // keep the in-memory cache in sync so the AI service can read it
      // immediately without a fresh Firestore round-trip
      userCache = {...?userCache, ...updates};

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal info saved'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'These details can be used in AI-suggested responses - for '
            'example if someone asks for your name or phone number. Leave '
            'a field blank if you don\'t want it shared this way.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          _buildField('Preferred Name', _preferredName, Icons.badge_outlined),
          const SizedBox(height: 16),
          Text('Gender', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Male'),
                  selected: _gender == 'male',
                  onSelected: (_) => setState(() => _gender = 'male'),
                ),
              ),
    const SizedBox(width: 12),
    Expanded(
      child: ChoiceChip(
        label: const Text('Female'),
        selected: _gender == 'female',
        onSelected: (_) => setState(() => _gender = 'female'),
      ),
    ),
  ],
),
          const SizedBox(height: 16),
          _buildField(
            'Phone Number',
            _phone,
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildField('Address', _address, Icons.home_outlined, maxLines: 2),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
