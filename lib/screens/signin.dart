import 'package:auto_route/auto_route.dart';
import 'package:disfigstyle/actions/users.dart';
import 'package:disfigstyle/components/desktop_app_bar.dart';
import 'package:disfigstyle/components/fade_in_x.dart';
import 'package:disfigstyle/components/fade_in_y.dart';
import 'package:disfigstyle/components/loading_animation.dart';
import 'package:disfigstyle/router/app_router.gr.dart';
import 'package:disfigstyle/state/colors.dart';
import 'package:disfigstyle/state/user.dart';
import 'package:disfigstyle/types/enums.dart';
import 'package:disfigstyle/utils/app_storage.dart';
import 'package:disfigstyle/utils/snack.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

class Signin extends StatefulWidget {
  final void Function(bool isAuthenticated) onSigninResult;

  const Signin({Key key, this.onSigninResult}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String email = '';
  String password = '';

  bool isCheckingAuth = false;
  bool isCompleted = false;
  bool isSigningIn = false;

  final passwordNode = FocusNode();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          DesktopAppBar(
            automaticallyImplyLeading: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: 100.0,
              bottom: 300.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: 320.0,
                      child: body(),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    if (isSigningIn) {
      return LoadingAnimation(
        textTitle: 'Signing in...',
      );
    }

    return idleContainer();
  }

  Widget idleContainer() {
    return Column(
      children: <Widget>[
        header(),
        emailInput(),
        passwordInput(),
        forgotPassword(),
        validationButton(),
        noAccountButton(),
      ],
    );
  }

  Widget emailInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 80.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.email),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                email = value;
              },
              onFieldSubmitted: (value) => passwordNode.requestFocus(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Email login cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: FlatButton(
        onPressed: () => context.router.push(ForgotPasswordRoute()),
        child: Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "I forgot my password",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (context.router.stack.length > 1)
          FadeInX(
            beginX: 10.0,
            delay: 200.milliseconds,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 20.0,
              ),
              child: IconButton(
                onPressed: () => context.router.pop(),
                icon: Icon(Icons.arrow_back),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FadeInY(
              beginY: 50.0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            FadeInY(
              delay: 300.milliseconds,
              beginY: 50.0,
              child: Opacity(
                opacity: 0.6,
                child: Text(
                  'Connect to your existing account',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget noAccountButton() {
    return FadeInY(
      delay: 400.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FlatButton(
            onPressed: () {
              context.router.navigate(
                SignupRoute(onSignupResult: widget.onSigninResult),
              );
            },
            child: Opacity(
              opacity: 0.6,
              child: Text(
                "I don't have an account",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            )),
      ),
    );
  }

  Widget passwordInput() {
    return FadeInY(
      delay: 100.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: EdgeInsets.only(
          top: 30.0,
          left: 15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              focusNode: passwordNode,
              controller: passwordController,
              decoration: InputDecoration(
                icon: Icon(Icons.lock_outline),
                labelText: 'Password',
              ),
              obscureText: true,
              onChanged: (value) {
                password = value;
              },
              onFieldSubmitted: (value) => signInProcess(),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Password login cannot be empty';
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget validationButton() {
    return FadeInY(
      delay: 200.milliseconds,
      beginY: 50.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: RaisedButton(
          onPressed: () => signInProcess(),
          color: stateColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(7.0),
            ),
          ),
          child: Container(
            width: 250.0,
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool inputValuesOk() {
    if (!checkEmailFormat(email)) {
      showSnack(
        context: context,
        message: "The value specified is not a valid email",
        type: SnackType.error,
      );

      return false;
    }

    if (password.isEmpty) {
      showSnack(
        context: context,
        message: "Password cannot be empty",
        type: SnackType.error,
      );

      return false;
    }

    return true;
  }

  void signInProcess() async {
    if (!inputValuesOk()) {
      return;
    }

    setState(() => isSigningIn = true);

    try {
      final userCred = await stateUser.signin(
        email: email,
        password: password,
      );

      if (userCred == null) {
        showSnack(
          context: context,
          type: SnackType.error,
          message: 'The password is incorrect or the user does not exists.',
        );

        return;
      }

      appStorage.setCredentials(
        email: email,
        password: password,
      );

      isSigningIn = false;
      isCompleted = true;

      // If this callback is defined,
      // this page is call from AuthGuard.
      if (widget.onSigninResult != null) {
        widget.onSigninResult(true);
        return;
      }

      context.router.navigate(HomeRoute());
    } catch (error) {
      debugPrint(error.toString());

      setState(() => isSigningIn = false);

      showSnack(
        context: context,
        type: SnackType.error,
        message: 'The password is incorrect or the user does not exists.',
      );
    }
  }
}
