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

require 'xml'
require 'sqlite3'

#db = SQLite3::Database.new("stackoverflow.db")
db_idx = SQLite3::Database.new("stackoverflow_idx.db")

#db.execute("
#    CREATE TABLE posts ( 
#      id INTEGER PRIMARY KEY, 
#      post_type_id INTEGER, 
#      parent_id INTEGER, 
#      accepted_answer_id INTEGER, 
#      score INTEGER, 
#      body TEXT, 
#      title VARCHAR(255)
#    ); 
#    CREATE INDEX post_type_id_idx ON posts(post_type_id);
#    CREATE INDEX parent_id_idx ON posts(parent_id);
#    CREATE INDEX title_idx ON posts(title); ")
#*/
db_idx.execute("
    CREATE TABLE questions ( 
      id INTEGER PRIMARY KEY, 
      title VARCHAR(255)
    ); 
    CREATE INDEX title_idx ON questions(title); ")
db_idx.execute("
    CREATE TABLE answers ( 
      id INTEGER PRIMARY KEY, 
      parent_id INTEGER
    ); 
    CREATE INDEX parent_id_idx ON answers(parent_id);")

reader = XML::Reader.file "posts.xml"
#ins = db.prepare('INSERT INTO posts VALUES (?, ?, ?, ?, ?, ?, ?)')
ins_question = db_idx.prepare('INSERT INTO questions VALUES (?, ?)')
ins_answer = db_idx.prepare('INSERT INTO answers VALUES (?, ?)')

while reader.read
    if reader.node_type == XML::Reader::TYPE_ELEMENT && reader.name == 'row'
        post = {}
        while reader.move_to_next_attribute == 1
            post[reader.name] = reader.value
        end
        #ins.execute(post['Id'], 
        #            post['PostTypeId'], 
        #            post['ParentID'],
        #            post['AcceptedAnswerId'], 
        #            post['Score'], 
        #            post['Body'], 
        #            post['Title'])
        
        if post['PostTypeId'] == '1'
            ins_question.execute(post['Id'], 
                                 post['Title'])
        else if post['PostTypeId'] == '2'
            ins_answer.execute(post['Id'], 
                               post['ParentID'])
        end end
    end
end

#reader.move_to_first_attribute

