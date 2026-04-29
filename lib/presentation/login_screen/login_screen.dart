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
    // Check if already signed in
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      });
    }
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
        // Ensure user profile exists in DB
        await VocabularyService.ensureUserProfile();
        VocabularyService.invalidateCache();

        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
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
                const Spacer(),
                Text(
                  'Hoş geldin 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Devam etmek için Google hesabınla giriş yap.',
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                _GoogleSignInButton(
                  isLoading: _isLoading,
                  onTap: _handleGoogleSignIn,
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
                SizedBox(height: 5.h),
              ],
            ),
          ),
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
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
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
