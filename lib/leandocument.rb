libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require "sinatra/base"
require "leandocument/version"
require "leandocument/server"
require "leandocument/document"
require "rdiscount"
require "yaml"
require 'erb'

Leandocument::Server.start
