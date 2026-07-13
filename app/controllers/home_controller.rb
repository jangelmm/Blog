class HomeController < ApplicationController
  def index
    @profile         = Profile.first_or_create!(name: "Tu nombre")
    @recent_posts    = Post.published.recent.limit(3)
    @featured_projects = Project.ordered.limit(3)
  end
end
