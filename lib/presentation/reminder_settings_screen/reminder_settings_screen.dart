import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../data/services/notification_service.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _isEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await NotificationService.getReminderSettings();
    if (!mounted) return;
    setState(() {
      _isEnabled = settings['enabled'] as bool;
      _selectedTime = TimeOfDay(
        hour: settings['hour'] as int,
        minute: settings['minute'] as int,
      );
      _isLoading = false;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryLight,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceVariantDark,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    if (_isEnabled) {
      if (!kIsWeb) {
        await NotificationService.requestPermission();
      }
      await NotificationService.scheduleDailyReminder(
        _selectedTime.hour,
        _selectedTime.minute,
      );
    } else {
      await NotificationService.cancelReminder();
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEnabled
              ? 'Hatırlatıcı ${_selectedTime.format(context)} için ayarlandı'
              : 'Hatırlatıcı kapatıldı',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: _isEnabled ? AppTheme.success : AppTheme.textMuted,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryLight,
                        ),
                      )
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
          Text(
            'Hatırlatıcı Ayarları',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildToggleCard(),
          if (_isEnabled) ...[const SizedBox(height: 16), _buildTimeCard()],
          const SizedBox(height: 32),
          _buildSaveButton(),
          if (kIsWeb) ...[const SizedBox(height: 16), _buildWebNote()],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1B5E), Color(0xFF1A2A6C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppTheme.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günlük Hedef Hatırlatıcısı',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Her gün belirlediğin saatte 20 kelime hedefini tamamlamanı hatırlatır.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.alarm_rounded,
            color: AppTheme.primaryLight,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hatırlatıcıyı Etkinleştir',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _isEnabled ? 'Açık' : 'Kapalı',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: _isEnabled ? AppTheme.success : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (val) => setState(() => _isEnabled = val),
            activeThumbColor: AppTheme.primaryLight,
            activeTrackColor: AppTheme.primary.withAlpha(100),
            inactiveThumbColor: AppTheme.textMuted,
            inactiveTrackColor: AppTheme.surfaceVariantDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.glassSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryLight.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppTheme.primaryLight,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hatırlatma Saati',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    _selectedTime.format(context),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Değiştir',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Kaydet',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildWebNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warningSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Yerel bildirimler yalnızca mobil cihazlarda çalışır. Ayarlar kaydedildi.',
              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.warning),
            ),
          ),
        ],
      ),
    );
  }
}
