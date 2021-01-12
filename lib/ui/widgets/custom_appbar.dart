import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:realiteye/redux/app_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showCartIcon;
  final bool showSearchIcon;
  CustomAppBar(this.title, {this.showCartIcon = false, this.showSearchIcon = false}) : preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize; // default is 56.0

  @override
  Widget build(BuildContext context) {
    var user;
    if (showCartIcon) {
      user = StoreProvider.of<AppState>(context).state.firebaseUser;
    }

    return AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) {
            //print("Current route:" + ModalRoute.of(context).settings.name);
            return (ModalRoute.of(context).settings.name == Navigator.defaultRouteName) ?
            IconButton(
                icon: new Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer())
            : IconButton(icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context));
          },
        ),
        actions: [
          showSearchIcon ? IconButton(icon: Icon(Icons.search), onPressed: () {
            Navigator.pushNamed(context, '/search');
          }) :
          Container(),
          (showCartIcon && user != null) ? IconButton(icon: Icon(Icons.shopping_cart), onPressed: () => Navigator.pushNamed(context, '/cart')) :
              Container(),
        ],
    );
  }
}
