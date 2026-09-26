import '../../../../core/api/api_client.dart';
import '../../../../core/error/exceptions/api_exception.dart';
import '../../../../core/api/json_reader.dart';
import '../../domain/entities/offer.dart';

class ApiOffersRepository implements OffersRepository {
  ApiOffersRepository(this._api);

  final ApiClient _api;

  @override
  Future<OfferList> fetch({
    OfferTab tab = OfferTab.pending,
    OfferSort? sort,
  }) async {
    final data = JsonReader.of(
      await _api.get(
        '/offers',
        query: {'status': tab.name, 'sort': ?sort?.name},
      ),
    );
    return OfferList(
      pendingCount: data.read<int>('pendingCount'),
      pendingCountLabel: data.read<int>('pendingCountLabel'),
      offers: data.readList('offers', offerFromJson),
    );
  }

  @override
  Future<Offer> detail(String id) async =>
      offerFromJson(JsonReader.of(await _api.get('/offers/${_segment(id)}')));

  @override
  Future<Offer> accept(String id) async => offerFromJson(
    JsonReader.of(await _api.post('/offers/${_segment(id)}/accept')),
  );

  @override
  Future<Offer> reject(String id) async => offerFromJson(
    JsonReader.of(await _api.post('/offers/${_segment(id)}/reject')),
  );

  static String _segment(String id) => Uri.encodeComponent(id);
}

Offer offerFromJson(JsonReader json) {
  final expiresAt = DateTime.tryParse(json.read<String>('expiresAt'));
  if (expiresAt == null) {
    throw const ApiException(
      code: ApiException.badResponse,
      message: 'Unexpected API data: expiresAt',
    );
  }
  return Offer(
    id: json.read<String>('id'),
    title: json.read<String>('title'),
    place: json.read<String>('place'),
    pay: json.read<String>('pay'),
    logoPath: json.read<String>('logo'),
    district: json.read<String>('district'),
    when: json.read<String>('when'),
    status: json.readEnum('status', OfferStatus.values),
    remain: json.read<String>('remain'),
    expiresAt: expiresAt,
    city: json.readOptional<String>('city'),
    note: json.readOptional<String>('note'),
  );
}
