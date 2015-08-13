require 'test_helper'

class ResourceActionsTest < ActionDispatch::IntegrationTest
  fixtures :posts
  
  # INDEX ACTION
  test "GET /api/posts endpoint is public and operational" do
    get "/api/posts"
    assert_equal 200, status
  end
  
  test "GET /api/posts endpoint works with slugs" do
    get "/api/posts?slug=#{Post.first.slug}"
    assert_equal 200, status
  end
  
  # SHOW ACTION
  test "GET /api/posts/:id endpoint is public and operational" do
    get "/api/posts/#{Post.first.id}"
    assert_equal 200, status
  end
  
  test "GET /api/posts/:id endpoint works with slugs" do
    get "/api/posts/#{Post.first.slug}"
    assert_equal 200, status
  end
  
  # CREATE ACTION
  test "POST /api/posts endpoint is public and operational" do
    payload = {
      data: {
        attributes: {
          title: "Second Post",
          body: "hi hello"
        } 
      } 
    }

    post "/api/posts", payload
    assert_equal 200, status
  end
  
  # UPDATE ACTION
  test "PATCH /api/posts/:id endpoint is public and operational" do
    payload = {
      data: {
        attributes: {
          title: "Second Post",
          body: "hi hello"
        } 
      } 
    }

    patch "/api/posts/#{Post.first.id}", payload
    assert_equal 200, status
  end
  
  # DESTROY ACTION
  test "DELETE /api/posts/:id endpoint is public and operational" do
    delete "/api/posts/#{Post.first.id}"
    assert_equal 204, status
  end
end
