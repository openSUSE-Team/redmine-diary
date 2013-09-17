#
# This hook copies the comment from the issue to the time entry if the latter is
# blank (when updating an issue)
#
class DiaryIssueHook < Redmine::Hook::Listener
  def controller_issues_edit_before_save(context)
    journal = context[:journal]
    time_entry = context[:time_entry]

    # Instead of creating a time entry with a blank comment, copy the first 200
    # characters from the journal (the issue comment)
    if time_entry && journal && time_entry.comments.blank?
      comments = journal.notes[0..250]
      # To be honest, a new record is not expected at this point with the
      # current redmine implementation, but just in case...
      if time_entry.new_record?
        time_entry.comments = comments
      else
        time_entry.update_attribute :comments, comments
      end
    end
    true
  end
end

