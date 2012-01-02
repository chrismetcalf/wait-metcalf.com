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

  # Shorcuts
  r302 %r{^/the-(lucky-)?couple/?}, '/2012/01/02/the-lucky-couple/'
end

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

#
# Create and configure a toto instance
#
toto = Toto::Server.new do
  set :date,        lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
  #set :root,        "home"
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
end

run toto
