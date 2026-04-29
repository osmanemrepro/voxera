import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../data/services/vocabulary_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      setState(() => _errorMessage = 'Şifreler eşleşmiyor.');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Şifre en az 6 karakter olmalı.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      if (response.user != null && mounted) {
        // User profile will be auto-created by the trigger handle_new_user
        await VocabularyService.ensureUserProfile();
        VocabularyService.invalidateCache();

        // Check if email confirmation is required
        if (response.session == null) {
          // Email confirmation needed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt başarılı! E-posta adresinizi onaylayın.'),
                backgroundColor: AppTheme.success,
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
          }
        } else {
          // Auto-confirmed, go straight to home
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message;
        if (e.message.contains('already registered') ||
            e.message.contains('already been registered') ||
            e.message.contains('User already registered') ||
            e.message.contains('already exists')) {
          message = 'Bu e-posta zaten kayıtlı. Giriş yapmayı deneyin.';
        } else if (e.message.contains('password')) {
          message = 'Şifre çok zayıf. En az 6 karakter kullanın.';
        } else if (e.message.contains('rate limit') ||
            e.message.contains('Too many requests')) {
          message = 'Çok fazla deneme. Biraz bekleyin.';
        } else {
          message = 'Kayıt başarısız: ${e.message}';
        }
        setState(() => _errorMessage = message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    SizedBox(height: 4.h),
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Logo
                    Center(
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Center(
                      child: Text(
                        'Yeni Hesap Oluştur',
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Center(
                      child: Text(
                        'Voxera ile kelime öğrenmeye başla',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.error.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.error,
                              size: 18,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.outfit(
                                  fontSize: 11.sp,
                                  color: AppTheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Ad Soyad
                    _buildLabel('Ad Soyad'),
                    SizedBox(height: 0.8.h),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Osman Yaygın',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Ad gerekli' : null,
                    ),
                    SizedBox(height: 2.h),

                    // E-posta
                    _buildLabel('E-posta'),
                    SizedBox(height: 0.8.h),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'ornek@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Geçerli bir e-posta girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Sifre
                    _buildLabel('Şifre'),
                    SizedBox(height: 0.8.h),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'En az 6 karakter',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Şifre en az 6 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 2.h),

                    // Sifre tekrar
                    _buildLabel('Şifre Tekrar'),
                    SizedBox(height: 0.8.h),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: 'Şifreni tekrar gir',
                      obscureText: _obscureConfirm,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) {
                          return 'Şifreler eşleşmiyor';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 4.h),

                    // Kayit Ol butonu
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                                'Hesap Oluştur',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Giris yap linki
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text.rich(
                          TextSpan(
                            text: 'Zaten hesabın var mı? ',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Giriş yap',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
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
    bool obscureText = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(fontSize: 13.sp, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          fontSize: 13.sp,
          color: AppTheme.textMuted,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textMuted, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.glassSurface,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide:
              const BorderSide(color: AppTheme.glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide:
              const BorderSide(color: AppTheme.glassBorder, width: 1),
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
          borderSide:
              const BorderSide(color: AppTheme.error, width: 1),
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
