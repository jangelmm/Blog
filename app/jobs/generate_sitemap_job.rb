class GenerateSitemapJob < ApplicationJob
  queue_as :default

  def perform
    SitemapGenerator::Interpreter.run
    SitemapGenerator::Sitemap.ping_search_engines
  end
end
