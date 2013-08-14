require 'diary_time_entry_patch'

Redmine::Plugin.register :redmine_diary do
  name 'Extended views for time tracker'
  author 'Ancor Gonzalez Sosa'
  description 'WIP'
  version '0.0.1'
  url ''
  author_url ''
  
  requires_redmine :version_or_higher => '2.3.1'

  menu :top_menu, :diary_entries, {:controller => :diary_entries, :action => :index},
       :caption => :label_diary, :after => :home,
       :if => Proc.new { User.current.allowed_to?(:view_time_entries, nil, :global => true) }
end

Rails.configuration.to_prepare do
  require_dependency 'time_entry'
  TimeEntry.send(:include, DiaryTimeEntryPatch)
end
