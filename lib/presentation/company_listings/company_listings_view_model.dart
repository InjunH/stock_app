// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_app/domain/repository/stock_repository.dart';
import 'package:stock_app/presentation/company_listings/company_listings_action.dart';
import 'package:stock_app/presentation/company_listings/company_listings_state.dart';

class CompanyListingsViewModel with ChangeNotifier {
  final StockRepository _repository;

  var _state = CompanyListingsState();

  Timer? _debounce;

  CompanyListingsState get state => _state;

  CompanyListingsViewModel(this._repository) {
    _getCompanyListings();
  }

  void onAction(CompanyListingsAction action) {
    action.when(
      refresh: () => _getCompanyListings(fetchFromRemote: true),
      onSearchQueryCahnge: (query) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          _getCompanyListings(query: query);
        });
      },
    );
  }

  Future _getCompanyListings(
      {bool fetchFromRemote = false, String query = ''}) async {
    _state = state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _repository.getCompanyListings(fetchFromRemote, query);

    result?.when(success: (listings) {
      _state = state.copyWith(companies: listings);
    }, error: (e) {
      // TODO : error
      print('remote error: ${e.toString()}');
    });

    _state = state.copyWith(isLoading: false);
    notifyListeners();
  }
}
