# Jekyll Module to create monthly archive pages
#
# Shigeya Suzuki, November 2013
# Copyright notice (MIT License) attached at the end of this file
#

#
# This code is based on the following works:
#   https://gist.github.com/ilkka/707909
#   https://gist.github.com/ilkka/707020
#   https://gist.github.com/nlindley/6409459
#

#
# Archive will be written as #{archive_path}/#{year}/#{month}/index.html
# archive_path can be configured in 'path' key in 'monthly_archive' of
# site configuration file. 'path' is default null.
#

module Jekyll
  module MonthlyArchiveUtil
    def self.archive_base(site)
      site.config['monthly_archive'] && site.config['monthly_archive']['path'] || ''
    end
  end

  # Generator class invoked from Jekyll
  class MonthlyArchiveGenerator < Generator
    def generate(site)
      posts_group_by_year_and_month(site).each do |ym, list|
        site.pages << MonthlyArchivePage.new(site, MonthlyArchiveUtil.archive_base(site),
                                             ym[0], ym[1], list)
      end
    end

    def posts_group_by_year_and_month(site)
      site.posts.docs.each.group_by { |post| [post.date.year, post.date.month] }
    end
  end

  # Actual page instances
  class MonthlyArchivePage < Page
    ATTRIBUTES_FOR_LIQUID = %w(
      year,
      month,
      date,
      content
    )

    def initialize(site, dir, year, month, posts)
      @site = site
      @dir = dir
      @year = year
      @month = month.to_s.rjust(2, '0')
      @archive_dir_name = '%04d/%02d' % [year, month]
      @date = Time.new(@year, @month.to_i)
      @layout =  site.config['monthly_archive'] && site.config['monthly_archive']['layout'] || 'monthly_archive'
      self.ext = '.html'
      self.basename = 'index'
      if ENV['AMP'] == 'yes'
        self.content = <<-EOS
  {% for post in page.posts %}
    <a href="{{ post.url }}" title="{{post.date | date: "%Y-%m-%d" }} • {{ post.title }}">
      <amp-img src="https://img.dxfoto.ru/s/{{post.date | date: "%Y"}}/{{post.date | date: "%m"}}/{{post.date | date: "%Y-%m-%d"}}.webp" alt="{{ post.title }}" width="512" height="512" layout="responsive"></amp-img>
    </a>
  {% endfor %}
        EOS
      else
        self.content = <<-EOS
  {% for post in page.posts %}
    <div class="pure-u-12-24 pure-u-sm-8-24 pure-u-md-6-24 index-item">
      <a href="{{ post.url }}" title="{{post.date | date: "%Y-%m-%d" }} • {{ post.title }}">
        <picture class="pure-img">
          <source srcset="https://img.dxfoto.ru/s/{{post.date | date: "%Y"}}/{{post.date | date: "%m"}}/{{post.date | date: "%Y-%m-%d"}}.webp" type="image/webp">
          <source srcset="https://img.dxfoto.ru/s/{{post.date | date: "%Y"}}/{{post.date | date: "%m"}}/{{post.date | date: "%Y-%m-%d"}}.jpg" type="image/jpeg">
          <img src="https://img.dxfoto.ru/s/{{post.date | date: "%Y"}}/{{post.date | date: "%m"}}/{{post.date | date: "%Y-%m-%d"}}.jpg" alt="{{ post.title }}" class="pure-img" />
        </picture>
      </a>
    </div>
  {% endfor %}
        EOS
      end
      self.data = {
        'layout' => @layout,
        'og' => { 'exclude' => 'yes' },
        'type' => 'archive',
        'title' => "Архив за #{@year}.#{@month}",
        'posts' => posts,
        'url' => File.join('/',
                           MonthlyArchiveUtil.archive_base(site),
                           @archive_dir_name, 'index.html')
      }
    end

    def render(layouts, site_payload)
      payload = {
        'page' => self.to_liquid,
        'paginator' => pager.to_liquid
      }.merge(site_payload)
      do_layout(payload, layouts)
    end

    def to_liquid(attr = nil)
      data.merge(
        'content' => content,
        'date' => @date,
        'month' => @month,
        'year' => @year
      )
    end

    def destination(dest)
      File.join('/', dest, @dir, @archive_dir_name, 'index.html')
    end
  end
end

# The MIT License (MIT)
#
# Copyright (c) 2013 Shigeya Suzuki
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
