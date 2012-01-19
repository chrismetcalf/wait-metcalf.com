require 'rubygems'
require 'toto'
require 'rack-rewrite'
require 'cgi'

use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
use Rack::Static, :urls => ['/albums', '/blog/wp-content', '/uploads', '/files'], :root => 'public/_archive'
use Rack::CommonLogger

# Rack config
use Rack::Rewrite do
  # Feed URLs
  rewrite '/atom.xml', 'index.xml'
  r302 '/feed/', 'http://feeds.feedburner.com/wait-metcalf'
end

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

#
# Create and configure a toto instance
#
toto = Toto::Server.new do
  set :date,        lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
  set :markdown,    :smart
  set :summary,     :max => 150, :delim => /~/
  set :title,       Dir.pwd.split('/').last
  set :author,      "Chris Metcalf"
  set :ext,         "txt"
  set :prefix,      ""

  set :error, lambda { |code|
    case code
    when 404
      "Excuse me sir, but I think you've gotten lost... (404)"
    when 500
      "You've ruined it!!! (500)"
    else
      "Well I just don't know what to tell you here..."
    end
  }

  # Magic to allow me to use Markdown for static pages
  set :to_html, lambda {|path, page, ctx|
    if File.exists? "#{path}/#{page}.txt"
      Markdown.new(File.read("#{path}/#{page}.txt").strip).to_html
    else
      ERB.new(File.read("#{path}/#{page}.rhtml")).result(ctx)
    end
  }
end

run toto
