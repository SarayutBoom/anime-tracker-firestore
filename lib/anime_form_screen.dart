import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/firestore.dart';

class AnimeFormScreen extends StatefulWidget {
  final String? docID;
  final String? initialName;
  final int? initialEpisodes;
  final int? initialSeason;
  final double? initialScore;

  const AnimeFormScreen({
    super.key,
    this.docID,
    this.initialName,
    this.initialEpisodes,
    this.initialSeason,
    this.initialScore,
  });

  @override
  State<AnimeFormScreen> createState() => _AnimeFormScreenState();
}

class _AnimeFormScreenState extends State<AnimeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _episodesController = TextEditingController();
  final _seasonController = TextEditingController();
  final _scoreController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  static const Color bgColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color accentColor = Color(0xFF2563EB);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color errorColor = Color(0xFFEF4444);

  bool get isEditMode => widget.docID != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.initialName ?? '';
      _episodesController.text = widget.initialEpisodes?.toString() ?? '';
      _seasonController.text = widget.initialSeason?.toString() ?? '';
      _scoreController.text = widget.initialScore?.toStringAsFixed(2) ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _episodesController.dispose();
    _seasonController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _saveAnime() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final episodes = int.parse(_episodesController.text);
    final season = int.parse(_seasonController.text);
    final score = double.parse(_scoreController.text);

    try {
      if (isEditMode) {
        await _firestoreService.updateAnime(
          docID: widget.docID!,
          name: name,
          episodes: episodes,
          season: season,
          score: score,
        );
      } else {
        await _firestoreService.addAnime(
          name: name,
          episodes: episodes,
          season: season,
          score: score,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode ? 'Updated successfully' : 'Saved to Firestore',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            color: bgColor,
            border: Border(bottom: BorderSide(color: borderColor, width: 1)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 24, 18),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: textPrimary, size: 26),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEditMode ? 'EDIT' : 'NEW',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isEditMode ? 'Edit Title' : 'Add New Title',
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('01', 'TITLE INFORMATION'),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _nameController,
                label: 'Anime Name',
                hint: 'e.g. Attack on Titan',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _sectionLabel('02', 'DETAILS'),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _episodesController,
                      label: 'Episodes',
                      hint: '24',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildTextField(
                      controller: _seasonController,
                      label: 'Season',
                      hint: '1',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = int.tryParse(v);
                        if (n == null || n <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _sectionLabel('03', 'RATING'),
              const SizedBox(height: 14),
              _buildTextField(
                controller: _scoreController,
                label: 'Score',
                hint: '4.75',
                suffix: '/ 5.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null) return 'Invalid number';
                  if (n < 0 || n > 5) return 'Must be 0.00 - 5.00';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Range: 0.00 – 5.00 · Max 2 decimals',
                  style: TextStyle(
                    fontSize: 13,
                    color: textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _saveAnime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 19),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isEditMode ? 'SAVE CHANGES' : 'CREATE',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String number, String label) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: accentColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Divider(color: borderColor, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            fontSize: 17,
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: accentColor,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: textTertiary,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentColor, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: errorColor, width: 1.8),
            ),
            errorStyle: const TextStyle(
              color: errorColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}