#!/usr/bin/env ruby

require 'sinatra'
require 'json'
require 'date'
require './lib/helper.rb'

helpers Helper

get '/' do
  erb :index
end

get '/chart/:name' do
  erb :chart, :locals => {:name => params[:name]}
end

get '/data/timeline.json' do
  content_type :json
  flatten_entries(churn_by_file_by_day()).to_json
end

get '/data/histogram.json' do
  content_type :json
  churn_by_file().to_json
end

get '/data/matrix.json' do
  content_type :json
  read_log2().to_json
end
