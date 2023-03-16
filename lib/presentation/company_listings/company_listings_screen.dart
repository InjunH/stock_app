import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_app/presentation/company_listings/company_listings_action.dart';
import 'package:stock_app/presentation/company_listings/company_listings_view_model.dart';

class CompanyListingsScreen extends StatelessWidget {
  const CompanyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CompanyListingsViewModel>();
    final state = viewModel.state;
    return Scaffold(
      body: SafeArea(
        top: true,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                viewModel
                    .onAction(CompanyListingsAction.onSearchQueryCahnge(query));
              },
              decoration: InputDecoration(
                  labelText: '검색....',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)))),
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () async {
              viewModel.onAction(const CompanyListingsAction.refresh());
            },
            child: ListView.builder(
              itemCount: state.companies.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(state.companies[index].name),
                    ),
                    Divider(
                      color: Theme.of(context).colorScheme.primary,
                    )
                  ],
                );
              },
            ),
          ))
        ]),
      ),
    );
  }
}