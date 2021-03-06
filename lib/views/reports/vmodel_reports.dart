import 'dart:async';

import 'package:Staffield/core/employees_repository.dart';
import 'package:Staffield/core/entities/employee.dart';
import 'package:Staffield/core/reports_repository.dart';
import 'package:Staffield/views/reports/report_type.dart';
import 'package:Staffield/views/reports/views/fl_charts/area_fl_charts.dart';
import 'package:Staffield/views/reports/views/fl_charts/components/chart_data.dart';
import 'package:Staffield/views/reports/views/fl_charts/components/report_criteria.dart';
import 'package:Staffield/views/reports/views/fl_charts/components/show_platform_date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class VModelReports extends GetxController {
  @override
  void onInit() {
    if (employees.isNotEmpty) _employee = employees.first;
    selectedEmployees = employees;
    fetchReportData();
    super.onInit();
  }

  final _reportsRepo = ReportsRepository();
  final _employeesRepo = Get.find<EmployeesRepository>();

  ReportType _reportType = ReportType.fl_charts;
  Units period = Units.MONTH;
  var selectedEmployees = <Employee>[];
  String penaltyTypeCurrentUid = '111';

  Widget view = Center(child: CircularProgressIndicator());

  //-----------------------------------------
  List<Employee> get employees => _employeesRepo.repoWhereHidden(false);

  //-----------------------------------------
  Employee _employee;

  Employee get employee => _employee;
  set employee(Employee employee) {
    _employee = employee;
    fetchReportData();
  }

  //-----------------------------------------
  var _criterion = ReportCriterion.total;

  ReportCriterion get criterion => _criterion;
  set criterion(ReportCriterion value) {
    if (value != ReportCriterion.total && _auxMenuCurrentValue == MenuWageItem.bonus) {
      _auxMenuCurrentValue = MenuWageItem.sum;
    }
    _criterion = value;
    fetchReportData();
  }

  //-----------------------------------------
  int _periodsAmount = 6;

  int get periodsAmount => _periodsAmount;
  set periodsAmount(int amount) {
    _periodsAmount = amount;
    fetchReportData();
  }

  //-----------------------------------------
  DateTime _startDate = DateTime.now();
  String get startDate => Jiffy(_startDate).yMMMd;

  //-----------------------------------------
  MenuWageItem _auxMenuCurrentValue = MenuWageItem.sum;
  static var _auxMenuTextStyle = TextStyle(color: Colors.lightBlueAccent, fontSize: 20.0);

  MenuWageItem get auxMenuCurrentValue => _auxMenuCurrentValue;
  set auxMenuCurrentValue(MenuWageItem value) {
    _auxMenuCurrentValue = value;
    fetchReportData();
  }

  //- - - - - - - - - - - - - - - - - - -
  var auxMenuWageItems = [
    DropdownMenuItem(value: MenuWageItem.sum, child: Text('сумма', style: _auxMenuTextStyle)),
    DropdownMenuItem(value: MenuWageItem.bonus, child: Text('бонусы', style: _auxMenuTextStyle)),
    DropdownMenuItem(value: MenuWageItem.avg, child: Text('средняя', style: _auxMenuTextStyle)),
  ];

  //- - - - - - - - - - - - - - - - - - -
  var auxMenuRevenueItems = [
    DropdownMenuItem(value: MenuWageItem.sum, child: Text('сумма', style: _auxMenuTextStyle)),
    DropdownMenuItem(value: MenuWageItem.avg, child: Text('средняя', style: _auxMenuTextStyle)),
  ];

  //-----------------------------------------
  Future<void> pickStartDate(BuildContext context) async {
    DateTime date = await showPlatformDatePicker(context, _startDate);
    if (date != null) {
      _startDate = date;
      fetchReportData();
    }
  }

  //-----------------------------------------
  Future<void> fetchReportData() async {
    view = Center(child: CircularProgressIndicator());
    update();

    switch (_reportType) {
      case ReportType.fl_charts:
        {
          var reports = _reportsRepo.fetch(
            periodsAmount: _periodsAmount,
            period: period,
            employees: selectedEmployees,
            startDate: _startDate,
          );
          reports.then((reports) {
            view = AreaFlCharts(ChartData(
              reports,
              criterion,
              penaltyTypeUid: penaltyTypeCurrentUid,
              auxMenuValue: auxMenuCurrentValue,
            ));
            update();
          });
        }
        break;
    }
  }
}

enum MenuWageItem { sum, bonus, avg }
