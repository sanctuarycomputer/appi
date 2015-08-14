require 'test_helper'

class ResourceErrorHandlingTest < ActionDispatch::IntegrationTest
  fixtures :posts
  
  # SHOW ACTION
  test "GET /api/posts/:id endpoint handles Active Record errors" do
    get "/api/posts/9999"
    assert_equal 500, status

    data = JSON.parse response.body
    assert data.has_key? "errors"

    assert_equal data["errors"][0]["title"], "ActiveRecord::RecordNotFound"
    assert_equal data["errors"][0]["detail"], "Couldn't find Post with 'id'=9999"
  end
  
  # CREATE ACTION
  test "POST /api/posts handles validation errors" do
    payload = {
      data: {
        attributes: {
          body: "hi hello"
        } 
      } 
    }

    post "/api/posts", payload
    assert_equal 422, status

    data = JSON.parse response.body
    assert data.has_key? "errors"

    assert_equal data["errors"][0]["title"], "Resources: Could Not Save"

    assert_equal data["errors"][1]["title"], "can't be blank"
    assert_equal data["errors"][1]["source"]["pointer"], "data/attributes/title"
  end
  
  # UPDATE ACTION
  test "PATCH /api/posts/:id handles validation errors" do
    payload = {
      data: {
        attributes: {
          title: "",
          body: "hi hello"
        } 
      } 
    }

    patch "/api/posts/#{Post.first.id}", payload
    assert_equal 422, status

    data = JSON.parse response.body
    assert data.has_key? "errors"

    assert_equal data["errors"][0]["title"], "Resources: Could Not Save"

    assert_equal data["errors"][1]["title"], "can't be blank"
    assert_equal data["errors"][1]["source"]["pointer"], "data/attributes/title"
  end
  
  test "PATCH /api/posts/:id endpoint handles Active Record errors" do
    payload = {
      data: {
        attributes: {
          title: "Second Post",
          body: "hi hello"
        } 
      } 
    }

    patch "/api/posts/9999", payload
    assert_equal 500, status

    data = JSON.parse response.body
    assert data.has_key? "errors"

    assert_equal data["errors"][0]["title"], "ActiveRecord::RecordNotFound"
    assert_equal data["errors"][0]["detail"], "Couldn't find Post with 'id'=9999"
  end

  # DESTROY ACTION
  test "DELETE /api/posts/1 endpointihandles Active Record errors" do
    delete "/api/posts/9999"
    
    assert_equal 500, status

    data = JSON.parse response.body
    assert data.has_key? "errors"

    assert_equal data["errors"][0]["title"], "ActiveRecord::RecordNotFound"
    assert_equal data["errors"][0]["detail"], "Couldn't find Post with 'id'=9999"
  end
end
