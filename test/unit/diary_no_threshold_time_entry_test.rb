require File.expand_path('../../test_helper', __FILE__)

class DiaryTest < ActiveSupport::TestCase
  fixtures  :projects, :enabled_modules,
            :users, :members, :member_roles, :roles, :groups_users

  setup :disable_threshold

  def disable_threshold
    Setting.plugin_redmine_diary['days_threshold'] = 0
  end

  def test_create_old
    entry = TimeEntry.new(:project => Project.find(1), :spent_on => 4.days.ago,
                          :hours => 1, :user => User.find(3), :activity_id => 1)
    assert entry.save
  end

  def test_update_old
    user = User.find(3)
    entry = TimeEntry.create(:project => Project.find(1), :spent_on => Date.today,
                        :hours => 1, :user => user, :activity_id => 1)
    assert entry.editable_by?(user)
    # Travel four days to the future
    Timecop.freeze(4.day.since) do
      assert entry.editable_by?(user)
    end
  end
end
