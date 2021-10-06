import 'dart:io';

import 'package:ashapos/blocs/authentication/authentication_cubit.dart';
import 'package:ashapos/blocs/cart/cart_cubit.dart';
import 'package:ashapos/blocs/categories_food/categories_food_cubit.dart';
import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/blocs/sales/sales_cubit.dart';
import 'package:ashapos/ui/screens/auth/login.dart';
import 'package:ashapos/ui/screens/home.dart';
import 'package:ashapos/ui/screens/splash.dart';
import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp(
    authenticationRepository: AuthenticationRepository(),
  ));
}

class MyApp extends StatelessWidget {
  final AuthenticationRepository authenticationRepository;

  const MyApp({Key key, @required this.authenticationRepository})
      : assert(authenticationRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => AuthenticationCubit(
                  authenticationRepository: authenticationRepository)),
          BlocProvider(create: (_) => CartCubit()),
          BlocProvider(create: (_) => ConnectivityCubit())
        ],
        child: MyAppView(),
      ),
    );
  }
}

class MyAppView extends StatefulWidget {
  @override
  _MyAppViewState createState() => _MyAppViewState();
}

class _MyAppViewState extends State<MyAppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'ETAM BERSINAR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, child) =>
          BlocListener<AuthenticationCubit, AuthenticationState>(
        listenWhen: (old, state) {
          if (old.errorMessage == '') {
            return true;
          }
          if (state.errorMessage == '') {
            return true;
          }
          return false;
        },
        listener: (_, state) {
          if (state.isAuthenticated) {
            _navigator.pushAndRemoveUntil<void>(
              MaterialPageRoute(builder: (_) => HomePage()),
              (route) => false,
            );
          }
          if (state.isUnauthenticated) {
            _navigator.pushAndRemoveUntil<void>(
              LoginPage.route(),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (_, state) {
            if (state.initial) {
              return SplashPage();
            }
            return MultiBlocProvider(providers: [
              BlocProvider(
                  create: (_) => SalesCubit(
                      connectivityCubit:
                          BlocProvider.of<ConnectivityCubit>(context),
                      authenticationCubit:
                          BlocProvider.of<AuthenticationCubit>(context))
                    ..initSales()),
              BlocProvider(
                  create: (_) => CategoriesFoodCubit(
                      connectivityCubit:
                          BlocProvider.of<ConnectivityCubit>(context),
                      authenticationCubit:
                          BlocProvider.of<AuthenticationCubit>(context))
                    ..initCategoriesFood())
            ], child: child);
          },
        ),
      ),
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
