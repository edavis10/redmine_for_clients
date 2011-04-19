require File.dirname(__FILE__) + '/../test_helper'

class AutoCompletesControllerTest < ActionController::TestCase
  fixtures :all

  def test_issues_should_not_be_case_sensitive
    get :issues, :project_id => 'ecookbook', :q => 'ReCiPe'
    assert_response :success
    assert_not_nil assigns(:issues)
    assert assigns(:issues).detect {|issue| issue.subject.match /recipe/}
  end
  
  def test_issues_should_return_issue_with_given_id
    get :issues, :project_id => 'subproject1', :q => '13'
    assert_response :success
    assert_not_nil assigns(:issues)
    assert assigns(:issues).include?(Issue.find(13))
  end

  context "GET :users" do
    setup do
      @login = User.generate!(:login => 'Acomplete')
      @firstname = User.generate!(:firstname => 'Complete')
      @lastname = User.generate!(:lastname => 'Complete')
      @none = User.generate!(:login => 'hello', :firstname => 'ABC', :lastname => 'DEF')
      @inactive = User.generate!(:firstname => 'Complete', :status => User::STATUS_LOCKED)
    end

    context "with no restrictions" do
      setup do
        get :users, :q => 'complete'
      end
      
      should_respond_with :success
      
      should "render a list of matching users in checkboxes" do
        assert_select "input[type=checkbox][value=?]", @login.id
        assert_select "input[type=checkbox][value=?]", @firstname.id
        assert_select "input[type=checkbox][value=?]", @lastname.id
        assert_select "input[type=checkbox][value=?]", @none.id, :count => 0
      end
      
      should "only show active users" do
        assert_select "input[type=checkbox][value=?]", @inactive.id, :count => 0
      end
    end

    context "including groups" do
      setup do
        @group = Group.generate(:lastname => 'Complete Group').reload
        get :users, :q => 'complete', :include_groups => true
      end
      
      should_respond_with :success
      
      should "include matching groups" do
        assert_select "input[type=checkbox][value=?]", @group.id
      end

    end

    context "restrict by removing group members" do
      setup do
        @group = Group.first
        @group.users << @login
        @group.users << @firstname
        get :users, :q => 'complete', :remove_group_members => @group.id
      end
      
      should_respond_with :success
      
      should "not include existing members of the Group" do
        assert_select "input[type=checkbox][value=?]", @lastname.id

        assert_select "input[type=checkbox][value=?]", @login.id, :count => 0
        assert_select "input[type=checkbox][value=?]", @firstname.id, :count => 0
      end
    end
    
    context "restrict by removing issue watchers" do
      setup do
        @issue = Issue.find(2)
        @issue.add_watcher(@login)
        @issue.add_watcher(@firstname)
        get :users, :q => 'complete', :remove_watchers => @issue.id, :klass => 'Issue'
      end
      
      should_respond_with :success
      
      should "not include existing watchers" do
        assert_select "input[type=checkbox][value=?]", @lastname.id

        assert_select "input[type=checkbox][value=?]", @login.id, :count => 0
        assert_select "input[type=checkbox][value=?]", @firstname.id, :count => 0
      end
    end
  end
end
