require 'test_helper'

class ResourceFilteringTest < ActionDispatch::IntegrationTest
  fixtures :posts, :comments, :categories
 
  test "It can filter on a string" do
    get "/api/categories?name=News"
    assert_equal 200, status

    data = JSON.parse response.body
    assert_equal data.length, 1 
  end
  
  test "It can filter on a string with multiple values" do
    get "/api/categories?name=News*Random"
    assert_equal 200, status

    data = JSON.parse response.body
    assert_equal data.length, 2 
  end
  
  test "It can filter on a bool" do
    get "/api/posts?published=true"
    assert_equal 200, status

    data = JSON.parse response.body
    assert_equal data.length, 1 
  end
end
