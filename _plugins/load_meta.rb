#require 'aws-sdk'
#require 'fileutils'
#Jekyll::Hooks.register :site, :after_reset do |site|
#  unless Dir.entries(site.config['source'] + '/_data/').include? 'tags'
#    Aws.config.update region: 'eu-west-1',
#                      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
#    s3 = Aws::S3::Client.new
#    resp = s3.list_objects(bucket: 'meta-dxfoto-ru')
#    resp.contents.each do |m|
#      next unless (m.key.start_with?('tags') || m.key.start_with?('exif') || m.key.start_with?('colors')) && m.key.end_with?('.json')
#      d = site.config['source'] + '/_data/' + m.key.split('/')[0..-2].join('/')
#      FileUtils.mkdir_p d
#      s3.get_object response_target: site.config['source'] + '/_data/' + m.key,
#                    bucket: 'meta-dxfoto-ru',
#                    key: m.key
#    end
#  end
#end
