import 'dart:async';

import 'package:Staffield/constants/routes_paths.dart';
import 'package:Staffield/core/employees_repository.dart';
import 'package:Staffield/core/entries_repository.dart';
import 'package:Staffield/core/entities/employee.dart';
import 'package:Staffield/core/entities/entry.dart';
import 'package:Staffield/core/entities/penalty.dart';
import 'package:Staffield/core/entities/penalty_mode.dart';
import 'package:Staffield/core/entities/penalty_type.dart';
import 'package:Staffield/core/penalty_types_repository.dart';
import 'package:Staffield/core/utils/calc_total_mixin.dart';
import 'package:Staffield/constants/routes.dart';
import 'package:Staffield/utils/string_utils.dart';
import 'package:Staffield/views/common/dialog_confirm.dart';
import 'package:Staffield/views/common/text_feild_handler/text_field_data_decimal.dart';
import 'package:Staffield/views/edit_employee/dialog_edit_employee.dart';
import 'package:Staffield/views/edit_entry/dialog_penalty/dialog_penalty.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VModelEditEntry extends GetxController {
  VModelEditEntry(String uid) {
    init(uid);
  }
  Entry entry;
  TextFieldDataDecimal interest;
  String labelBonus = 'БОНУС';
  String labelName = 'СОТРУДНИК';
  String labelPenalties = 'ШТРАФЫ';
  final int nameMaxLength = 40;
  double _penaltiesTotal;
  double _bonusAux;

  List<Penalty> penalties;
  TextFieldDataDecimal revenue;
  TextFieldDataDecimal wage;
  final dropdownKey = GlobalKey<FormFieldState>();
  final _employeesRepo = Get.find<EmployeesRepository>();

  final _entriesRepo = Get.find<EntriesRepository>();
  final _penaltyTypesRepo = Get.find<PenaltyTypesRepository>();

  init(String uid) {
    this.entry = uid == null ? Entry() : _entriesRepo.getEntry(uid);
    if (uid != null) {
      print('---------- view_edit_entry : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp)}');
    }
    wage = TextFieldDataDecimal(
      label: 'ОКЛАД',
      defaultValue:
          uid == null ? '' : entry.wage?.toString()?.formatAsCurrency(decimals: 2)?.noDotZero,
      onChanged: calcTotalAndNotify,
    );
    revenue = TextFieldDataDecimal(
      label: 'ВЫРУЧКА',
      defaultValue:
          uid == null ? '' : entry.revenue?.toString()?.formatAsCurrency(decimals: 2)?.noDotZero,
      onChanged: calcTotalAndNotify,
    );
    interest = TextFieldDataDecimal(
      label: 'ПРОЦЕНТ',
      maxLength: 5,
      defaultValue:
          uid == null ? '' : entry.interest?.toString()?.formatAsCurrency(decimals: 2)?.noDotZero,
      onChanged: calcTotalAndNotify,
      validator: validateInterest,
    );
    penalties = entry.penalties.map((penalty) => Penalty.copy(penalty)).toList();
    calcTotal();
  }

  //-----------------------------------------
  String get bonus => _bonusAux.toString().formatAsCurrency(decimals: 2);

  //-----------------------------------------
  List<DropdownMenuItem<String>> get employeesItems {
    var result = _employeesRepo.repoWhereHidden(false)
      ..add(Employee(name: 'Добавить сотрудника...', uid: '111'));

    return result
        .map((employee) => DropdownMenuItem(value: employee.uid, child: Text(employee.name)))
        .toList();
  }

  //-----------------------------------------
  String get employeeUid {
    if (_employeesRepo.repo.any((element) => element.uid == entry.employee.uid)) {
      return entry.employee.uid;
    } else
      return null;
  }

  //-----------------------------------------
  String get penaltiesTotal => _penaltiesTotal.toString().formatAsCurrency(decimals: 2);

  //-----------------------------------------
  List<DropdownMenuItem> get penaltyTypesList {
    _penaltyTypesRepo.repo.forEach((element) {});
    var list = _penaltyTypesRepo.repo
        .map((type) => DropdownMenuItem<String>(child: Text(type.title), value: type.uid))
        .toList();
    list.add(DropdownMenuItem<String>(child: Text('Создать новый...'), value: '111'));
    return list;
  }

  //-----------------------------------------
  String get total => entry.total.toString().formatAsCurrency(decimals: 2);

  //-----------------------------------------
  void calcTotal([String _]) {
    var result = CalcTotal(
      revenue: revenue.value,
      interest: interest.value,
      wage: wage.value,
      penalties: penalties,
    );
    _bonusAux = result.bonus;
    entry.total = result.total;
    _penaltiesTotal = result.penaltiesTotal;
  }

  //-----------------------------------------
  void calcTotalAndNotify([String _]) {
    calcTotal();
    update(['calc']);
  }

  //-----------------------------------------
  PenaltyType getPenaltyType(String uid) => _penaltyTypesRepo.getType(uid);

  //-----------------------------------------
  Future<void> goBack(BuildContext context) async {
    if (penalties.isEmpty)
      Navigator.of(context).pop();
    else {
      var isConfirmed =
          await dialogConfirm(context, text: ('Изменения не будут сохранены. Продолжить?'));
      if (isConfirmed ?? false) Navigator.of(context).pop();
    }
  }

  //-----------------------------------------
  void handlePenalty(BuildContext context, String typeUid) {
    if (typeUid != '111')
      _addPenalty(context, typeUid);
    else
      _addPenaltyType(context);
  }

  //-----------------------------------------
  Future<void> removeEntry(BuildContext context) async {
    var _isConfirmed = await dialogConfirm(context, text: 'Удалить эту запись?');
    if (_isConfirmed ?? false) {
      _entriesRepo.remove(entry.uid);
      Navigator.of(context).pop();
    }
  }

  //-----------------------------------------
  void removePenalty(Penalty item) {
    var index = penalties.indexOf(item);
    if (index >= 0) penalties.removeAt(index);
    calcTotalAndNotify();
  }

  //-----------------------------------------
  void save() {
    entry.timestamp = DateTime.now().millisecondsSinceEpoch;
    entry.penalties = penalties.toList();
    entry.wage = wage.value;
    entry.revenue = revenue.value;
    entry.interest = interest.value;
    calcTotal();
    _entriesRepo.addOrUpdate([entry]);
  }

  //-----------------------------------------
  Future<void> setEmployeeUid(String uid, BuildContext context) async {
    if (uid != '111') {
      entry.employee = _employeesRepo.getEmployeeByUid(uid);
    } else {
      var result =
          await showDialog<Employee>(context: context, builder: (context) => DialogEditEmployee());
      if (result != null) {
        entry.employee = result;
        dropdownKey.currentState.didChange(result.uid);
      }
    }
    update();
  }

  //-----------------------------------------
  void updatePenalty(Penalty item) {
    var index = penalties.indexOf(item);
    if (index >= 0) penalties[index] = item;
    calcTotalAndNotify();
  }

  //-----------------------------------------
  String validateEmployeeUid(String txt) {
    if (txt == null)
      return 'Выберите сотрудника';
    else {
      return null;
    }
  }

  //-----------------------------------------
  String validateInterest(String txt) {
    if (txt.isEmpty)
      return 'Введите';
    else if (txt.endsWith('.'))
      return 'Проверьте';
    else if ((double.tryParse(txt) ?? 101) > 100)
      return 'Проверьте';
    else {
      return null;
    }
  }

  //-----------------------------------------
  Future<void> _addPenalty(BuildContext context, String typeUid) async {
    var result = await showDialog<Penalty>(
      context: context,
      builder: (BuildContext context) => DialogPenalty(
        penalty: Penalty(typeUid: typeUid, parentUid: entry.uid),
        isNewPenalty: true,
        screenEntryVModel: this,
      ),
    );
    if (result != null) penalties.add(result);
    calcTotalAndNotify();
  }

  //-----------------------------------------
  void _addPenaltyType(BuildContext context) {
    Routes.sailor.navigate(RoutesPaths.editPenaltyType,
        params: {'penaltyType': PenaltyType(mode: PenaltyMode.plain)});
  }
}
