import 'package:stock_app/domain/model/company_info.dart';
import 'package:stock_app/domain/model/company_listing.dart';

import '../../util/result.dart';

abstract class StockRepository {
  Future<Result<List<CompanyListing>>>? getCompanyListings(
      bool fetchFromRemote, String query) {
    return null;
  }

  Future<Result<CompanyInfo>>? getCompanyInfo(String symbol) {
    return null;
  }
}
