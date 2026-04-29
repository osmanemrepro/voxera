import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../data/services/vocabulary_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isEmailLogin = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: webClientId,
    serverClientId: webClientId,
    scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly'],
  );

  @override
  void initState() {
    super.initState();
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID token found');
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user != null && mounted) {
        await VocabularyService.ensureUserProfile();
        VocabularyService.invalidateCache();
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google girişi başarısız: ${_friendlyError(e)}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta ve şifre gerekli.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçerli bir e-posta adresi girin.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && mounted) {
        await VocabularyService.ensureUserProfile();
        VocabularyService.invalidateCache();
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      }
    } on AuthException catch (e) {
      if (mounted) {
        String message;
        if (e.message.contains('Invalid login') || e.message.contains('Invalid credentials')) {
          message = 'E-posta veya şifre hatalı.';
        } else if (e.message.contains('Email not confirmed')) {
          message = 'E-posta adresinizi onaylayın.';
        } else if (e.message.contains('Too many requests')) {
          message = 'Çok fazla deneme. Biraz bekleyin.';
        } else {
          message = 'Giriş başarısız: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Giriş başarısız. Lütfen tekrar deneyin.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') || msg.contains('socket')) {
      return 'İnternet bağlantısı yok.';
    }
    if (msg.contains('sign_in_failed') || msg.contains('sign_in_canceled')) {
      return 'Google girişi iptal edildi.';
    }
    return e.toString();
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 6.h),
                  // Logo
                  Center(
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withAlpha(100),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.record_voice_over_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Center(
                    child: Text(
                      'Voxera',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Center(
                    child: Text(
                      'Kelime öğrenmenin akıllı yolu',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),

                  // Hos geldin
                  Text(
                    'Hoş geldin 👋',
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Hesabına giriş yap veya yeni hesap oluştur.',
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Tab: Google / E-posta
                  Container(
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppTheme.glassSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Google', !_isEmailLogin, () {
                          setState(() => _isEmailLogin = false);
                        }),
                        _buildTab('E-posta', _isEmailLogin, () {
                          setState(() => _isEmailLogin = true);
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  if (!_isEmailLogin)
                    _GoogleSignInButton(
                      isLoading: _isLoading,
                      onTap: _handleGoogleSignIn,
                    )
                  else ...[
                    // E-posta
                    _buildLabel('E-posta'),
                    SizedBox(height: 0.8.h),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'ornek@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    SizedBox(height: 2.h),
                    // Sifre
                    _buildLabel('Şifre'),
                    SizedBox(height: 0.8.h),
                    _buildTextField(
                      controller: _passwordController,
                      hint: '••••••••',
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
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Giris Yap
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _handleEmailLogin,
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
                                'Giriş Yap',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],

                  SizedBox(height: 2.h),

                  // Kayit ol linki
                  if (_isEmailLogin)
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.registerScreen,
                                );
                              },
                        child: Text.rich(
                          TextSpan(
                            text: 'Hesabın yok mu? ',
                            style: GoogleFonts.outfit(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Kayıt ol',
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

                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      'Giriş yaparak Kullanım Koşulları\'nı kabul etmiş olursunuz.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        color: AppTheme.textMuted,
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
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.primaryGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : AppTheme.textMuted,
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
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 7.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://www.google.com/favicon.ico',
                    width: 22,
                    height: 22,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 26,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Google ile devam et',
                    style: GoogleFonts.outfit(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1035),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
