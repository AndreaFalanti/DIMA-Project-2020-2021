import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_redux/flutter_redux.dart';
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
        body: Builder(
          builder: (context) {
            return Center(
              child: Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          // TODO: Remove initial value in production
                          controller: _emailController..text = "Elsie_Crona55@example.com",
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (String value) {
                            if (value.isEmpty) return 'Please enter some text';
                            return null;
                          },
                        ),
                        TextFormField(
                          // TODO: Remove initial value in production
                          controller: _passwordController..text = "R5Z3IDE8lkaofwu",
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (String value) {
                            if (value.isEmpty) return 'Please enter some text';
                            return null;
                          },
                          obscureText: true,
                        ),
                        RaisedButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _performSignInWithMethod(_signInWithEmailAndPassword, context);
                              }
                            },
                            child: Text("Sign In")),
                        RaisedButton(
                            onPressed: () =>
                                _performSignInWithMethod(_signInWithGoogle, context),
                            child: Text("Sign In with Google"))
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        ),
    );
  }

  void _performSignInWithMethod(Future<User> Function(BuildContext) method, BuildContext context) async {
    User user = await method(context);
    if (user != null) {
      StoreProvider.of<AppState>(context)
          .dispatch(ChangeFirebaseUserAction(user));
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

      // TODO: because of Navigator.pop it will not be visible in time
      //displaySnackbarWithText(context, "${user.email} signed in");

      return user;
    } catch (e) {
      displaySnackbarWithText(context, "Failed to sign in with Email & Password");

      return null;
    }
  }

  Future<User> _signInWithGoogle(scaffold) async {
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

      // TODO: because of Navigator.pop it will not be visible in time
      //displaySnackbarWithText(context, "${user.displayName} Logged in");

      return user;
    } on FirebaseAuthException catch (e) {
      print("Error code: ${e.code}");
      scaffold.showSnackBar(SnackBar(
        content: Text("Error during authentication"),
      ));
      return null;
    } catch (e) {
      print(e);
      displaySnackbarWithText(context, "Error");
      return null;
    }
  }
}
