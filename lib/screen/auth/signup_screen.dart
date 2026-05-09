import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/logo_section.dart';
import '../../widgets/terms_checkbox.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final GlobalKey<FormState> _formKey;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup(AuthService authService) async {
    if (!_validateForm()) return;
    if (!_agreedToTerms) {
      _showErrorSnackBar('Please agree to the terms and conditions');
      return;
    }

    final success = await authService.register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    
    if (success) {
      _showSuccessSnackBar('Account created successfully! Please log in.');
      _navigateToLogin();
    } else {
      _showErrorSnackBar(authService.error ?? 'Sign up failed');
    }
  }

  bool _validateForm() => _formKey.currentState?.validate() ?? false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void _navigateBack() => Navigator.pop(context);
  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);
  void _toggleConfirmPasswordVisibility() => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  void _updateTermsAgreement(bool? value) => setState(() => _agreedToTerms = value ?? false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Consumer<AuthService>(
        builder: (context, authService, _) => AuthBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LogoSection(),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: _buildSignupForm(authService),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: _navigateBack,
      ),
    );
  }

  Widget _buildSignupForm(AuthService authService) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final textColor = textTheme.bodyLarge?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeaders(textTheme, colorScheme, textColor),
        const SizedBox(height: 40),
        _buildWelcomeText(textTheme, textColor),
        const SizedBox(height: 32),
        _buildNameRow(theme, textColor),
        const SizedBox(height: 16),
        _buildEmailField(theme, textColor),
        const SizedBox(height: 16),
        _buildPhoneField(theme, textColor),
        const SizedBox(height: 16),
        _buildPasswordField(theme, textColor),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(theme, textColor),
        const SizedBox(height: 16),
        TermsCheckbox(
          value: _agreedToTerms,
          onChanged: _updateTermsAgreement,
        ),
        const SizedBox(height: 24),
        AuthButton(
          isLoading: authService.isLoading,
          label: 'Sign Up',
          onPressed: () => _handleSignup(authService),
        ),
        const SizedBox(height: 20),
        _buildLoginLink(theme),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ],
    );
  }

  Widget _buildHeaders(TextTheme textTheme, ColorScheme colorScheme, Color textColor) {
    return Column(
      children: [
        Text(
          'GUIDE TO',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SOUTHERN WOMEN\'S MUSEUM',
          style: textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your personal museum guide',
          style: textTheme.bodyLarge?.copyWith(
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(TextTheme textTheme, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Create your account', style: textTheme.headlineLarge),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Start your guided museum experience',
            style: textTheme.bodyLarge?.copyWith(
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameRow(ThemeData theme, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: AuthTextField(
            controller: _firstNameController,
            hintText: 'John',
            labelText: 'FIRST NAME',
            theme: theme,
            textColor: textColor,
            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AuthTextField(
            controller: _lastNameController,
            hintText: 'Doe',
            labelText: 'LAST NAME',
            theme: theme,
            textColor: textColor,
            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme, Color textColor) {
    return AuthTextField(
      controller: _emailController,
      hintText: 'your@email.com',
      labelText: 'EMAIL',
      theme: theme,
      textColor: textColor,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email is required';
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
        if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
        return null;
      },
    );
  }

  Widget _buildPhoneField(ThemeData theme, Color textColor) {
    return AuthTextField(
      controller: _phoneController,
      hintText: '1234567890',
      labelText: 'PHONE',
      theme: theme,
      textColor: textColor,
      validator: (value) => (value == null || value.isEmpty) ? 'Phone is required' : null,
    );
  }

  Widget _buildPasswordField(ThemeData theme, Color textColor) {
    return AuthTextField(
      controller: _passwordController,
      hintText: 'Min. 6 characters',
      labelText: 'PASSWORD',
      theme: theme,
      textColor: textColor,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: textColor.withValues(alpha: 0.5),
        ),
        onPressed: _togglePasswordVisibility,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme, Color textColor) {
    return AuthTextField(
      controller: _confirmPasswordController,
      hintText: 'Re-enter password',
      labelText: 'CONFIRM PASSWORD',
      theme: theme,
      textColor: textColor,
      obscureText: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          color: textColor.withValues(alpha: 0.5),
        ),
        onPressed: _toggleConfirmPasswordVisibility,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm password';
        if (value != _passwordController.text) return 'Passwords do not match';
        return null;
      },
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final textColor = textTheme.bodyLarge?.color ?? Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: textTheme.bodyLarge?.copyWith(
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        TextButton(
          onPressed: _navigateToLogin,
          child: Text(
            'Log In',
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}