require 'middleman-core/cli'
require 'yaml'

# Provides a "chapter" command for adding chapters to data
class Chapter < Thor
  check_unknown_options!

  namespace :chapter

  CHAPTERS = File.join('source', 'chapters.yml')

  def self.source_root
    ENV['MM_ROOT']
  end

  def self.exit_on_failure?
    true
  end

  desc 'chapter NAME', 'Create a chapter listing in chapters.yml'
  method_option 'title',
                aliases: '-t',
                desc: 'The title of the chapter'

  method_option 'description',
                aliases: '-d',
                desc: 'The description of the chapter (for meta tags)'

  method_option 'url',
                aliases: '-u',
                desc: 'The URL for the chapter'

  def chapter(name)
    fail "No name provided!" if name.nil?

    @name = name
    @title = options[:title] || name.capitalize
    @desc = options[:description] || "The #{@title} chapter of Papers We Love"
    @url = options[:url] || "http://paperswelove.org"

    if chapter?.nil?
      add_chapter
    else
      fail "#{@name} already exists in #{CHAPTERS}!"
    end
  end

  protected

  def chapter?
    @chapters = YAML.load_file(CHAPTERS)
    @chapters.detect { |chapter| chapter.has_value?(@name) }
  end

  def add_chapter
    @chapters << { name: @name,
                   title: @title,
                   description: @desc,
                   url: @url }
    File.open(CHAPTERS, 'w+') { |f| f.write(@chapters.to_yaml) }
  end

end
