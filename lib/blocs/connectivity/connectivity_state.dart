part of 'connectivity_cubit.dart';

enum ConnectivityStatus { online, offline, init }

class ConnectivityState extends Equatable {
  const ConnectivityState(this.result);

  final ConnectivityStatus result;

  ConnectivityState.init() : this(ConnectivityStatus.offline);

  ConnectivityState changed(ConnectivityStatus statusChanged) =>
      ConnectivityState(statusChanged);

  bool get isonline => result == ConnectivityStatus.online;
  bool get isoffline => result == ConnectivityStatus.offline;
  bool get initial => result == ConnectivityStatus.init;

  @override
  List<Object> get props => [result];
}
