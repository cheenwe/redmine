# Redmine - project management software
# Copyright (C) 2006-2015  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class TimelogController < ApplicationController
  menu_item :issues

  before_filter :find_time_entry, :only => [:show, :edit, :update]
  before_filter :find_time_entries, :only => [:bulk_edit, :bulk_update, :destroy]
  before_filter :authorize, :only => [:show, :edit, :update, :bulk_edit, :bulk_update, :destroy]

  before_filter :find_optional_project, :only => [:new, :create, :index, :report]
  before_filter :authorize_global, :only => [:new, :create, :index, :report]

  accept_rss_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :sort
  include SortHelper
  helper :issues
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper

  def index
    @query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')

    sort_init(@query.sort_criteria.empty? ? [['spent_on', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    scope = time_entry_scope(:order => sort_clause).
      includes(:project, :user, :issue).
      preload(:issue => [:project, :tracker, :status, :assigned_to, :priority])

    respond_to do |format|
      format.html {
        @entry_count = scope.count
        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a
        @total_hours = scope.sum(:hours).to_f

        render :layout => !request.xhr?
      }
      format.api  {
        @entry_count = scope.count
        @offset, @limit = api_offset_and_limit
        @entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
      }
      format.atom {
        entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
        render_feed(entries, :title => l(:label_spent_time))
      }
      format.csv {
        # Export all entries
        @entries = scope.to_a
        send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog.csv')
      }
    end
  end

  def report
    @query = TimeEntryQuery.build_from_params(params, :project => @project, :name => '_')
    scope = time_entry_scope

    @report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.csv  { send_data(report_to_csv(@report), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
    end
  end

  def all
    solve_status_id = IssueStatus.get_status_id "已解决"
    abort_status_id = IssueStatus.get_status_id "已放弃"
    close_status_id = IssueStatus.get_status_id "已关闭"
    ongoing_status_id = IssueStatus.get_status_id "进行中"


    @users = User.where(status:1)
    @all_records = []
    #大于 , 小于
    if params[:time_more_than].present?  || params[:time_less_than].present?
      if params[:time_more_than].present? && params[:time_less_than].present?
        start_at = Date.parse(params[:time_more_than]).beginning_of_day
        end_at = Date.parse(params[:time_less_than]).end_of_day
      elsif params[:time_more_than].present?
        start_at = Date.parse(params[:time_more_than]).beginning_of_day
        end_at = Time.now
      elsif  params[:time_less_than].present?
        start_at = Issue.first.created_on
        end_at = Date.parse(params[:time_less_than]).end_of_day
      else
      end



      @users.each do |user|

      issues =  Issue.where(assigned_to: user.id).where(created_on:start_at..end_at)



      issues_solve = issues.where(status_id:solve_status_id)
      issues_abort = issues.where(status_id:abort_status_id)
      issues_close = issues.where(status_id:close_status_id)
      issues_ongoing = issues.where(status_id:ongoing_status_id)

      issues_plan_hours = issues.sum(:estimated_hours)
      issues_solve_plan_hours = issues_solve.sum(:estimated_hours)
      issues_abort_plan_hours = issues_abort.sum(:estimated_hours)
      issues_close_plan_hours = issues_close.sum(:estimated_hours)
      issues_ongoing_plan_hours = issues_ongoing.sum(:estimated_hours)

      time_entries =TimeEntry.where(user_id: user.id).where(created_on:start_at..end_at)

        @all_records << {
          user_id: user.id,
          user: user.name,
          plan_hours:  issues_plan_hours ,
          issues_size: issues.size,
          issues_solve_size: issues_solve.size,
          issues_abort_size: issues_abort.size,
          issues_close_size: issues_close.size,
          issues_ongoing_size: issues_ongoing.size,
          issues_solve_plan_hours: issues_solve_plan_hours,
          issues_abort_plan_hours: issues_abort_plan_hours,
          issues_close_plan_hours: issues_close_plan_hours,
          issues_ongoing_plan_hours: issues_ongoing_plan_hours,
          issues_solve_percent: (issues_solve.size*100/issues.size rescue 0.0),
          issues_close_percent: (issues_close.size*100/issues.size rescue 0.0),
          hours: time_entries.sum(:hours)
          # : TimeEntry.where("user_id: #{user.id }AND created_at >= #{params[:q]}").sum(:hours)
        }
      end

    else


      @users.each do |user|
      issues =  Issue.where(assigned_to: user.id)
      issues_ongoing = issues.where(status_id:ongoing_status_id)


      issues_solve = issues.where(status_id:solve_status_id)
      issues_abort = issues.where(status_id:abort_status_id)
      issues_close = issues.where(status_id:close_status_id)

      issues_ongoing_plan_hours = issues_ongoing.sum(:estimated_hours)
      issues_plan_hours = issues.sum(:estimated_hours)
      issues_solve_plan_hours = issues_solve.sum(:estimated_hours)
      issues_abort_plan_hours = issues_abort.sum(:estimated_hours)
      issues_close_plan_hours = issues_close.sum(:estimated_hours)

      time_entries =TimeEntry.where(user_id: user.id)

        @all_records << {
          user_id: user.id,
          user: user.name,
          plan_hours:  issues_plan_hours ,
          issues_size: issues.size,
          issues_solve_size: issues_solve.size,
          issues_abort_size: issues_abort.size,
          issues_close_size: issues_close.size,
          issues_ongoing_size: issues_ongoing.size,

          issues_solve_plan_hours: issues_solve_plan_hours,
          issues_abort_plan_hours: issues_abort_plan_hours,
          issues_ongoing_plan_hours: issues_ongoing_plan_hours,
          issues_close_plan_hours: issues_close_plan_hours,
          issues_ongoing_percent: (issues_ongoing.size*100/issues.size rescue 0.0),
          issues_solve_percent: (issues_solve.size*100/issues.size rescue 0.0),
          issues_close_percent: (issues_close.size*100/issues.size rescue 0.0),
          hours: time_entries.sum(:hours)
          # : TimeEntry.where("user_id: #{user.id }AND created_at >= #{params[:q]}").sum(:hours)
        }
      end
    end

  end

  def show
    respond_to do |format|
      # TODO: Implement html response
      format.html { render :nothing => true, :status => 406 }
      format.api
    end
  end

  def new
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @time_entry.safe_attributes = params[:time_entry]
  end

  def create
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @time_entry.safe_attributes = params[:time_entry]
    if @time_entry.project && !User.current.allowed_to?(:log_time, @time_entry.project)
      render_403
      return
    end

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_create)
          if params[:continue]
            options = {
              :time_entry => {
                :project_id => params[:time_entry][:project_id],
                :issue_id => @time_entry.issue_id,
                :activity_id => @time_entry.activity_id
              },
              :back_url => params[:back_url]
            }
            if params[:project_id] && @time_entry.project
              redirect_to new_project_time_entry_path(@time_entry.project, options)
            elsif params[:issue_id] && @time_entry.issue
              redirect_to new_issue_time_entry_path(@time_entry.issue, options)
            else
              redirect_to new_time_entry_path(options)
            end
          else
            redirect_back_or_default project_time_entries_path(@time_entry.project)
          end
        }
        format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end

  def edit
    @time_entry.safe_attributes = params[:time_entry]
  end

  def update
    @time_entry.safe_attributes = params[:time_entry]

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default project_time_entries_path(@time_entry.project)
        }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end

  def bulk_edit
    @available_activities = TimeEntryActivity.shared.active
    @custom_fields = TimeEntry.first.available_custom_fields
  end

  def bulk_update
    attributes = parse_params_for_bulk_time_entry_attributes(params)

    unsaved_time_entry_ids = []
    @time_entries.each do |time_entry|
      time_entry.reload
      time_entry.safe_attributes = attributes
      call_hook(:controller_time_entries_bulk_edit_before_save, { :params => params, :time_entry => time_entry })
      unless time_entry.save
        logger.info "time entry could not be updated: #{time_entry.errors.full_messages}" if logger && logger.info?
        # Keep unsaved time_entry ids to display them in flash error
        unsaved_time_entry_ids << time_entry.id
      end
    end
    set_flash_from_bulk_time_entry_save(@time_entries, unsaved_time_entry_ids)
    redirect_back_or_default project_time_entries_path(@projects.first)
  end

  def destroy
    destroyed = TimeEntry.transaction do
      @time_entries.each do |t|
        unless t.destroy && t.destroyed?
          raise ActiveRecord::Rollback
        end
      end
    end

    respond_to do |format|
      format.html {
        if destroyed
          flash[:notice] = l(:notice_successful_delete)
        else
          flash[:error] = l(:notice_unable_delete_time_entry)
        end
        redirect_back_or_default project_time_entries_path(@projects.first)
      }
      format.api  {
        if destroyed
          render_api_ok
        else
          render_validation_errors(@time_entries)
        end
      }
    end
  end

private
  def find_time_entry
    @time_entry = TimeEntry.find(params[:id])
    unless @time_entry.editable_by?(User.current)
      render_403
      return false
    end
    @project = @time_entry.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_time_entries
    @time_entries = TimeEntry.where(:id => params[:id] || params[:ids]).to_a
    raise ActiveRecord::RecordNotFound if @time_entries.empty?
    raise Unauthorized unless @time_entries.all? {|t| t.editable_by?(User.current)}
    @projects = @time_entries.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def set_flash_from_bulk_time_entry_save(time_entries, unsaved_time_entry_ids)
    if unsaved_time_entry_ids.empty?
      flash[:notice] = l(:notice_successful_update) unless time_entries.empty?
    else
      flash[:error] = l(:notice_failed_to_save_time_entries,
                        :count => unsaved_time_entry_ids.size,
                        :total => time_entries.size,
                        :ids => '#' + unsaved_time_entry_ids.join(', #'))
    end
  end

  def find_optional_project
    if params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
    elsif params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Returns the TimeEntry scope for index and report actions
  def time_entry_scope(options={})
    scope = @query.results_scope(options)
    if @issue
      scope = scope.on_issue(@issue)
    end
    scope
  end

  def parse_params_for_bulk_time_entry_attributes(params)
    attributes = (params[:time_entry] || {}).reject {|k,v| v.blank?}
    attributes.keys.each {|k| attributes[k] = '' if attributes[k] == 'none'}
    attributes[:custom_field_values].reject! {|k,v| v.blank?} if attributes[:custom_field_values]
    attributes
  end
end
