module Jekyll
  # calculates images sizes for respectful links
  # tag accepts "f", "l", "m" or "s" as an argument
  class ImageSizeTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text.strip
    end

    def render(context)
      return unless context.registers.key? :page
      page_date = context.registers[:page]['date']
      y = page_date.strftime('%Y')
      m = page_date.strftime('%m')
      d = page_date.strftime('%Y-%m-%d')
      exif = {}
      begin
        if context.environments[0]['site']['data']['exif'][y][m].key?(d)
          exif = context.environments[0]['site']['data']['exif'][y][m][d]
        end
      rescue NoMethodError
        exif = {}
      end
      if exif.key?('ImageWidth') && exif.key?('ImageHeight')
        case @text
        when 'f'
          return exif['ImageWidth'].to_s + ' ⨉ ' + exif['ImageHeight'].to_s
        when 'l'
          height = exif['ImageHeight'].to_f * 2048 / exif['ImageWidth'].to_f
          return '2048 ⨉ ' + height.to_i.to_s
        when 'm'
          height = exif['ImageHeight'].to_f * 1024 / exif['ImageWidth'].to_f
          return '1024 ⨉ ' + height.to_i.to_s
        when 's'
          return '512 ⨉ 512'
        end
      else
        case @text
        when 'f'
          return '? ⨉ ?'
        when 'l'
          return '2048 ⨉ ?'
        when 'm'
          return '1024 ⨉ ?'
        when 's'
          return '512 ⨉ 512'
        end
      end
    end
  end
end

Liquid::Template.register_tag('image_size', Jekyll::ImageSizeTag)
