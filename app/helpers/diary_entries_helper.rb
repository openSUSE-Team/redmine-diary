module DiaryEntriesHelper

  def close_user
    if @user_is_open
      @user_is_open = false
      "</tbody>\n".html_safe
    else
      ""
    end
  end

  def user_header(user)
    if user.id != @user_id
      out = close_user.html_safe
      @user_id = user.id
      @user_is_open = true
      out += "<thead>\n<tr>\n".html_safe
      out += "<th class=\"diary-user\" colspan=\"#{@query.inline_columns.size+1}\">#{user.login}</th>\n".html_safe
      out += "<tbody>\n".html_safe
      raw out
    else
      ""
    end
  end

  def close_day
    raw(close_user.html_safe + "</table>\n</div>\n".html_safe)
  end

  def open_day(day)
    if day != @day
      out = @day.nil? ? "" : close_day.html_safe
      @user_is_open = false
      @day = day
      @user_id = nil
      out += "<div class=\"diary-day\">\n".html_safe
      out += content_tag(:h2, day)
      out += "<table class=\"list time-entries\">\n".html_safe
      out += "<thead>\n<tr>\n".html_safe
      @query.inline_columns.each do |column|
        out += "<th>#{column.caption}</th>\n".html_safe
      end
      out += "<th></th>\n</tr>\n</thead>\n".html_safe
      raw out
    else
      ""
    end
  end

  def diary_column_content(column, entry)
    if column.name.to_sym == :comments
      content_tag('div', textilizable(entry, :comments), :class => "wiki")
    else
      column_content(column, entry)
    end
  end
end
