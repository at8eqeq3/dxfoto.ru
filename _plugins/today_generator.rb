module Jekyll
  # creates file with a key of latest image
  class TodayIndex < Generator
    safe true
    priority :low
    def generate(site)
      today = File.new("#{__dir__}/../today.json", 'w')
      date = site.posts.docs[-1].data['date'].strftime('%Y/%m/%Y-%m-%d')
      data = <<-TODAY
{
  "ErrorDocument": {
    "Key": "index.html"
  },
  "IndexDocument": {
    "Suffix": "error.html"
  },
  "RoutingRules": [
    {
      "Condition": {
        "KeyPrefixEquals": "today.jpg"
      },
      "Redirect": {
        "HostName": "img.dxfoto.ru",
        "HttpRedirectCode": "301",
        "Protocol": https",
        "ReplaceKeyWith": "l/#{date}.jpg"
      }
    }
  ]
}
      TODAY
      today.puts data
    end
  end
end
