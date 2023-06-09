// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:stock_app/domain/model/intraday_info.dart';

import 'package:stock_app/domain/repository/stock_repository.dart';
import 'package:stock_app/presentation/company_info/company_info_state.dart';

class CompanyInfoViewModel with ChangeNotifier {
  final StockRepository _repository;

  var _state = const CompanyInfoState();

  CompanyInfoState get state => _state;

  CompanyInfoViewModel(this._repository, String symbol) {
    loadCompanyInfo(symbol);
  }

  void loadCompanyInfo(String symbol) async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _repository.getCompanyInfo(symbol);

    result.when(
      success: (info) {
        print(info);
        _state = state.copyWith(companyInfo: info, isLoading: false);
      },
      error: (e) {
        _state = state.copyWith(
            companyInfo: null, isLoading: false, errorMessage: e.toString());
      },
    );

    notifyListeners();

    final intradayInfo = await _repository.getIntradayInfo(symbol);

    intradayInfo.when(
      success: (stockInfo) {
        _state = state.copyWith(
            stockInfos: stockInfo, isLoading: false, errorMessage: null);
      },
      error: (e) {
        _state = state.copyWith(
            stockInfos: [], isLoading: false, errorMessage: e.toString());
      },
    );

    notifyListeners();
  }
}
