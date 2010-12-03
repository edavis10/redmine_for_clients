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
    @group = Group.find(params[:id])
    @users = User.active.like(params[:q]).find(:all, :limit => 100) - @group.users
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
