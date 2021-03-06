import 'dart:async';
import 'dart:math';

import 'package:Staffield/core/entities/penalty_type.dart';
import 'package:Staffield/core/penalty_types_repository_interface.dart';
import 'package:Staffield/services/sqlite/srvc_sqlite_penalty_types_adapter.dart';
import 'package:get/get.dart';

class PenaltyTypesRepository {
  final PenaltyTypeRepositoryInterface sqliteAdapter = Get.find<PenaltyTypesAdapter>();
  var _repo = <PenaltyType>[];

  //-----------------------------------------
  var _streamCtrlCacheUpdates = StreamController<bool>.broadcast();
  Stream<bool> get updates => _streamCtrlCacheUpdates.stream;
  void _notifyRepoUpdates() => _streamCtrlCacheUpdates.sink.add(true);

  //-----------------------------------------
  List<PenaltyType> get repo => _repo;

  //-----------------------------------------
  PenaltyType getType(String typeUid) => _repo.firstWhere((type) => type.uid == typeUid);
  //-----------------------------------------
  Future<void> fetch() async {
    _repo = await sqliteAdapter.fetch();
    _notifyRepoUpdates();
  }

  //-----------------------------------------
  PenaltyType getRandom() {
    var random = Random();
    return _repo[random.nextInt(_repo.length)];
  }

  //-----------------------------------------
  Future<bool> addOrUpdate(PenaltyType type) async {
    if (type.uid == null)
      return false;
    else {
      var index = _repo.indexWhere((item) => item.uid == type.uid);
      if (index < 0)
        _repo.add(type);
      else
        _repo[index] = type;
    }
    var result = await sqliteAdapter.addOrUpdate(type);
    _notifyRepoUpdates();
    return result;
  }

  //-----------------------------------------
  Future<int> hideUnHide(PenaltyType type) async {
    var result = await sqliteAdapter.hideUnhide(uid: type.uid, hide: type.hide);
    _notifyRepoUpdates();
    return result;
  }

  //-----------------------------------------
  void dispose() {
    _streamCtrlCacheUpdates.close();
  }
}
