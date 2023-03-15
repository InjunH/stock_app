// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:stock_app/data/csv/company_listings_parser.dart';
import 'package:stock_app/data/mapper/company_mapper.dart';
import 'package:stock_app/data/source/local/stock_dao.dart';
import 'package:stock_app/data/source/remote/stock_api.dart';
import 'package:stock_app/domain/model/company_listing.dart';
import 'package:stock_app/domain/repository/stock_repository.dart';
import 'package:stock_app/util/result.dart';

import '../source/local/company_listing_entity.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApi _api;
  final StockDao _dao;
  final _parser = CompanyListingsParser();

  StockRepositoryImpl(
    this._api,
    this._dao,
  );

  @override
  Future<Result<List<CompanyListing>>> getCompanyListings(
      bool fetchFromRemote, String query) async {
    /// 캐시에서 찾는다
    final List<CompanyListingEntity> localListings =
        await _dao.searchCompanyListing(query);

    /// 없다면 remote에서 찾는다
    final isDBEmpty = localListings.isEmpty && query.isEmpty;
    final shouldJustLoadFromCache = !isDBEmpty && !fetchFromRemote;

    if (shouldJustLoadFromCache) {
      return Result.success(
          localListings.map((e) => e.toCompanyListing()).toList());
    }

    /// remote
    try {
      final response = await _api.getListings();
      final remoteListings = await _parser.parse(response.body);

      // clean caching
      await _dao.clearCompanyListings();
      // add caching
      await _dao.insertCompanyListings(
          remoteListings.map((e) => e.toCompanyListingEntity()).toList());

      // todo csv 파싱 필요
      return Result.success(remoteListings);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
