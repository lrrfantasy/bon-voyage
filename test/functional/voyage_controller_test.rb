require 'test_helper'

class VoyageControllerTest < ActionController::TestCase
  test "should get response" do
    get :response
    assert_response :success
  end

end
