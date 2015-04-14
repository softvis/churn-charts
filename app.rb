#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'date'
require './lib/helper.rb'

helpers Helper

get '/' do
  erb :index
end

get '/timeline' do
  erb :timeline
end

get '/histogram' do
  erb :histogram
end

get '/data/timeline.json' do
  content_type :json
  flatten_entries(aggregate_churn(read_log())).to_json
end

get '/data/histogram.json' do
  content_type :json
  aggregate_by_file(read_log()).to_json
end
