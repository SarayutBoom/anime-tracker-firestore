import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/firestore.dart';

class AnimeFormScreen extends StatefulWidget {
  // ถ้ามี docID = แก้ไข, ถ้าไม่มี = เพิ่มใหม่
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

  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color accentColor = Color(0xFFFF6B9D);

  bool get isEditMode => widget.docID != null;

  @override
  void initState() {
    super.initState();
    // ถ้าเป็นโหมดแก้ไข ให้ใส่ค่าเดิมเข้าไป
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

  // -------- บันทึกข้อมูล --------
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
            content:
                Text(isEditMode ? 'แก้ไขเรียบร้อยแล้ว' : 'บันทึกเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
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
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditMode ? 'แก้ไขอนิเมะ' : 'เพิ่มอนิเมะใหม่',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, accentColor],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isEditMode
                        ? Icons.edit_note_rounded
                        : Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ชื่ออนิเมะ
              _buildLabel('ชื่ออนิเมะ', Icons.movie_rounded),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: 'เช่น Attack on Titan',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'กรุณากรอกชื่ออนิเมะ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // จำนวนตอน
              _buildLabel('จำนวนตอน', Icons.playlist_play_rounded),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _episodesController,
                hint: 'เช่น 24',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณากรอกจำนวนตอน';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'ต้องเป็นจำนวนเต็มบวก';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ซีซั่นที่
              _buildLabel('ซีซั่นที่', Icons.layers_rounded),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _seasonController,
                hint: 'เช่น 1',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณากรอกซีซั่น';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'ต้องเป็นจำนวนเต็มบวก';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // คะแนน
              _buildLabel('คะแนน (0.00 - 5.00)', Icons.star_rounded),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _scoreController,
                hint: 'เช่น 4.75',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // อนุญาตแค่ตัวเลขและจุด ทศนิยมไม่เกิน 2 ตำแหน่ง
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'กรุณากรอกคะแนน';
                  final n = double.tryParse(v);
                  if (n == null) return 'กรุณากรอกตัวเลขที่ถูกต้อง';
                  if (n < 0 || n > 5) return 'ต้องอยู่ในช่วง 0.00 - 5.00';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '* ทศนิยมได้สูงสุด 2 ตำแหน่ง',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ปุ่มบันทึก
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveAnime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditMode
                            ? Icons.save_rounded
                            : Icons.cloud_upload_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEditMode ? 'บันทึกการแก้ไข' : 'บันทึกลง Firestore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------- Label สำหรับแต่ละ field --------
  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primaryColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // -------- TextField แบบ styled --------
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}