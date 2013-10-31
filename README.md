# Redmine Diary

Redmine plugin to use time requests for reporting daily activity

## Install

Just place it at `plugins/redmine_diary` (yes, with underscore) 
and restart Redmine.

## Usage

This plugin implements all the goodies needed for a very particular use case:
using Redmine's "spent time entries" to log the daily activity in a central
diary providing a fast overview of the activity for every single day.

The plugin provides a new top level menu entry called "diary" visible for users
with the right permissions to read time entries. Clicking on it will show a list
of time entries grouped by date and user. It's possible to add time entries
directly from this view using the form at the top of the page.

In addition, the plugin can be configured to prevent the creation, modification
and deletion of old time entries, in order to encourage users to keep the time
entries up to date, using them for logging the activity in a daily basis. On
the other hand, to reduce the number of time entries with blank comments and
to speedup reporting, time entries created while updating an issue are filled
with the content of the journal (comment) for that update (if the update is
commented but the time entry is not).

## Support

Tested with Redmine 2.3.1 and 2.3.2 and both Ruby 1.9.3 and 1.8.7.

## License

The Redmine Diary Plugin is licensed under the MIT License (LICENSE.txt).

Copyright (c) 2013 Ancor González Sosa
