import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screen/draw/draw_view.dart';
import 'screen/home/home_view.dart';
import 'screen/intro/intro_view.dart';
import 'screen/splash/splash_view.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  GetPageRoute page(RouteSettings settings, Widget Function() genPage,
      [Bindings? bindings]) {
    var page = GetPage(
      name: settings.name!,
      page: genPage,
      arguments: settings.arguments,
      binding: bindings,
    );
    return PageRedirect(route: page, unknownRoute: page).page();
  }

  switch (settings.name) {
    case "/splash":
      return page(settings, () => SplashView());

    case "/intro":
      return page(settings, () => IntroView());

    case "/home":
      return page(settings, () => HomeView());

    case "/draw":
      return page(settings, () => DrawView());

    default:
      return page(
        settings,
        () => Scaffold(
          appBar: AppBar(title: const Text('404')),
          body: Center(child: Text('No route defined for ${settings.name}')),
        ),
      );
  }
}

enum AppPage {
  splash,
  intro,
  home,
  draw,
}

extension AppPageExtension on AppPage {
  String get routeName {
    switch (this) {
      case AppPage.splash:
        return '/${AppPage.splash.name}';
      case AppPage.intro:
        return '/${AppPage.intro.name}';
      case AppPage.home:
        return '/${AppPage.home.name}';
      case AppPage.draw:
        return '/${AppPage.draw.name}';
    }
  }
}
