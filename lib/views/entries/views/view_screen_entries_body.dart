import 'package:Staffield/constants/app_gradients.dart';
import 'package:Staffield/constants/app_text_styles.dart';
import 'package:Staffield/core/models/entry_report.dart';
import 'package:Staffield/views/entries/screen_entries_vmodel.dart';
import 'package:Staffield/views/entries/views/view_screen_entries_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewScreenEntriesBody extends StatefulWidget {
  @override
  _ViewScreenEntriesBodyState createState() => _ViewScreenEntriesBodyState();
}

class _ViewScreenEntriesBodyState extends State<ViewScreenEntriesBody> {
  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
              child: Selector<ScreenEntriesVModel, bool>(
            selector: (_, vModel) => vModel.endOfData,
            builder: (context, endOfData, child) {
              return Selector<ScreenEntriesVModel, List<EntryReport>>(
                selector: (context, vModel) => vModel.cache,
                builder: (_, list, __) {
                  if (list.length == 0)
                    return endOfData
                        ? Center(
                            child: Text('Нет записей',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: Colors.white)),
                          )
                        : Center(child: CircularProgressIndicator());
                  else
                    return NotificationListener<ScrollNotification>(
                      onNotification: (notif) {
                        if (notif.metrics.extentAfter < 200)
                          Provider.of<ScreenEntriesVModel>(context, listen: false).fetchNextChunk();
                        return true;
                      },
                      child: Scrollbar(
                        child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (context, index) => list[index].isDateLabel
                                ? Container(
                                    padding: EdgeInsets.only(left: 8.0),
                                    margin: EdgeInsets.only(top: 14.0, bottom: 14.0),
                                    alignment: Alignment.centerLeft,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.mirage,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black,
                                          spreadRadius: 0,
                                          blurRadius: 2,
                                          offset: Offset(0, 1), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child:
                                        Text(list[index].dateLabel, style: AppTextStyles.dateLabel),
                                  )
                                : ViewScreenEntriesItem(list[index])),
                      ),
                    );
                },
              );
            },
          )),
        ],
      );
}