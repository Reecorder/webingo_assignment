abstract class Routes {
  Routes._();
  static const home = _Paths.home;
  static const login = _Paths.login;
  static const splash = _Paths.splash;
  static const flightSearch = _Paths.flightSearch;
  static const flightList = _Paths.flightList;
  static const flightDetails = _Paths.flightDetails;
}

abstract class _Paths {
  _Paths._();
  static const home = "/home";
  static const login = "/login";
  static const splash = "/splash";
  static const flightSearch = "/flightSearch";
  static const flightList = "/flight-list";
  static const flightDetails = "/flight-details";
}
