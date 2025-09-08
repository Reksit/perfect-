import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _loading = false;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChars = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordStrong {
    return _hasMinLength && _hasUppercase && _hasLowercase && _hasNumbers && _hasSpecialChars;
  }

  double get _passwordStrength {
    int score = 0;
    if (_hasMinLength) score++;
    if (_hasUppercase) score++;
    if (_hasLowercase) score++;
    if (_hasNumbers) score++;
    if (_hasSpecialChars) score++;
    return score / 5.0;
  }

  Color get _passwordStrengthColor {
    if (_passwordStrength < 0.3) return Colors.red;
    if (_passwordStrength < 0.6) return Colors.orange;
    if (_passwordStrength < 0.8) return Colors.yellow;
    return Colors.green;
  }

  String get _passwordStrengthText {
    if (_passwordStrength < 0.3) return 'Weak';
    if (_passwordStrength < 0.6) return 'Fair';
    if (_passwordStrength < 0.8) return 'Good';
    return 'Strong';
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPasswordStrong) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a stronger password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would call your API here
      // await APIService.changePassword(
      //   currentPassword: _currentPasswordController.text,
      //   newPassword: _newPasswordController.text,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Navigate back
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: !showPassword,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                showPassword ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            helperText: helpText,
            helperMaxLines: 2,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _passwordStrengthText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _passwordStrengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        LinearProgressIndicator(
          value: _passwordStrength,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
        ),
        const SizedBox(height: 16),
        
        Text(
          'Password Requirements:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        _buildRequirementRow('At least 8 characters', _hasMinLength),
        _buildRequirementRow('Uppercase letter (A-Z)', _hasUppercase),
        _buildRequirementRow('Lowercase letter (a-z)', _hasLowercase),
        _buildRequirementRow('Number (0-9)', _hasNumbers),
        _buildRequirementRow('Special character (!@#\$%^&*)', _hasSpecialChars),
      ],
    );
  }

  Widget _buildRequirementRow(String requirement, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              requirement,
              style: TextStyle(
                color: isMet ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTips() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Security Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildTip('Use a unique password that you don\'t use elsewhere'),
            _buildTip('Include a mix of letters, numbers, and symbols'),
            _buildTip('Avoid using personal information like names or birthdays'),
            _buildTip('Consider using a password manager'),
            _buildTip('Change your password regularly'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Your Password',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your current password and choose a new secure password.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildPasswordField(
                        label: 'Current Password',
                        controller: _currentPasswordController,
                        showPassword: _showCurrentPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showCurrentPassword = !_showCurrentPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      
                      _buildPasswordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        showPassword: _showNewPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (!_isPasswordStrong) {
                            return 'Password does not meet security requirements';
                          }
                          return null;
                        },
                        helpText: 'Choose a strong password with at least 8 characters',
                      ),
                      
                      if (_newPasswordController.text.isNotEmpty) ...[
                        _buildPasswordStrengthIndicator(),
                        const SizedBox(height: 16),
                      ],
                      
                      _buildPasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        showPassword: _showConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Change Password',
                          onPressed: _loading ? null : _changePassword,
                          isLoading: _loading,
                          icon: Icons.security,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSecurityTips(),
              
              const SizedBox(height: 24),
              
              // Additional Security Options
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Security',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        leading: const Icon(Icons.phonelink_lock),
                        title: const Text('Two-Factor Authentication'),
                        subtitle: const Text('Add an extra layer of security'),
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Two-factor authentication coming soon!'),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.devices),
                        title: const Text('Active Sessions'),
                        subtitle: const Text('Manage your login sessions'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Session management coming soon!'),
                            ),
                          );
                        },
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: const Text('Login History'),
                        subtitle: const Text('View recent login activity'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Login history coming soon!'),
                            ),
                          );
                        },
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
}
