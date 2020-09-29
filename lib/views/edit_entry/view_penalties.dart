import 'package:Staffield/views/edit_entry/dialog_penalty/dialog_penalty.dart';
import 'package:flutter/material.dart';
import 'package:Staffield/constants/app_colors.dart';
import 'package:Staffield/core/entities/penalty.dart';
import 'package:Staffield/views/edit_entry/vmodel_edit_entry.dart';
import 'package:Staffield/utils/string_utils.dart';

class ViewPenalties extends StatelessWidget {
  ViewPenalties(this.screenEditEntryVModel);
  final ScreenEditEntryVModel screenEditEntryVModel;
  @override
  Widget build(BuildContext context) {
    var penalties = screenEditEntryVModel.penalties;
    return Column(
      children: <Widget>[
        if (penalties != null)
          ...penalties.map((penalty) => ViewPenaltiesItem(penalty, screenEditEntryVModel)).toList()
      ],
    );
  }
}

class ViewPenaltiesItem extends StatelessWidget {
  ViewPenaltiesItem(this.penalty, this.vModel);
  final Penalty penalty;
  final ScreenEditEntryVModel vModel;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.primaryBlend,
      child: InkWell(
        onTap: () async {
          var res = await showDialog<Penalty>(
            context: context,
            builder: (BuildContext context) =>
                DialogPenalty(penalty: penalty, screenEntryVModel: vModel),
          );

          if (res != null) vModel.updatePenalty(res);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Row(children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    vModel.getPenaltyType(penalty.typeUid).title.toUpperCase(),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      penalty.total.toString().formatInt,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
          ]),
        ),
      ),
    );
  }
}
