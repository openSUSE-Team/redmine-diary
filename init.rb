require 'diary_time_entry_patch'
require 'diary_issue_hook'

Redmine::Plugin.register :redmine_diary do
  name 'Redmine diary'
  author 'Ancor Gonzalez Sosa'
  description 'Diary view for time entries plus some related goodies'
  version '0.0.6'
  url 'https://github.com/openSUSE-Team/redmine-diary'
  author_url 'https://github.com/ancorgs'
  
  requires_redmine :version_or_higher => '2.3.1'

  menu :top_menu, :diary_entries, {:controller => :diary_entries, :action => :index},
       :caption => :label_diary, :after => :home,
       :if => Proc.new { User.current.allowed_to?(:view_time_entries, nil, :global => true) }

  settings :partial => 'settings/redmine_diary_settings',
           :default => { 'default_project_id' => nil,
                         'days_threshold' => nil }
end

Rails.configuration.to_prepare do
  require_dependency 'time_entry'
  TimeEntry.send(:include, DiaryTimeEntryPatch)
end
