#!/usr/bin/env ruby

require 'date'
require 'exifr/jpeg'
require 'miro'
require 'tty-prompt'
require 'xmp'
require 'yaml'

# trying to suppress warnings
module NoWarnings
  def warn(message, category: nil, **kwargs)
    # do nothing
  end
end
Warning.extend NoWarnings

prompt = TTY::Prompt.new
Miro.options[:color_count] = 4

# checking for executables. We need nano, git and s3cmd
%w[nano git s3cmd].each do |exe|
  unless system('which', exe, %i[out err] => File::NULL)
    puts 'Не найдена необходимая команда: ' + exe + '. Дальше не пойдём.'
    exit 1
  end
end

PHOTO_ROOT = ENV.key?('DXFOTO_PHOTO_ROOT') ? ENV['DXFOTO_PHOTO_ROOT'] : prompt.ask('Не установлена переменная окружения DXFOTO_PHOTO_ROOT. Где искать фотки?')
SITE_ROOT = ENV.key?('DXFOTO_SITE_ROOT') ? ENV['DXFOTO_SITE_ROOT'] : prompt.ask('Не установлена переменная окружения DXFOTO_SITE_ROOT. Где исходники сайта?', default: Dir.pwd)

curdate = Time.now

# fill with actual values
exif_gear = {
  camera: {
    'Canon EOS 70D' => '70D'
  },
  lens: {
    'EF-S55-250mm f/4-5.6 IS STM' => '55-250mm'
  }
}

gear = {
  camera: [
    '70D',
    'E-3',
    'E-300'
  ],
  lens: [
    '14-45mm',
    '40-150mm',
    '35mm macro',
    '55-250mm',
    '40mm',
    'Зенитар',
    'Индустар 50-2',
    'Гелиос 44-2',
    'Таир-3',
    'Индустар 61'
  ],
  extra: [
    'EX-25',
    '31mm ext',
    '21mm ext',
    '13mm ext'
  ]
}

post_meta = {}
post_meta['layout'] = 'post'

post_meta['date'] = (prompt.ask('За какой день пост?', default: curdate.strftime('%Y-%m-%d'), convert: :date).to_time + 3*60*60).getgm

photo_file = File.join(PHOTO_ROOT, post_meta['date'].strftime('%Y/%m/%Y-%m-%d.jpg'))

if File.file? photo_file
  ### get dominant colors
  colors = Miro::DominantColors.new(photo_file)
  post_meta['colors'] = [colors.to_hex[0][1..7], colors.to_hex[1][1..7].to_s]

  ### read exif
  e = EXIFR::JPEG.new(photo_file)
  guess_date = e.date_time_original.to_date
  post_meta['shoot_date'] = prompt.ask('Уточним дату съёмки:', default: guess_date.strftime('%Y-%m-%d'), convert: :date)
  guess_camera = exif_gear[:camera].key?(e.model) ? exif_gear[:camera][e.model] : nil
  guess_lens = exif_gear[:lens].key?(e.lens_model) ? exif_gear[:lens][e.lens_model] : nil

  xmp = XMP.parse e
  taxonomy = []
  begin
    hts = xmp.lr.hierarchicalSubject
    hts.each do |ht|
      taxonomy << ht.split('|', 2)[1] if ht.start_with? 'taxonomy'
    end
  rescue NoMethodError
    # do nothing
  end
  post_meta['taxonomy'] = []
  unless taxonomy.empty?
    taxonomy.each do |t|
      if prompt.yes?('Найдена таксономическая запись: ' + t + '. Добавить')
        post_meta['taxonomy'] << t
      end
    end
  end
  post_meta['taxonomy'] << prompt.ask('Добавить таксономическую запись вручную?')
  post_meta['taxonomy'].reject! { |t| t.to_s.strip == '' }
  post_meta.delete 'taxonomy' if post_meta['taxonomy'].empty?

  ### ask for additional data
  post_meta['title'] = prompt.ask('Как будет называться?')
  post_meta['author'] = prompt.select('Кто снимал?', %w[Д.Г. К.С.])
  post_meta['location'] = prompt.ask('Где снято?')
  post_meta['tags'] = prompt.ask('Жёппки надо написать:', convert: :list)
  post_meta['gear'] = []
  post_meta['gear'] << prompt.select('Какая камера?', gear[:camera], default: guess_camera)
  post_meta['gear'] << prompt.select('Какой объектив?', gear[:lens], default: guess_lens)
  post_meta['gear'] << prompt.multi_select('Дополнительный обвес?', gear[:extra])
  post_meta['gear'].flatten!

  ### upload
  if prompt.yes?('Загрузжаем файл в ObjectStorage?')
    system "s3cmd put #{photo_file} s3://hd.dxfoto.ru/#{post_meta['date'].strftime('%Y/%m/%Y-%m-%d.jpg')}"
  end

  ### create post
  Dir.chdir(SITE_ROOT)
  current_branch = `git branch --show-current`.strip
  if current_branch == 'deploy-aerobatic'
    if prompt.yes?('Создадим пост?')
      post_file_path = File.join(SITE_ROOT, post_meta['date'].strftime('_posts/%Y/%m/%Y-%m-%d-post.md'))
      post_file = File.new(post_file_path, 'w')
      post_file.puts YAML.dump(post_meta)
      post_file.puts "---\n"
      post_file.close
      prompt.keypress('После нажатия Enter откроется редактор', keys: [:return])
      system "nano #{post_file_path}"
      system 'git add .'
      system 'git commit -m "Post for ' + post_meta['date'].strftime('%Y-%m-%d') + '"'
      system 'git push origin deploy-aerobatic' if prompt.yes?('Пушим в гит?')
    end
  else
    puts 'Текущая ветка кода (' + current_branch + ') отличается от целевой (deploy-aerobatic).'
    puts 'Необходимо завершить работу с текущей веткой, переключиться на целевую и создать пост вручную'
    puts 'Вот front-matter для него:'
    puts YAML.dump(post_meta)
  end
else
  puts 'Нужно сначала экспортировать файл за ' + post_meta['date'].strftime('%Y-%m-%d')
  exit 1
end
