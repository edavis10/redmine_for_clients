class AutoCompletesController < ApplicationController
  before_filter :find_project, :only => :issues

  helper :custom_fields
  
  def issues
    @issues = []
    q = params[:q].to_s
    if q.match(/^\d+$/)
      @issues << @project.issues.visible.find_by_id(q.to_i)
    end
    unless q.blank?
      @issues += @project.issues.visible.find(:all, :conditions => ["LOWER(#{Issue.table_name}.subject) LIKE ?", "%#{q.downcase}%"], :limit => 10)
    end
    render :layout => false
  end

  def users
    if params[:remove_group_members].present?
      @group = Group.find(params[:remove_group_members])
      @removed_users = @group.users
    end

    if params[:remove_watchers].present? && params[:klass].present?
      watcher_class = params[:klass].constantize
      if watcher_class.included_modules.include?(Redmine::Acts::Watchable) # check class is a watching class
        @object = watcher_class.find(params[:remove_watchers])
        @removed_users = @object.watcher_users
      end
    end

    @removed_users ||= []
    
    @users = User.active.like(params[:q]).find(:all, :limit => 100) - @removed_users
    render :layout => false
  end
  
  private

  def find_project
    project_id = (params[:issue] && params[:issue][:project_id]) || params[:project_id]
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
