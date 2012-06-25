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

    grouped = data['elements'].group_by { |e| e['type'] }

    puts "nodes     : #{grouped['node'].count}"
    puts "ways      : #{grouped['way'].count}"
    puts "relations : #{grouped['relation'].count}"

    puts "--- Top 20 tags ---"

    data['elements'].flat_map  { |e| e['tags'].map {|k,v| {key: "#{k}=#{v}"} } if e['tags']}
                    .compact
                    .group_by  { |tag| tag[:key] }
                    .reject    { |key, tags| key =~ /^tiger|gnis/ }
                    .sort_by   { |key, tags| tags.count }
                    .last(20)
                    .reverse
                    .each      { |key, tags| puts "#{key} : #{tags.count}" }

  end
end

OsmStats.start


