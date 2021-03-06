import 'package:Staffield/core/entities/penalty_type.dart';
import 'package:Staffield/core/penalty_types_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Staffield/core/entities/penalty_mode.dart';
import 'package:get/get.dart';

class ScreenEditPenaltyTypeVModel extends ChangeNotifier {
  ScreenEditPenaltyTypeVModel(this.type);

  PenaltyType type;

  String get mode => type.mode;
  set mode(String mode) {
    type.mode = mode;
    notifyListeners();
  }

  final _penaltyTypesRepo = Get.find<PenaltyTypesRepository>();

  //-----------------------------------------
  bool save(GlobalKey<FormState> formKey) {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      _penaltyTypesRepo.addOrUpdate(type);
      return true;
    } else
      return false;
  }

  //-----------------------------------------
  void remove() {
    // screenEntryVModel.removePenalty(penalty);
  }

  //-----------------------------------------
  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      DropdownMenuItem<String>(child: Text('ПРОСТОЙ ШТРАФ'), value: PenaltyMode.plain),
      DropdownMenuItem<String>(child: Text('ЦЕНА ЗА ЕДИНИЦУ'), value: PenaltyMode.calc),
    ];
  }
}
