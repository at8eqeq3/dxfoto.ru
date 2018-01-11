module Jekyll
  class ImgSrcTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
      size, date = @text.split(' ', 2)
      puts date.to_s unless date.strip == ''
      @tokens = tokens
    end
    def render(context)
      size, date = @text.split(' ', 2)
      page_date = nil
      if date.to_s.match(/\d{4}-\d{2}-\d{2}/)
        page_date = date
      else
        page_date = context.registers[:page]['date'] if context.registers.key? :page\
      end
      return if page_date.nil?

      url_part = page_date.strftime('%Y/%m/%Y-%m-%d')
      ### XXX temporary check, remove when images migration is complete
      # thres is a date of first photo in S3
      thres = Time.new(2016, 1, 31)
      if page_date >= thres
        case size
        when 'l'
          "https://img.dxfoto.ru/l/#{url_part}.jpg"
        when 'm'
          "https://img.dxfoto.ru/m/#{url_part}.jpg"
        when 's'
          "https://img.dxfoto.ru/s/#{url_part}.jpg"
        else
          "https://hd.dxfoto.ru/#{url_part}.jpg"
        end
      else
        case size
        when 'l'
          "https://res.cloudinary.com/dxfoto-ru/t_large/#{url_part}.jpg"
        when 'm'
          "https://res.cloudinary.com/dxfoto-ru/t_medium/#{url_part}.jpg"
        when 's'
          "https://res.cloudinary.com/dxfoto-ru/t_small/#{url_part}.jpg"
        else
          "https://res.cloudinary.com/dxfoto-ru/#{url_part}.jpg"
        end
      end
    end
  end
end

Liquid::Template.register_tag('img_src', Jekyll::ImgSrcTag)
