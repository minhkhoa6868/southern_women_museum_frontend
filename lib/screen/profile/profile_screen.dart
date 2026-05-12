import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/language_service.dart';
import '../../core/services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  // Text editing controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Form key
  late GlobalKey<FormState> _formKey;

  // User data
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _membership = 'Museum member';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.currentUser == null) {
      await authService.getCurrentUser();
    }

    if (mounted) {
      setState(() {
        _firstName = authService.currentUser?.firstName ?? 'David';
        _lastName = authService.currentUser?.lastName ?? 'Nguyen';
        _email = authService.currentUser?.email ?? 'davidnguyen@gmail.com';
        _phone = authService.currentUser?.phone ?? '';
        _notificationsEnabled =
            authService.currentUser?.isNotificationEnabled ?? true;
        _selectedLanguage = authService.currentUser?.language == 'vi'
            ? 'Vietnamese'
            : 'English';

        _firstNameController.text = _firstName;
        _lastNameController.text = _lastName;
        _emailController.text = _email;
        _phoneController.text = _phone;

        _isLoading = false;
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        if (_formKey.currentState!.validate()) {
          _saveChanges();
          _isEditing = false;
        }
      } else {
        _isEditing = true;
      }
    });
  }

  Future<void> _saveChanges() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() => _isLoading = true);

    final success = await authService.updateUser(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        setState(() {
          _firstName = _firstNameController.text.trim();
          _lastName = _lastNameController.text.trim();
          _email = _emailController.text.trim();
          _phone = _phoneController.text.trim();
        });
        _showSuccessSnackBar('Profile updated successfully');
      } else {
        _showErrorSnackBar(authService.error ?? 'Update failed');
      }
    }
  }

  void _cancelEditing() {
    setState(() {
      _firstNameController.text = _firstName;
      _lastNameController.text = _lastName;
      _emailController.text = _email;
      _phoneController.text = _phone;
      _isEditing = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSignOut(AuthService authService) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE07A6A).withValues(alpha: 0.2),
                      const Color(0xFFE07A6A).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: const Color(0xFFE07A6A),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to leave?\nYou will need to log in again.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color:
                              Theme.of(context).textTheme.bodyLarge?.color
                                  ?.withValues(alpha: 0.2) ??
                              Colors.grey,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE07A6A),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldSignOut == true) {
      await authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  String _getInitials() {
    if (_firstName.isEmpty || _lastName.isEmpty) return 'DN';
    return '${_firstName[0]}${_lastName[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<AuthService>(
      builder: (context, authService, _) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'My Profile',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildProfileHeader(theme, colorScheme, textTheme),
              const SizedBox(height: 8),
              _buildPersonalInfoTitle(colorScheme, textTheme),
              _buildPersonalInfoFrame(theme, textTheme, colorScheme),
              const SizedBox(height: 24),
              _buildSettingsTitle(colorScheme, textTheme),
              _buildSettingsFrame(theme, textTheme, colorScheme),
              const SizedBox(height: 16),
              _buildSignOutFrame(theme, authService),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // PERSONAL INFORMATION Title with Edit button frame
  Widget _buildPersonalInfoTitle(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'PERSONAL INFORMATION',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 1,
            ),
          ),
          if (!_isEditing)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextButton(
                onPressed: _toggleEditMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // SETTINGS Title (no edit button)
  Widget _buildSettingsTitle(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'SETTINGS',
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 3),
                ),
                child: CircleAvatar(
                  backgroundColor: colorScheme.primary,
                  radius: 38,
                  child: Text(
                    _getInitials(),
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_firstName $_lastName',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 14,
                      color: theme.textTheme.bodyLarge?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 12,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _membership,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FRAME - PERSONAL INFORMATION CONTENT
  Widget _buildPersonalInfoFrame(
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: !_isEditing
          ? Column(
              children: [
                // First Name & Last Name Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FIRST NAME',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyLarge?.color
                                    ?.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _firstName,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LAST NAME',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyLarge?.color
                                    ?.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _lastName,
                                  style: textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDivider(theme),
                // Email Address
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMAIL ADDRESS',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withValues(
                            alpha: 0.5,
                          ),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: theme.textTheme.bodyLarge?.color?.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _email,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FIRST NAME',
                                style: textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        theme.textTheme.bodyLarge?.color
                                            ?.withValues(alpha: 0.2) ??
                                        Colors.grey,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _firstNameController,
                                  style: textTheme.bodyLarge,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LAST NAME',
                                style: textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        theme.textTheme.bodyLarge?.color
                                            ?.withValues(alpha: 0.2) ??
                                        Colors.grey,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _lastNameController,
                                  style: textTheme.bodyLarge,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMAIL ADDRESS',
                          style: textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyLarge?.color?.withValues(
                              alpha: 0.5,
                            ),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  theme.textTheme.bodyLarge?.color?.withValues(
                                    alpha: 0.2,
                                  ) ??
                                  Colors.grey,
                            ),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            style: textTheme.bodyLarge,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Email is required';
                              final emailRegex = RegExp(
                                r'^[^@]+@[^@]+\.[^@]+$',
                              );
                              if (!emailRegex.hasMatch(value))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _cancelEditing,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _toggleEditMode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Save changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.1),
    );
  }

  // FRAME - SETTINGS CONTENT (with icons)
  Widget _buildSettingsFrame(
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Notifications
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            secondary: Icon(
              Icons.notifications_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            title: Text('Notifications', style: textTheme.bodyLarge),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
          _buildDivider(theme),

          // Language
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              Icons.language_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            title: Text('Language', style: textTheme.bodyLarge),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedLanguage,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
            onTap: () => _showLanguageDialog(),
          ),
          _buildDivider(theme),

          // Dark Mode toggle
          Consumer<ThemeService>(
            builder: (context, themeService, _) => SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: Icon(
                themeService.isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: colorScheme.primary,
                size: 22,
              ),
              title: Text('Dark Mode', style: textTheme.bodyLarge),
              value: themeService.isDark,
              onChanged: (_) => themeService.toggle(),
              activeThumbColor: colorScheme.primary,
              activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
          _buildDivider(theme),

          // Privacy Settings
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              Icons.lock_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
            title: Text('Privacy Settings', style: textTheme.bodyLarge),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showComingSoonSnackBar(),
          ),
          _buildDivider(theme),

          // Help & Support - with help icon
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              Icons.help_outline,
              color: colorScheme.primary,
              size: 22,
            ),
            title: Text('Help & Support', style: textTheme.bodyLarge),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _showHelpSupportDialog(), // <-- ĐỔI CHỖ NÀY
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSignOutFrame(ThemeData theme, AuthService authService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE07A6A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE07A6A).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: OutlinedButton.icon(
        onPressed: () => _handleSignOut(authService),
        icon: Icon(Icons.logout_outlined, color: const Color(0xFFE07A6A)),
        label: Text(
          'Sign Out',
          style: TextStyle(
            color: const Color(0xFFE07A6A),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFE07A6A),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(double.infinity, 0),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: _selectedLanguage == 'English'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await _changeLanguage('en', 'English');
              },
            ),
            ListTile(
              title: const Text('Vietnamese'),
              trailing: _selectedLanguage == 'Vietnamese'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await _changeLanguage('vi', 'Vietnamese');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLanguage(
    String languageCode,
    String languageLabel,
  ) async {
    if (_selectedLanguage == languageLabel) {
      return; // No change needed
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final languageService = Provider.of<LanguageService>(
        context,
        listen: false,
      );

      // Call backend to update user language
      final success = await authService.updateUserLanguage(languageCode);

      if (!mounted) return;

      if (success) {
        // Update local language state
        setState(() {
          _selectedLanguage = languageLabel;
          _isLoading = false;
        });

        // Update app-wide language service
        await languageService.setLanguage(languageCode);

        _showSuccessSnackBar('Language changed to $languageLabel');
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar(authService.error ?? 'Failed to change language');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            // Email
            InkWell(
              onTap: () {
                // Copy email hoặc mở email app
                Navigator.pop(context);
                _showSuccessSnackBar('Email copied!');
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Support',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          'helper.woman.museum@gmail.com',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Phone
            InkWell(
              onTap: () {
                // Copy phone hoặc gọi điện
                Navigator.pop(context);
                _showSuccessSnackBar('Phone number copied!');
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.phone_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Support',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          '0836 180 180',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Support available: Mon - Fri, 9:00 AM - 6:00 PM',
                      style: TextStyle(fontSize: 11, color: Colors.amber[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
