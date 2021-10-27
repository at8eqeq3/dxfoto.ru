module Jekyll
  # creates file with a key of latest image
  class PostIndex < Generator
    safe true
    priority :low
    def generate(site)
      today = File.new("#{__dir__}/../today", 'w')
      today.puts site.posts.docs[-1].data['date'].strftime('/l/%Y/%m/%Y-%m-%d.jpg')
    end
  end
end
