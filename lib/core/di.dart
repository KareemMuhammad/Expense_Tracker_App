import 'package:get_it/get_it.dart';

import '../data/data_source/currency_remote_data_source.dart';
import '../data/data_source/expenses_local_data_source.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<CurrencyRemoteDataSource>(
    () => CurrencyRemoteDataSource(),
  );

  getIt.registerLazySingleton<ExpensesLocalDataSource>(
    () => ExpensesLocalDataSource(),
  );

  await getIt.get<ExpensesLocalDataSource>().init();
}
