#!/usr/bin/env ruby
#
# Copyright (C) 2012 Xavier Antoviaque <xavier@antoviaque.org>
#
# This software's license gives you freedom; you can copy, convey,
# propagate, redistribute and/or modify this program under the terms of
# the GNU Affero General Public License (AGPL) as published by the Free
# Software Foundation (FSF), either version 3 of the License, or (at your
# option) any later version of the AGPL published by the FSF.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program in a file in the toplevel directory called
# "AGPLv3".  If not, see <http://www.gnu.org/licenses/>.
#

require 'rubygems'
require 'open-uri'
require 'net/http'
require 'json'
require 'nokogiri'
require 'terminal-table/import'
require 'sqlite3'
require 'optparse'

module StackOverflow
    class API
        def search(search_string)
            search_string = URI::encode(search_string)
            api_get("/2.0/similar?order=desc&sort=votes&title=#{search_string}&site=stackoverflow&filter=!9Tk5iz1Gf")
        end

        def get_question(question_id)
            api_get("/2.0/questions/#{question_id}?order=desc&sort=activity&site=stackoverflow&filter=!9Tk5izFWA")
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

    class DB
        def initialize
            @db     = SQLite3::Database.new(File.join(Dir.home, ".stackoverflow/stackoverflow.db"))
            @db_idx = SQLite3::Database.new(File.join(Dir.home, ".stackoverflow/stackoverflow_idx.db"))
        end

        def search(search_string)
            # Search on titles in the small index DB, to get the ids faster
            sql = "SELECT id FROM questions WHERE "
            sub_sql = []
            for search_term in search_string.split(' ')
                sub_sql << "title LIKE '%#{search_term}%'"
            end
            sql += sub_sql.join(' AND ')

            questions_ids = []
            @db_idx.execute(sql) do |row|
                questions_ids << row[0]
            end

            # Then retreive details from the main (large) DB
            sql = "SELECT id, score, body, title FROM posts WHERE "
            sub_sql = []
            for question_id in questions_ids
                sub_sql << "id=#{question_id}"
            end
            sql += sub_sql.join(' OR ')
            sql += ' ORDER BY score DESC'

            questions = []
            @db.execute(sql) do |row|
                questions << { :id => row[0],
                               :score => row[1],
                               :body => row[2],
                               :title => row[3],
                               :link => '',
                               :answers => get_answers(row[0]) }
            end
        end

        def get_answers(question_id)
            # Search on parent ids in the small index DB, to get the ids faster
            sql = "SELECT id FROM answers WHERE parent_id=#{question_id}"
            answers_ids = []
            @db_idx.execute(sql) do |row|
                answers_ids << row[0]
            end

            # Then retreive details from the main (large) DB
            sql = "SELECT id, score, body FROM posts WHERE "
            sub_sql = []
            for answer_id in answers_ids
                sub_sql << "id=#{answer_id}"
            end
            sql += sub_sql.join(' OR ')
            sql += ' ORDER BY score DESC'

            answers = []
            @db.execute(sql) do |row|
                answers << { :id => row[0],
                             :score => row[1],
                             :body => row[2] }
            end
        end
    end

    class DBUpdater
        def initialize
            @dir_path = File.join(Dir.home, ".stackoverflow")
            @db_version_path = File.join(@dir_path, "db_version")

            @remote_hostname = "dl.dropbox.com"
            @remote_path = "/u/31130894/"
        end

        def check_local_dir
            Dir.mkdir(@dir_path) if not directory_exists?(@dir_path)
        end

        def get_db_version
            db_version = 0
            if file_exists?(@db_version_path)
                File.open(@db_version_path, 'r') { |f| db_version = f.read().to_i }
            end
            db_version
        end

        def set_db_version(version_nb)
            File.open(@db_version_path, 'w+') { |f| f.write(version_nb.to_s) }
        end

        def get_remote_db_version
            remote_db_version = 0
            Net::HTTP.start(@remote_hostname) do |http|
                resp = http.get(File.join(@remote_path, "db_version"))
                resp.body.to_i
            end
        end

        def update
            check_local_dir
            remote_db_version = get_remote_db_version
            db_version = get_db_version
            if db_version < remote_db_version
                puts "Database update found!"
                puts "Updating from version #{db_version} to version #{remote_db_version} (several GB to download - this can take a while)..."
                download_all
                set_db_version(remote_db_version)
            end
            puts "The database is up to date (version #{get_db_version})."
        end

        def download_all
            download_file "stackoverflow_idx.db.gz"
            gunzip_file   "stackoverflow_idx.db.gz"
            download_file "stackoverflow.db.gz"
            gunzip_file   "stackoverflow.db.gz"
        end

        def download_file(filename)
            puts "Downloading #{filename}..."
            Net::HTTP.start(@remote_hostname) do |http|
                f = open(File.join(@dir_path, filename), "wb")
                begin
                    http.request_get(File.join(@remote_path, filename)) do |resp|
                        resp.read_body do |segment|
                            f.write(segment)
                        end
                    end
                ensure
                    f.close()
                end
            end
        end

        def gunzip_file(filename)
            puts "Unpacking #{filename}..."
            gz_file_path = File.join(@dir_path, filename)
            z = Zlib::Inflate.new(16+Zlib::MAX_WBITS)

            File.open(gz_file_path) do |f|
                File.open(gz_file_path[0...-3], "w") do |w|
                    f.each do |str|
                        w << z.inflate(str)
                    end
                end
            end
            z.finish
            z.close
            File.delete(gz_file_path)
        end

        def directory_exists?(path)
          return false if not File.exist?(path) or not File.directory?(path)
          true
        end

        def file_exists?(path)
          return false if not File.exist?(path) or not File.file?(path)
          true
        end

    end

    class Formatter
        def questions_list(questions)
            nb = 1

            table = Terminal::Table.new do |t|
                questions.each do |question|
                    score = question['score'] > 0 ? "+#{question['score']}" : question['score']
                    t << ["[#{nb}]", "(#{score})", question['title']]
                    nb += 1
                end
                t.style = {:padding_left => 2, :border_x => " ", :border_i => " ", :border_y => " "}
            end
            puts table
        end

        def question_viewer(question)
            answers = question['answers']
            nb = 1
            
            table = Terminal::Table.new do |t|
                t << ["Question", html2text(question['body'])]
                t.title = question['title'] + "\n\n" + question['link']
                t << :separator
                t << :separator

                answers.each do |answer|
                    text = html2text(answer['body'])
                    t << ["[#{nb}] (+#{answer['score']})", "#{text}"]
                    t << :separator
                    nb += 1
                end
            end

            IO.popen("less", "w") { |f| f.puts table }
        end

        def html2text(html)
            doc = Nokogiri::HTML(html)
            doc = doc.css('body').text.squeeze(" ").squeeze("\n").gsub(/[\n]+/, "\n\n")
            wordwrap(doc)
        end

        def wordwrap(str, columns=80)
            str.gsub(/\t/, "    ").gsub(/.{1,#{ columns }}(?:\s|\Z)/) do
                ($& + 5.chr).gsub(/\n\005/, "\n").gsub(/\005/, "\n")
            end
        end
    end

    class Command
        def run
            options = {}
            OptionParser.new do |opts|
                opts.banner = "** Usage: so [options] <search string> [<question_id>]"
                opts.on("-h", "--help", "Help") do |v|
                    help
                    exit
                end
                opts.on("-u", "--update", "Update local database") do |v|
                    DBUpdater.new.update
                    exit
                end
                opts.on("-o", "--offline", "Offline mode") do |v|
                    options['offline'] = true
                end
            end.parse!

            if ARGV.length < 1
                help
                exit
            end

            # last argument is integer when user is specifing a question_nb from the results
            question_nb = nil
            if ARGV[-1] =~ /^[0-9]+$/
                question_nb = ARGV.pop.to_i
            end

            search_string = ARGV.join(' ')
            search(search_string, question_nb, options)
        end

        def help
            puts "** Usage: so [options] <search string> [<question_id>]"
            puts "          so --update\n\n"
            puts "Arguments:"
            puts "\t<search_string> : Search Stack Overflow for a combination of words"
            puts "\t<question_id>   : (Optional) Display the question with this #id from the search results\n\n"
            puts "Options:"
            puts "\t-o --offline    : Query the local database instead of the online StackOverflow API (offline mode)"
            puts "\t-u --update     : Download or update the local database of StackOverflow answers (7GB+)\n\n"
        end

        def search(search_string, question_nb, options)
            if options['offline']
                api = DB.new
            else
                api = API.new
            end
            
            questions = api.search(search_string)
            if !questions or questions.length == 0
                puts "No record found - Try a less specific (or sometimes, more specific) query"
                return
            end

            if !question_nb
                Formatter.new.questions_list(questions)
            else
                question = questions[question_nb.to_i - 1]
                Formatter.new.question_viewer(question)
            end
        end
    end
end

