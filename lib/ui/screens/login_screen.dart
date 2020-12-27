import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:realiteye/generated/locale_keys.g.dart';
import 'package:realiteye/redux/actions.dart';
import 'package:realiteye/redux/app_state.dart';
import 'package:realiteye/utils/data_service.dart';
import 'package:realiteye/utils/utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.login_title.tr())),
      //TODO: Check if this is a good practice
      resizeToAvoidBottomInset: false,
      body: Builder(builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TODO: Sample logo of the app added to occupy space
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://image.shutterstock.com/image-vector/global-camera-eye-logo-photo-600w-383758570.jpg"),
                  fit: BoxFit.fitWidth
                )
              ),
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // SizedBox(
                    //   height: 50,
                    // ),
                    TextFormField(
                      // TODO: Remove initial value in production
                      controller: _emailController
                        ..text = "Elsie_Crona55@example.com",
                      decoration: InputDecoration(
                          labelText: 'Email', suffixIcon: Icon(Icons.email)),
                      validator: (String value) {
                        if (value.isEmpty) return 'Please enter some text';
                        return null;
                      },
                    ),
                    TextFormField(
                      // TODO: Remove initial value in production
                      controller: _passwordController..text = "R5Z3IDE8lkaofwu",
                      decoration: InputDecoration(
                          labelText: 'Password', suffixIcon: Icon(Icons.lock)),
                      validator: (String value) {
                        if (value.isEmpty) return 'Please enter some text';
                        return null;
                      },
                      obscureText: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                          onPressed: () {
                            // Dismiss the keyboard after submit (otherwise snackbar is not visible)
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState.validate()) {
                              _performSignInWithMethod(
                                  _signInWithEmailAndPassword, context);
                            }
                          },
                          color: Theme.of(context).accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          child: Text("Sign In")),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 15, left: 15),
              //TODO: Add to localization
              child: Text(
                "Or sign in with a social account:",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: SignInButton(
                    Buttons.Google,
                    text: "Google Sign In",
                    onPressed: () =>
                        _performSignInWithMethod(_signInWithGoogle, context),
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Flexible(
                      child: SignInButton(
                    Buttons.Facebook,
                    text: "Facebook Sign In",
                    //TODO: Add support for facebook login
                    onPressed: () => print('Sign in with facebook'),
                  )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Divider(
                thickness: 1,
                indent: 15,
                endIndent: 15,
                height: 25,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                RichText(
                  text: TextSpan(
                    text: "Not registered? ",
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                Navigator.pushNamed(context, "/register")),
                    ],
                  ),
                ),
              ],
            )
          ],
        );
      }),
    );
  }

  void _performSignInWithMethod(
      Future<User> Function(BuildContext) method, BuildContext context) async {
    User user = await method(context);
    if (user != null) {
      var store = StoreProvider.of<AppState>(context);
      store.dispatch(ChangeFirebaseUserAction(user));
      store.dispatch(FetchCartAction());
      Navigator.pop(context, "${user.email} signed in");
    }
  }

  Future<User> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      final User user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ))
          .user;

      return user;
    } catch (e) {
      displaySnackbarWithText(
          context, "Failed to sign in with Email & Password");

      return null;
    }
  }

  Future<User> _signInWithGoogle(BuildContext context) async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      List<String> displayNameSplit = user.displayName.split(" ");

      Map<String, dynamic> userData = {
        'firstname': displayNameSplit[0],
        'lastname': displayNameSplit[1],
        'email': user.email,
        'photoURL': user.photoURL
      };

      addUser(user, userData);

      return user;
    } on FirebaseAuthException catch (e) {
      print("Error code: ${e.code}");
      displaySnackbarWithText(context, "Error during authentication");
      return null;
    } catch (e) {
      print(e);
      /* TODO: more meaningful message or show no snackbar at all,
      *   it seems is triggered by back button */
      displaySnackbarWithText(context, "Error");
      return null;
    }
  }
}
