import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Goes up after every answer to a request. Kept alive, so an answer that
/// lands after its screen closed still reaches the lists open now.
class OffersRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final offersRevisionProvider = NotifierProvider<OffersRevision, int>(
  OffersRevision.new,
);
