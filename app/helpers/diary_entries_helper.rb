module DiaryEntriesHelper

  def close_table
    if @table_is_open
      @table_is_open = false
      "</tbody>\n</table>\n".html_safe
    else
      ""
    end
  end

  def open_table
    @table_is_open = true
    out = "<table class=\"list time-entries\">\n"
    out += "<thead>\n<tr>\n"
    @query.inline_columns.each do |column|
      out += "<th>#{column.caption}</th>\n"
    end
    out += "<th></th>\n</tr>\n</thead>\n<tbody>\n"
    out.html_safe
  end

  def user_header(user)
    if user.id != @user_id
      @user_id = user.id
      out = close_table
      out += content_tag(:h3, user.login)
      out += open_table
      out.html_safe
    else
      ""
    end
  end

  def close_day
    "</div>\n".html_safe
  end

  def open_day(day)
    if day != @day
      out = close_table
      out += close_day unless @day.nil?
      @day = day
      @user_id = nil
      out += "<div class=\"diary-day\">\n".html_safe
      out += content_tag(:h2, day)
      out.html_safe
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
