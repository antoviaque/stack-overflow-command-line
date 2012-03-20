#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'open-uri'
require 'net/http'
require 'json'


module StackOverflow
    class API
        def search(search_string)
            search_string = URI::encode(search_string)
            api_path = "/2.0/similar?order=desc&sort=votes&title=#{search_string}&site=stackoverflow&filter=default"
            api_get(api_path)
        end

        private

        def api_get(path)
            url = "https://api.stackexchange.com" + path
            u = URI.parse(url)
            Net::HTTP.start(u.host, u.port, :use_ssl => true) do |http|
                response = http.get(u.request_uri)
                return JSON(response.body)
            end
        end
    end

    class Command < Thor
        desc "search <question>", "Search Stack Overflow for a question"


        def search(search_string)
            response = API.new.search(search_string)
            response['items'].each do |item|
                puts item['title']
            end
        end
    end
end


