module Jekyll
  # Liquid tag to build an URL to image by post date
  class ImgSrcTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
      _, date = @text.split(' ', 2)
      puts date.to_s unless date.strip == ''
      @tokens = tokens
    end

    def render(context)
      s, d = @text.split(' ', 2)
      page_date = nil
      if d =~ /\d{4}-\d{2}-\d{2}/
        page_date = date
      elsif context.registers.key? :page
        page_date = context.registers[:page]['date']
      end
      return if page_date.nil?

      if %w[l m s].include? s
        "https://img.dxfoto.ru/#{s}/#{page_date.strftime('%Y/%m/%Y-%m-%d')}.webp"
      else
        "https://hd.dxfoto.ru/#{page_date.strftime('%Y/%m/%Y-%m-%d')}.jpg"
      end
    end
  end
end

Liquid::Template.register_tag('img_src', Jekyll::ImgSrcTag)
