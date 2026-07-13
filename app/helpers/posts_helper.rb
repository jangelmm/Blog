# app/helpers/posts_helper.rb
module PostsHelper
  def build_tree(posts, prefix)
    root = {}
    posts.each do |post|
      rest = post.path.to_s.sub(/^#{Regexp.escape(prefix)}\/?/, "").split("/")
      node = root
      rest.each { |seg| node = (node[seg] ||= {}) }
      (node[:_posts] ||= []) << post
    end
    root
  end
end
