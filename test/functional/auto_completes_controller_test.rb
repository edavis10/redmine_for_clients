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
      
      get :users, :q => 'complete', :id => Group.first.id
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
  
end
