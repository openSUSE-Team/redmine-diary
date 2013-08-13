# This module is included into the TimeEntry model to prevent users from
# creating, updating or destroying time entries that are older than a threshold
# (two working days).
#
# It works by creating a validation and redefining TimeEntry#editable_by?
module DiaryTimeEntryPatch
  def self.included(base)

    base.class_eval do

      # Threshold in order to consider that time entries are too old to be
      # created or modified: two working days in the past
      def self.min_date_for_modifications
        non_w_days = Setting.non_working_week_days || []
        non_w_days.map!(&:to_i)
        day = Date.current
        days_left = 2
        while days_left > 0
          day -= 1
          days_left -=1 unless non_w_days.include? day.cwday
        end
        day
      end

      # Cannot modify or create time entries related to the past
      validate :not_too_old

      # Nobody can edit old time entries
      def editable_by_with_date_check?(usr)
        return false if self.spent_on && (self.spent_on < TimeEntry.min_date_for_modifications)
        editable_by_without_date_check?(usr)
      end

      alias_method_chain :editable_by?, :date_check

      protected

      def not_too_old
        if self.spent_on < TimeEntry.min_date_for_modifications
          errors.add :spent_on, :too_old
        end
      end
    end
  end
end
