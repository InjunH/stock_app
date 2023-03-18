import 'package:intl/intl.dart';
import 'package:stock_app/data/source/remote/dto/intraday_info_dto.dart';
import 'package:stock_app/domain/model/intraday_info.dart';

extension ToIntradayInfo on IntradayInfoDto {
  IntradayInfo toIntradayInfo() {
    final fomatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return IntradayInfo(date: fomatter.parse(timestamp), close: close);
  }
}
