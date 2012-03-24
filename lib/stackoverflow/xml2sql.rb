#!/usr/bin/env ruby

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

