require 'test_helper'

class RelationshipsDataTest < ActionDispatch::IntegrationTest
  fixtures :posts, :comments
  
  test "POST /api/comments endpoint allows belongs_to relationships" do
    payload = {
      data: {
        attributes: {
          body: "Good good post @dril" 
        },
        relationships: {
          post: {
            data: {
              type: "posts",
              id: "1"
            }
          } 
        }
      } 
    }

    post "/api/comments", payload
    assert_equal 200, status

    data = JSON.parse response.body

    assert_equal data["post_id"], 1
    assert_equal data["body"], "Good good post @dril"
  end
  
  test "POST /api/posts endpoint allows has_many relationships" do
    payload = {
      data: {
        attributes: {
          title: "Another Cracker from @dril",
          body: "i have taken my shirt off over 10000 times" 
        },
        relationships: {
          comments: {
            data: [
              { type: "comments", id: 1 },
              { type: "comments", id: 2 }
            ]
          }
        }
      } 
    }

    post "/api/posts", payload
    assert_equal 200, status

    data = JSON.parse response.body
    assert_equal Post.find(data["id"]).comments.length, 2
  end
end
