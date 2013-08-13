require File.expand_path('../../test_helper', __FILE__)

class DiaryITest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :groups_users

  def test_create_current
    entry = TimeEntry.new(:project => Project.find(1), :spent_on => Date.current,
                          :hours => 1, :user => User.find(3), :activity_id => 1)
    assert entry.save
  end

  def test_create_old
    # FIXME
    # We should use delorean or a similar gem to really check if working days
    # are calculated properly. At this point I will go for the easy track: old
    # enough to skip a possible weekend
    entry = TimeEntry.new(:project => Project.find(1), :spent_on => 5.days.ago,
                          :hours => 1, :user => User.find(3), :activity_id => 1)
    assert !entry.save
    assert_include 'Date cannot be that much in the past', entry.errors.full_messages
  end
end
