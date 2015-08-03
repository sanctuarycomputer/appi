# APPI

A minimal toolkit for building modern, stateless APIs, perfect for single page 
applications.  Built with Ember CLI in mind, but framework agnostic.  Use as much or
as little as you need.

First Class Support for:
- JSONAPI
- JSON Web Tokens
- Token Based Authentication
- Error Handling
- Frontend Hosting via Redis

Coming Soon:
- Slugs (Limited support for Friendly ID)
- Tokenable Resources (currently limited to User)
- Variable User Class
- Pagination (Via Kaminari)

## Installation

Add APPI to your Gemfile:

```rb
gem 'appi', github: 'sanctuarycomputer/appi'
```

then run a `bundle` and you're golden!

## Getting Started

Let's start with the essentials:

### Error Handling

The first thing you'll want to do is setup some APPI style exception handling
in your application.  This is a snap!

In your `application_controller.rb`:

```rb
module YourAPI
  class ApplicationController < ActionController::Base
    include APPI::RendersExceptions
  
    rescue_from APPI::Exception do |exception|
      render_appi_exception exception 
    end

  end
end
```

Now, whenever you need to show the user an error, you can do something like this:

```rb
module YourAPI
  class PostsController < ApplicationController
  
    def update
      unless params[:can_update]
        raise APPI::Exception.new("posts.will_not_update", id: @post.id)
      end
      ...
    end

  end
end
```

Then in your Rails i18n locale:

```rb
# config/locales/en.yml

en:
  appi_exceptions:
    posts:
      will_not_update: 
        title: 'Posts: Could Not Save'
        detail: 'Could not update a post with ID: %{id}.
        status: 'unprocessable_entity'

```

You can handle External & Rails exceptions with APPI too:

```rb
class ApplicationController < ActionController::Base
  include APPI::RendersExceptions

  rescue_from Exception do |exception|
    case exception
    when APPI::Exception
      render_appi_exception exception 

    when CanCan::AccessDenied
      details = {
        action: exception.action.to_s
      }

      if exception.subject.respond_to? :id
        details[:subject_id]         = exception.subject.id.to_s
        details[:subject_class_name] = exception.subject.class.to_s 
      else
        details[:subject_id]         = nil
        details[:subject_class_name] = exception.subject.to_s
      end

      render_appi_exception APPI::Exception.new('permissions.access_denied', details)

    else
      render_appi_exception APPI::Exception.new('rails.untracked_error', message: exception.message)
    end
  end
end
```

### Resource Controllers

APPI comes with some nice tools for DRY'ing up your Resource Controllers.

#### JSON API Requests

If you need to handle requests formatted for the JSON API spec, the Rails Strong Params method
isn't really going to cut the butter for you.  Instead, use APPI!

```rb
module YourAPI
  class PostsController < ApplicationController
    APPI::HandlesResources  
    
    protected

    def permitted_attributes
      [:name, :blurb]
    end

    def permitted_relationships
      [:comments]
    end
  end
end
```

#### Resource Filtering

It's a common pattern to filter a resource on its `index` action.  APPI has drop-in support for
this too:

```rb
module YourAPI
  class PostsController < ApplicationController
    APPI::HandlesResources  
    APPI::FiltersResources
    
    protected

    def permitted_attributes
      [:name, :blurb]
    end

    def permitted_relationships
      [:comments]
    end

    def permitted_filter_params
      [:status]
    end

  end
end
```

Now when you issue a `GET` request to the `posts` endpoint, you can also append `?status=publised`
to return a collection of published posts.

### Users & Current User

APPI supports token (JWT) based User Authentication, like so:

```rb
module YourAPI
  class ApplicationController < ActionController::Base
    include APPI::RendersExceptions
    include APPI::CurrentUser
  end
end
```

Now in your Users Controller:

```rb
module YourAPI
  class UsersController < BaseController
    include APPI::UserTokenController 
  end
end
```

And in your `routes.rb`:

```
Rails.application.routes.draw do

  resources :users do
    post 'token', on: :collection
  end

end
```

Now a user can request a token by issuing a `POST` request to the `users/token` endpoint, with an 
`email` and `password`.  With the token, and the `@current_user` variable with be loaded whenever
the request headers include a valid token in the following format:

```
Authorization: bearer 1234usertokenhere56789
```

You can also encode and decode things at will with the `APPI::TokenUtil` singleton class.

### Serving Single Page Applications from Redis

The Ember CLI Deploy approach to Single Page Application deployment usually
involves uploading compiled assets to a data store like S3, and then serving
an `index.html` file that references those assets from your API in some way.

APPI supports this idea through Redis:

```rb
module YourAPI
  class ApplicationController < ActionController::Base
    include APPI::ServesAppsFromRedis
  end
end
```

Then in your `routes.rb` file:

```rb
Rails.application.routes.draw do
  get '/(*path)', to: "application#serve_index", defaults: { app_name: "frontend" }
end
```

Now when a user requests `http://yourappserver.com/about-us`, APPI will look for a Redis
key called `frontend:current`, and serve its content as HTML Safe text.

If you're serving the app somewhere other than root, you'll want to force a trailing
forward slash too:

```rb
Rails.application.routes.draw do
  get 'admin/(*path)', to: "application#serve_index", defaults: { 
    app_name: "admin",
    trailing_slash_at_root: true
  }
end
```

If you're serving multiple apps, be sure to get the order right!

```rb
Rails.application.routes.draw do
  get 'admin/(*path)', to: "application#serve_index", defaults: { 
    app_name: "admin",
    trailing_slash_at_root: true
  }
  
  get '/(*path)', to: "application#serve_index", defaults: { app_name: "frontend" }
end
```

