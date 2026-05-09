import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/logo_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthService authService) async {
    if (!_validateForm()) return;

    final success = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackBar('Login successful!');
      _navigateToHome();
    } else {
      _showErrorSnackBar(authService.error ?? 'Login failed');
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

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  void _navigateToSignup() => Navigator.of(context).pushNamed('/signup');
  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: _buildLoginForm(authService),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthService authService) {
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
        _buildEmailField(theme, textColor),
        const SizedBox(height: 16),
        _buildPasswordField(theme, textColor),
        const SizedBox(height: 12),
        _buildForgotPasswordLink(textTheme, textColor),
        const SizedBox(height: 28),
        AuthButton(
          isLoading: authService.isLoading,
          label: 'Log in',
          onPressed: () => _handleLogin(authService),
        ),
        const SizedBox(height: 20),
        _buildSignupLink(textTheme, colorScheme, textColor),
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
          child: Text('Welcome back', style: textTheme.headlineLarge),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sign in to continue your journey',
            style: textTheme.bodyLarge?.copyWith(
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme, Color textColor) {
    return AuthTextField(
      controller: _emailController,
      hintText: 'your@email.com',
      icon: Icons.email_outlined,
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

  Widget _buildPasswordField(ThemeData theme, Color textColor) {
    return AuthTextField(
      controller: _passwordController,
      hintText: '••••••••',
      icon: Icons.lock_outline,
      theme: theme,
      textColor: textColor,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: textColor.withValues(alpha: 0.6),
          size: 20,
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

  Widget _buildForgotPasswordLink(TextTheme textTheme, Color textColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: Text(
          'Forgot Password?',
          style: textTheme.bodyLarge?.copyWith(
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupLink(TextTheme textTheme, ColorScheme colorScheme, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: textTheme.bodyLarge?.copyWith(
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        TextButton(
          onPressed: _navigateToSignup,
          child: Text(
            'Sign Up',
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