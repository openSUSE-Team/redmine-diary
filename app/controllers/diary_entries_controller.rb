class DiaryEntriesController < ApplicationController
  unloadable

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :queries
  include QueriesHelper
  helper :timelog
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper

  before_filter :find_project_and_issue, :authorize_creation, :only => :create
  before_filter :find_time_entry, :only => [:destroy, :edit, :update]

  def index
    # For the listing
    list

    # For the new entry form
    project_id = params.delete(:entry_project_id) || Setting.plugin_redmine_diary['default_project_id']
    project = (Project.find(project_id) rescue nil)
    @time_entry ||= TimeEntry.new(:user => User.current, :project => project,
                                  :activity_id => params.delete(:entry_activity_id))
    @time_entry.safe_attributes = params[:time_entry]
    @time_entry.hours ||= 0
  end

  def create
    spent_on = params[:time_entry].delete(:spent_on)
    spent_on = User.current.today if spent_on.blank?
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => spent_on)
    @time_entry.safe_attributes = params[:time_entry]

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    # We want to reuse the rest of the parameters for the listing, but not the time_entry
    params.delete(:time_entry)

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_create)
          # Adding two additional params, because using params[:time_entry] seems to cause some problems
          redirect_to diary_entries_path(params.merge(:entry_project_id => @project.id, :entry_activity_id => @time_entry.activity_id))
        }
      end
    else
      respond_to do |format|
        format.html {
          # Prepare the list
          list
          render :action => 'index'
        }
      end
    end
  end

  def destroy
    @time_entry.destroy
    respond_to do |format|
      format.html {
        if @time_entry.destroyed?
          flash[:notice] = l(:notice_successful_delete)
        else
          flash[:error] = l(:notice_unable_delete_time_entry)
        end
        redirect_to diary_entries_path(params)
      }
    end
  end

  def edit
    @time_entry.safe_attributes = params[:time_entry]
  end

  def update
    @time_entry.safe_attributes = params[:time_entry]
    if (project_id = params[:time_entry][:project_id]).present?
      @time_entry.project = Project.find(project_id)
    end

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    # We want to reuse the rest of the parameters for the listing, but not the time_entry
    params.delete(:time_entry)

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_to diary_entries_path(params)
        }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
      end
    end
  end

  protected

  def list
    # By default, show this week
    params[:spent_on] = "w" if params[:spent_on].blank?
    # By default, show the four more relevant fields and custom fields
    if params[:c].blank?
      params[:c] = %w(comments issue project hours)
      params[:c] = TimeEntryCustomField.pluck(:id).map {|i| "cf_#{i}" } + params[:c]
    end
    @query = TimeEntryQuery.build_from_params(params, :name => '_')
    scope = TimeEntry.visible.where(@query.statement)
    @entries = scope.includes(:project, :activity, :user, {:issue => :tracker}, {:custom_values => :custom_field})
    @entries = @entries.order("spent_on DESC, users.firstname, users.lastname, users.id")
  end

  def find_project_and_issue
    if params[:time_entry]
      if (project_id = params[:time_entry][:project_id]).present?
        @project = Project.find(project_id)
      end
      if (issue_id = params[:time_entry][:issue_id]).present?
        @issue = Issue.find(issue_id)
        @project ||= @issue.project
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_time_entry
    @time_entry = TimeEntry.find(params[:id])
    unless @time_entry.editable_by?(User.current)
      render_403
      return false
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def authorize_creation
    if User.current.allowed_to?({:controller => "timelog", :action => "new"}, @project, :global => false)
      true
    else
      render_403
    end
  end
end
