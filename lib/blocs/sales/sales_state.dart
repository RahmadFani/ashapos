part of 'sales_cubit.dart';

class SalesState extends Equatable {
  const SalesState(
      {this.status = SalesStatus.initial,
      this.sales,
      this.current = 0,
      this.lastpage = false,
      this.filter = SalesFilter.none});

  const SalesState._(
      {this.status = SalesStatus.initial,
      this.sales,
      this.current = 0,
      this.lastpage = false,
      this.filter = SalesFilter.none});

  /// Initial State
  ///
  /// Fungsi ini dipanggil saat pertama aplikasi di jalankan
  ///
  SalesState.init() : this._(sales: List.empty());

  /// Success State
  ///
  /// Fungsi ini dipanggil saat menerima data baru
  ///
  const SalesState.success(
      {List<SalesModel> saleslist,
      int newcurrent = 0,
      bool lastpagedata = false,
      SalesFilter filter = SalesFilter.none})
      : this._(
            status: SalesStatus.success,
            sales: saleslist,
            current: newcurrent,
            lastpage: lastpagedata,
            filter: filter);

  /// Replace state
  ///
  /// Replaced state manage
  ///
  SalesState replace({SalesStatus status = SalesStatus.success}) => SalesState(
      status: status,
      sales: this.sales,
      current: this.current,
      lastpage: this.lastpage,
      filter: this.filter);

  final SalesStatus status;
  final List<SalesModel> sales;
  final int current;
  final bool lastpage;
  final SalesFilter filter;

  bool get isfilterfromdate => filter == SalesFilter.fromdate;
  bool get isinitial => status == SalesStatus.initial;
  bool get empty => sales == List.empty();
  bool get isloading => status == SalesStatus.loading;

  @override
  List<Object> get props => [status, sales, current, lastpage, filter];
}

/// Sales Status
///
/// [status] => [loading, initial, success, empty]
///
/// [documentation]
///
/// loadmore => status ini dijalankan saat fungsi loadmore dijalankan
///
/// initial => status hanya dijalankan saat aplikasi pertamakali dijalankan
///
/// loading => status ini dijalankan saat user mengganti status sales berdasarkan tanggal atau sebaliknya
///
///
enum SalesStatus { loadmore, initial, loading, success, refresh }

/// Sales Filter
///
/// none => Tidak ada filter
/// [][][]
/// fromdate => Sales data di filter berdasarkan tanggal
///
enum SalesFilter { none, fromdate }
