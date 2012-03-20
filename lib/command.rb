#!/usr/bin/env ruby

require "rubygems"
require "thor"

module StackOverflow
    class Command < Thor
        desc "search <question>", "Search Stack Overflow for a question"
        def search(search_string)
            puts search_string
        end
    end
end


