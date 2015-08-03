module APPI
  module ServesAppsFromRedis
    extend ActiveSupport::Concern

    def serve_index 
      app_name = params[:app_name] || 'app'
      revision = params[:revision]
    
      if needs_trailing_slash? 
        redirect_to url_for(params.merge(trailing_slash: true)), status: 301 and return
      end

      index_key = if revision
                    "#{app_name}:#{revision}"
                  else
                    Sidekiq.redis { |r| r.get("#{app_name}:current") }
                  end
      index = Sidekiq.redis { |r| r.get(index_key) } || "Index file not found."
      render text: index.html_safe, layout: false
    end

    private

    def needs_trailing_slash?
      if params[:path]
        false
      else
        request.env['REQUEST_URI'].match(/[^\?]+/).to_s.last != '/' && params[:trailing_slash_at_root]
      end
    end
  end
end
