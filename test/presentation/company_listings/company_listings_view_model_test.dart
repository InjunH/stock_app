import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:stock_app/data/repository/stock_repository_impl.dart';
import 'package:stock_app/data/source/local/company_listing_entity.dart';
import 'package:stock_app/data/source/local/stock_dao.dart';
import 'package:stock_app/data/source/remote/stock_api.dart';
import 'package:stock_app/presentation/company_listings/company_listings_view_model.dart';

void main() {
  test('company_listings_view_model 생성시 데이터를 잘 가져와야 한다.', () async {
    Hive.init(null);
    Hive.registerAdapter(CompanyListingEntityAdapter());
    final api = StockApi();
    final dao = StockDao();
    final viewModel = CompanyListingsViewModel(StockRepositoryImpl(api, dao));

    await Future.delayed(const Duration(milliseconds: 3000));

    expect(viewModel.state.companies.isNotEmpty, true);
  });
}
