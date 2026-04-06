import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

import '../api/users.dart';
import '../config/styling.dart';
import '../helpers/alertbox.dart';
import '../providers/account_authentication.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  bool _isLoading = false;
  String? _displayName;
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600.0) {
            return Center(
              child: SizedBox(
                width: 600.0,
                child: _body(),
              ),
            );
          } else {
            return _body();
          }
        },
      ),
    );
  }

  Widget _body() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 200.0,
        ),
        child: Card(
          elevation: 4.0,
          shape: const RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  'Tools of Worship',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              Form(
                key: _formKey,
                child: _content(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            enabled: !_isLoading,
            keyboardType: TextInputType.name,
            validator: _displayNameValidator,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              _displayName = val;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Enter full name',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
            textInputAction: TextInputAction.next,
            onChanged: (val) {
              _email = val;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Enter email address',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: TextFormField(
            enabled: !_isLoading,
            obscureText: !_visiblePassword,
            keyboardType: TextInputType.visiblePassword,
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onChanged: (val) {
              _password = val;
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: 'Enter password',
              suffixIcon: InkWell(
                onTap: () {
                  setState(() {
                    _visiblePassword = !_visiblePassword;
                  });
                },
                child: Icon(
                  _visiblePassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onSignup,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign Up'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?',
                  style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: _isLoading ? null : _onBackToSignin,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child:
                    const Text('Sign in', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      AccountAuthentication accountAuth =
          context.read<AccountAuthentication>();

      bool success = await ApiUsers(accountAuth.authToken)
          .signup(_displayName!, _email!, _password!);

      if (success && mounted) {
        Navigator.of(context).pop();
        showMessage(
          context,
          'Please check your email account. You need to verify your email address before you can continue.',
        );
      }
    } catch (e) {
      if (mounted) {
        showError(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onBackToSignin() {
    Navigator.of(context).pop();
  }

  String? _displayNameValidator(String? displayName) {
    if (displayName == null || displayName.isEmpty) {
      return 'Empty name';
    }

    return null;
  }

  String? _emailValidator(String? email) {
    if (email != null && isEmail(email)) {
      return null;
    }

    return 'Invalid email address';
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Empty password';
    }

    if (!isLength(password, 8)) {
      return 'Password must be 8 or more characters long';
    }

    return null;
  }
}
