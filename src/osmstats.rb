#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'json'
require 'cgi'

class OsmStats < Thor
  desc "get", "get stats"
  method_option :user, :aliases => "-u", :desc => "OSM user name"
  def get
    api_url = "http://overpass.osm.rambler.ru/cgi/interpreter"

    params = CGI.escape(
      [
        "[out:json];",
        "(",
        "      node (user:'#{options[:user]}');",
        "       way (user:'#{options[:user]}');",
        "  relation (user:'#{options[:user]}');",
        ");",
        "out;"
      ].join('')
    )

    data = JSON.parse(`curl -s "#{api_url}?data=#{params}"`)

    nodes     = data['elements'].select {|e| e['type'] == 'node'}
    ways      = data['elements'].select {|e| e['type'] == 'way'}
    relations = data['elements'].select {|e| e['type'] == 'relation'}

    breakdown = {}

    data['elements'].each do |e|
      e['tags'].each do |t|
        key = "#{t[0].downcase}=#{t[1].downcase}"
        breakdown[key] = (breakdown[key] || 0) + 1
      end if e['tags']
    end

    puts "nodes     : #{nodes.count}"
    puts "ways      : #{ways.count}"
    puts "relations : #{relations.count}"

    puts "--- Top 20 tags ---"

    breakdown.delete_if {|k,v| k.match /^tiger/ }
             .sort_by {|k,v| v }
             .last(20)
             .reverse
             .each {|k,v| puts "#{k} : #{v}" }

  end
end

OsmStats.start


