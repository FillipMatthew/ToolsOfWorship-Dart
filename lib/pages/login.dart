import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:string_validator/string_validator.dart';

import '../config/styling.dart';
import '../helpers/alertbox.dart';
import '../providers/account_authentication.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _visiblePassword = false;
  bool _isLoading = false;
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
    bool bDark = Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            onPressed: _isLoading ? null : _onSignIn,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign In'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Text('or'),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: SignInButton(
            buttonType: bDark ? ButtonType.googleDark : ButtonType.google,
            onPressed: _isLoading ? null : _signInWithGoogle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Don\'t have an account?',
                  style: Theme.of(context).textTheme.bodySmall),
              TextButton(
                onPressed: _isLoading ? null : _onSignup,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.transparent),
                ),
                child:
                    const Text('Signup', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
          await context.read<AccountAuthentication>().signIn(_email!, _password!);
      if (!success && mounted) {
        showError(context, 'Invalid email or password.');
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

  void _onSignup() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignupPage()));
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final success = await context
          .read<AccountAuthentication>()
          .authenticateWithGoogleSignIn();
      if (!success && mounted) {
        showError(context, 'Google sign-in failed. Please try again.');
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

    return null;
  }
}
