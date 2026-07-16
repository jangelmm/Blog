SitemapGenerator::Sitemap.default_host = "https://jangelab.com"

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: "daily"
  add about_path, priority: 0.7, changefreq: "monthly"

  Project.find_each do |project|
    add project_path(project.slug), lastmod: project.updated_at, priority: 0.8
  end

  Post.published.find_each do |post|
    add post_show_path(path: post.path, slug: post.slug), lastmod: post.updated_at, priority: 0.9
  end
end
