import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/ui/screens/setting.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sales/sales.dart';

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationCubit, AuthenticationState>(
        builder: (_, state) {
      if (state.isUnauthenticated) {
        return Drawer();
      }
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            ListTile(
              leading: Material(
                  type: MaterialType.circle,
                  color: Colors.grey,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  )),
              title: Text('${state.user.fullName}'),
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Penjualan'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_shopping_cart),
              title: Text('Tambah Penjualan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, SalesPage.route());
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, SettingPage.route());
              },
            ),
            ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  // change app state...
                  Navigator.pop(context);
                  RepositoryProvider.of<AuthenticationRepository>(context)
                      .logOut();
                }),
          ],
        ),
      );
    });
  }
}
