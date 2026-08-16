class PreviewsController < ApplicationController
  skip_before_action :verify_authenticity_token

  include ApplicationHelper

  def render_preview
    dummy_post = Post.new(path: params[:path].to_s)

    render html: markdown(params[:text].to_s, dummy_post)
  end
end
