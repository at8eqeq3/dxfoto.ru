module Jekyll
  # creates file with a key of latest image
  class TodayIndex < Generator
    safe true
    priority :low
    def generate(site)
      today = File.new("#{__dir__}/../today.json", 'w')
      date = site.posts.docs[-1].data['date'].strftime('%Y/%m/%Y-%m-%d')
      data = <<-TODAY
<WebsiteConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <IndexDocument>
    <Suffix>index.html</Suffix>
  </IndexDocument>
  <ErrorDocument>
    <Key>error.html</Key>
  </ErrorDocument>
  <RoutingRules>
    <RoutingRule>
      <Condition>
        <KeyPrefixEquals>today.jpg</KeyPrefixEquals>
      </Condition>
      <Redirect>
        <ReplaceKeyPrefixWith>l/#{date}.jpg</ReplaceKeyPrefixWith>
      </Redirect>
    </RoutingRule>
  </RoutingRules>
</WebsiteConfiguration>
      TODAY
      today.puts data
    end
  end
end
