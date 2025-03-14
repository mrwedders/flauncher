/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flauncher/widgets/settings/launcher_section_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/category.dart';

class LauncherSectionsPanelPage extends StatelessWidget
{
  static const String routeName = "launcher_sections_panel";

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    return Column(
        children: [
          Text(localizations.launcherSections, style: Theme.of(context).textTheme.titleLarge),
          Divider(),
          Consumer<AppsService>(
            builder: (_, service, __) {
              List<LauncherSection> sections = service.launcherSections;

              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: sections.indexed.map((tuple) {
                      int index = tuple.$1;
                      bool last = index == sections.length - 1;

                      return _section(context, sections[index], index, last, index == 0);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 4, width: 0),
          TextButton.icon(
            icon: Icon(Icons.add),
            label: Text(localizations.addSection),
            onPressed: () {
              Navigator.pushNamed(context, LauncherSectionPanelPage.routeName);
            },
          ),
        ],
      );
  }

  Widget _section(BuildContext context, LauncherSection section, int index, bool last, bool autofocus) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    String title = localizations.spacer;
    if (section is Category) {
      title = section.name;
      
      if (title == localizations.spacer) {
        title = localizations.disambiguateCategoryTitle(title);
      }
    }
    
    return Padding(
      //key: Key(section.order.toString()),
      padding: EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: EnsureVisible(
          alignment: 0.5,
          child: ListTile(
            dense: true,
            title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                  icon: Icon(Icons.arrow_upward),
                  onPressed: index > 0 ? () => _move(context, index, index - 1) : null,
                ),
                IconButton(
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                  icon: Icon(Icons.arrow_downward),
                  onPressed: last ? null : () => _move(context, index, index + 1),
                ),
                IconButton(
                  autofocus: autofocus,
                  constraints: BoxConstraints(),
                  splashRadius: 20,
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, LauncherSectionPanelPage.routeName, arguments: index);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _move(BuildContext context, int oldIndex, int newIndex) async {
    await context.read<AppsService>().moveSection(oldIndex, newIndex);
  }
}
