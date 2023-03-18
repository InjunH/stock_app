// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:stock_app/data/mapper/company_mapper.dart';
import 'package:stock_app/data/source/local/stock_dao.dart';
import 'package:stock_app/data/source/remote/stock_api.dart';
import 'package:stock_app/domain/model/company_info.dart';
import 'package:stock_app/domain/model/company_listing.dart';
import 'package:stock_app/domain/model/intraday_info.dart';
import 'package:stock_app/domain/repository/stock_repository.dart';
import 'package:stock_app/util/result.dart';

import '../csv/company_listings_parser.dart';
import '../csv/intraday_info_parser.dart';
import '../source/local/company_listing_entity.dart';

class StockRepositoryImpl implements StockRepository {
  final StockApi _api;
  final StockDao _dao;
  final _companyListingsParser = CompanyListingsParser();
  final _intradayInfoParser = IntradayInfoParser();

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
      final remoteListings = await _companyListingsParser.parse(response.body);

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

  @override
  Future<Result<CompanyInfo>> getCompanyInfo(String symbol) async {
    try {
      final dto = await _api.getCompanyInfo(symbol: symbol);
      return Result.success(dto.toCompanyInfo());
    } catch (e) {
      return Result.error(Exception('회사 정보 로드 실패 ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<IntradayInfo>>> getIntradayInfo(String symbol) async {
    try {
      final response = await _api.getIntradayInfo(symbol: symbol);
      final result = await _intradayInfoParser.parse(response.body);
      return Result.success(result);
    } catch (e) {
      return Result.error(Exception('intraday Info load fail ${e.toString()}'));
    }
  }
}
