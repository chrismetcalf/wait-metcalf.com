require 'rubygems'
require 'toto'
require 'rack-rewrite'
require 'cgi'

use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
use Rack::Static, :urls => ['/albums', '/blog/wp-content', '/uploads', '/files'], :root => 'public/_archive'
use Rack::CommonLogger

# Rack config
use Rack::Rewrite do
  # We want the homepage to be our welcome page, and the blog to be /blog
  rewrite '/', '/home'
  rewrite %r{/blog/?$}, '/index'

  # Feed URLs
  rewrite '/atom.xml', 'index.xml'
  #r302 '/feed/', 'http://feeds.feedburner.com/chrismetcalf'
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
      "These are not the droids you are looking for... (404)"
    when 500
      "I would much rather have gone with Master Luke than stay here with you. I don't know what all this trouble is about, but I'm sure it must be your fault. (500)"
    else
      "Hokey religions and ancient weapons are no match for a good blaster at your side, kid."
    end
  }
end

run toto