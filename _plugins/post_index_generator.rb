# from http://stackoverflow.com/questions/26073090/how-to-retrieve-the-current-post-index-number-in-jekyll
module Jekyll
  # Adds serial number to each post
  class PostIndex < Generator
    safe true
    priority :low
    def generate(site)
      site.posts.docs.each_with_index do |item, index|
        item.data['index'] = index + 1
      end
    end
  end
end
