#!/usr/bin/env ruby

require 'rubygems'
require 'thor'
require 'open-uri'
require 'net/http'
require 'json'
require 'nokogiri'
require 'curses'
include Curses


module StackOverflow
    class API
        def search(search_string)
            search_string = URI::encode(search_string)
            api_get("/2.0/similar?order=desc&sort=votes&title=#{search_string}&site=stackoverflow&filter=default")
        end

        def get_answers(question_id)
            api_get("/2.0/questions/#{question_id}/answers?order=desc&sort=votes&site=stackoverflow&filter=!9Tk6JYC_e")
        end

        private

        def api_get(path)
            url = "https://api.stackexchange.com" + path
            u = URI.parse(url)
            Net::HTTP.start(u.host, u.port, :use_ssl => true) do |http|
                response = http.get(u.request_uri)
                return JSON(response.body)['items']
            end
        end
    end

    class Formatter
        def answers_viewer(answers)
            Curses.noecho # do not show typed keys
            Curses.init_screen
            Curses.cbreak

            Curses.stdscr.keypad(true) # enable arrow keys (required for pageup/down)
            Curses.start_color

            # Define colors
            #Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK) 
            #Curses.init_pair(COLOR_RED,COLOR_RED,COLOR_BLACK)
            
            win = Curses::Window.new(0, Curses.cols - 8*2, 0, 8)
            win.scrollok(true)
            #win.addstr(answers2text(answers))
            win.addstr(answers)

            loop do
                #Curses.refresh

                case win.getch

                when Curses::Key::UP
                    win.addstr("Text")
                    #win.scrl(-1)
            #        Curses.clear
            #        Curses.setpos(0,0)
            #        # Use colors defined color_init
            #        Curses.attron(color_pair(COLOR_RED)|A_NORMAL){
            #            Curses.addstr("Page Up")
            #        }
                when Curses::Key::DOWN
                    win.scrl(1)
            #        Curses.clear
            #        Curses.setpos(0,0)
            #        Curses.attron(color_pair(COLOR_BLUE)|A_NORMAL){
            #            Curses.addstr("Page Down")
            #        }
                end
            end
        end

        def answers2text(answers)
            nb = 1
            result = ""
            answers.each do |answer|
                text = html2text(answer['body'])
                result << "[#{nb}] #{text}\n\n" + "=" * 20 + "\n\n"
                nb += 1
            end
        end

        def html2text(html)
            doc = Nokogiri::HTML(html)
            doc.css('body').text.squeeze(" ").squeeze("\n").gsub(/[\n]+/, "\n\n")
        end
    end

    class Command < Thor
        desc "search <question>", "Search Stack Overflow for a question"

        def search(search_string, question_nb=nil)
            if !question_nb
                questions = API.new.search(search_string)
                questions.each do |question|
                    puts "[#{question['question_id']}] #{question['title']}"
                end
            else
                #answers = API.new.get_answers(question_nb)
                file = File.open("sample.txt", "r")
                answers = file.read
                Formatter.new.answers_viewer(answers)
            end
        end
    end
end


