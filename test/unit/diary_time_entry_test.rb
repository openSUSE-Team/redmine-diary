require File.expand_path('../../test_helper', __FILE__)

class DiaryTest < ActiveSupport::TestCase
  fixtures  :projects, :enabled_modules,
            :users, :members, :member_roles, :roles, :groups_users

  setup :set_threshold

  def set_threshold
    Setting.plugin_redmine_diary['days_threshold'] = 2
  end

  def test_create_current
    entry = TimeEntry.new(:project => Project.find(1), :spent_on => Date.current,
                          :hours => 1, :user => User.find(3), :activity_id => 1)
    assert entry.save
  end

  def test_create_old
    # Let's travel in time to a Thursday
    Timecop.freeze(Date.parse('2013-08-15')) do
      # 3 days are too much
      entry = TimeEntry.new(:project => Project.find(1), :spent_on => 3.days.ago,
                          :hours => 1, :user => User.find(3), :activity_id => 1)
      assert !entry.save
      assert_include 'Date cannot be that much in the past', entry.errors.full_messages
      # But 2 are ok
      entry.spent_on = 2.days.ago
      assert entry.save
    end
  end

  def test_create_old_on_monday
    # Let's travel in time to a Monday
    Timecop.freeze(Date.parse('2013-08-12')) do
      # 4 days old is still ok, because of the weekend
      entry = TimeEntry.new(:project => Project.find(1), :spent_on => 3.days.ago,
                          :hours => 1, :user => User.find(3), :activity_id => 1)
      assert entry.save
    end
  end

  def test_update_old
    # Let's travel in time to a Tuesday
    Timecop.freeze(Date.parse('2013-08-13')) do
      user = User.find(3)
      entry = TimeEntry.create(:project => Project.find(1), :spent_on => Date.today,
                        :hours => 1, :user => user, :activity_id => 1)
      assert entry.editable_by?(user)
      # What about tomorrow?
      Timecop.freeze(1.day.since) do
        assert entry.editable_by?(user)
      end
      # And the day after?
      Timecop.freeze(2.day.since) do
        assert entry.editable_by?(user)
      end
      # But three days are too much
      Timecop.freeze(3.day.since) do
        assert !entry.editable_by?(user)
      end
    end
  end
end
