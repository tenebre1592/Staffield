import 'package:Staffield/core/models/penalty_type.dart';
import 'package:Staffield/core/utils/calc_total_mixin.dart';
import 'package:Staffield/core/models/entry.dart';
import 'package:Staffield/core/models/penalty_mixin_time_by_money.dart';

class EntryReport extends Entry with TimeByMoney, CalcTotal {
  EntryReport() {
    for (var type in PenaltyType.allTypes) penaltiesTotalByType[type] = 0.0;
  }
  EntryReport.fromEntry(Entry entry) {
    for (var type in PenaltyType.allTypes) penaltiesTotalByType[type] = 0.0;
    uid = entry.uid;
    employeeNameAux = entry.employeeNameAux;
    revenue = entry.revenue;
    interest = entry.interest;
    wage = entry.wage;
    penalties = entry.penalties;
    time = 0;

    var calcTotalResult =
        calcTotalAndBonus(revenue: revenue, interest: interest, wage: wage, penalties: penalties);
    penaltiesTotalAux = calcTotalResult.penaltiesTotal;
    total = calcTotalResult.total;

    for (var penalty in penalties) {
      // if (penaltiesTotalByType[penalty.type] == null) penaltiesTotalByType[penalty.type] = 0.0;
      switch (penalty.type) {
        case PenaltyType.plain:
          {
            penaltiesTotalByType[penalty.type] += penalty.total;
          }
          break;
        case PenaltyType.timeByMoney:
          {
            penaltiesTotalByType[penalty.type] += (penalty.time * penalty.money);
            time += penalty.time;
          }
          break;
      }
      penaltiesCount++;
    }
  }

  int penaltiesCount = 0;
  Map<String, double> penaltiesTotalByType = {};

  @override
  String toString() {
    return super.toString() +
        ' penaltiesCount: $penaltiesCount, penaltiesTotalByType: $penaltiesTotalByType';
  }
}
