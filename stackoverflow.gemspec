Gem::Specification.new do |s|
  s.name        = 'stackoverflow'
  s.version     = '0.1.4'
  s.date        = '2012-03-26'
  s.summary     = "Query StackOverflow from the command line (offline/online modes)"
  s.description = "Allows to query Stack Overflow's questions & answers from the command line. It can either be used in 'online' mode, where the StackOverflow API is queried, or offline, by downloading the latest dump released by StackOverflow."
  s.authors     = ["Xavier Antoviaque"]
  s.email       = 'xavier@antoviaque.org'
  s.files       = ["lib/stackoverflow.rb"]
  s.homepage    = 'https://github.com/antoviaque/stack-overflow-command-line'
  
  s.executables << 'so'
  
  s.add_dependency('json', '>= 1.6.5')
  s.add_dependency('libxml-ruby', '>= 2.3.2')
  s.add_dependency('nokogiri', '>= 1.5.2')
  s.add_dependency('sqlite3', '>= 1.3.5')
  s.add_dependency('terminal-table', '>= 1.4.5')
end
