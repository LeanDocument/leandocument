libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)
require 'open-uri'
require "sinatra/base"
require 'sinatra/partial'
require "leandocument/version"
require "leandocument/server"
require "leandocument/document"
require "leandocument/blob_image"
require "leandocument/repository"
require "leandocument/render"
require "leandocument/render/markdown"
require "leandocument/render/re_structured_text"
require "rdiscount"
require 'rbst'
require "yaml"
require 'grit'
require 'digest/md5'
require 'erb'
