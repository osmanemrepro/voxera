import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  GoogleSignInAccount? _account;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is GoogleSignInAccount) {
      _account = args;
      // Pre-fill from Google display name if available
      final parts = (args.displayName ?? '').trim().split(' ');
      if (parts.isNotEmpty && _firstNameController.text.isEmpty) {
        _firstNameController.text = parts.first;
      }
      if (parts.length > 1 && _lastNameController.text.isEmpty) {
        _lastNameController.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.backgroundDark,
              Color(0xFF0D1B3E),
              Color(0xFF1A0A3E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    // Avatar from Google
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(100),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: _account?.photoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _account!.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: AppTheme.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.backgroundDark,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Center(
                      child: Text(
                        _account?.email ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 11.sp,
                          color: AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Profilini tamamla',
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Seni nasıl çağıralım?',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // First Name
                    _buildLabel('Ad'),
                    SizedBox(height: 1.h),
                    _buildTextField(
                      controller: _firstNameController,
                      hint: 'Adını gir',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null,
                    ),
                    SizedBox(height: 2.5.h),
                    // Last Name
                    _buildLabel('Soyad'),
                    SizedBox(height: 1.h),
                    _buildTextField(
                      controller: _lastNameController,
                      hint: 'Soyadını gir',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Soyad gerekli'
                          : null,
                    ),
                    SizedBox(height: 5.h),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Uygulamaya Geç',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.outfit(fontSize: 13.sp, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          fontSize: 13.sp,
          color: AppTheme.textMuted,
        ),
        filled: true,
        fillColor: AppTheme.glassSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppTheme.glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppTheme.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(
            color: AppTheme.primaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppTheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
        ),
        errorStyle: GoogleFonts.outfit(fontSize: 10.sp, color: AppTheme.error),
      ),
    );
  }
}
