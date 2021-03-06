import 'package:Staffield/core/entities/penalty_type.dart';
import 'package:Staffield/core/penalty_types_repository_interface.dart';
import 'package:Staffield/services/sqlite/penalty_types_sqlite_srvc.dart';
import 'package:Staffield/services/sqlite/sqlite_convert.dart';
import 'package:get/get.dart';

class PenaltyTypesAdapter implements PenaltyTypeRepositoryInterface {
  final PenaltyTypesSqliteSrvc _srvcSqlitePenaltyTypes = Get.find();

  //-----------------------------------------
  @override
  Future<List<PenaltyType>> fetch() async {
    var result = await _srvcSqlitePenaltyTypes.fetch();
    return result.map((map) => SqliteConvert.mapToPenaltyType(map)).toList();
  }

  //-----------------------------------------
  @override
  Future<bool> addOrUpdate(PenaltyType type) =>
      _srvcSqlitePenaltyTypes.addOrUpdate(SqliteConvert.penaltyTypeToMap(type));

  //-----------------------------------------
  @override
  Future<int> hideUnhide({String uid, bool hide}) =>
      _srvcSqlitePenaltyTypes.hideUnhide(uid: uid, hide: hide);
}
