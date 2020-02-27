// Copyright 2020 Kenton Hamaluik
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timecop/blocs/projects/bloc.dart';
import 'package:timecop/blocs/timers/bloc.dart';
import 'package:timecop/components/ProjectColour.dart';
import 'package:timecop/models/timer_entry.dart';

class RunningTimerRow extends StatelessWidget {
  final TimerEntry timer;
  final DateTime now;
  const RunningTimerRow({Key key, @required this.timer, @required this.now})
    : assert(timer != null),
      assert(now != null),
      super(key: key);

  static String formatDescription(String description) {
    if(description == null || description.trim().isEmpty) {
      return "(no description)";
    }
    return description;
  }

  static TextStyle styleDescription(BuildContext context, String description) {
    if(description == null || description.trim().isEmpty) {
      return TextStyle(color: Theme.of(context).disabledColor);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      child: ListTile(
        leading: ProjectColour(project: BlocProvider.of<ProjectsBloc>(context).getProjectByID(timer.projectID)),
        title: Text(formatDescription(timer.description), style: styleDescription(context, timer.description)),
        trailing: Text(timer.formatDuration(), style: TextStyle(fontFamily: "FiraMono")),
      ),
      actions: <Widget>[
        IconSlideAction(
          color: Theme.of(context).errorColor,
          foregroundColor: Theme.of(context).accentIconTheme.color,
          icon: FontAwesomeIcons.trash,
          onTap: () async {
            bool delete = await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text("Confirm Delete"),
                content: Text("Are you sure you want to delete this timer?"),
                actions: <Widget>[
                  FlatButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FlatButton(
                    child: const Text("Delete"),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              )
            );
            if(delete) {
              final TimersBloc timersBloc = BlocProvider.of<TimersBloc>(context);
              assert(timersBloc != null);
              timersBloc.add(DeleteTimer(timer));
            }
          },
        )
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          color: Theme.of(context).accentColor,
          foregroundColor: Theme.of(context).accentIconTheme.color,
          icon: FontAwesomeIcons.solidStopCircle,
          onTap: () {
            final TimersBloc timers = BlocProvider.of<TimersBloc>(context);
            assert(timers != null);
            timers.add(StopTimer(timer));
          },
        )
      ],
    );
  }
}