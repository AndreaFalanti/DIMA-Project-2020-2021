import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/cartItem.dart';

class AddItemAction {
  final CartItem item;

  AddItemAction(this.item);
}

class ChangeFirebaseUserAction {
  final User firebaseUser;

  ChangeFirebaseUserAction(this.firebaseUser);
}

class SwitchThemeAction {
  final ThemeMode theme;

  SwitchThemeAction(this.theme);
}

class FetchCartAction {}

class FetchCartSucceededAction {
  final List<CartItem> fetchedCartItems;

  FetchCartSucceededAction(this.fetchedCartItems);
}

class FetchCartFailedAction {
  final Exception error;

  FetchCartFailedAction(this.error);
}