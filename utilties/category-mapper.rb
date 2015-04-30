require 'getoptlong'
require 'json'
require './db-connection.rb'

=begin
  input config file
  open database connection
  open json file
    iterate through category tree
    assign parentIds as appropriate
  close file
  close connection
=end

def assign_parent_id(db_connection, category_json, parent_id) 
  category_id = db_connection.get_category_id(category_json['value'])
  db_connection.update_parent_category(category_id, parent_id)
  unless category_json['children'].nil?
    category_json['children'].each do |child|
      assign_parent_id(db_connection, child, category_id)
    end
  end
end

options = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

config_filepath = nil
categories_filepath = nil
db_connection_info = nil
all_arguments_specified = false

options.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
category-mapper.rb -c filepath

--config filepath, -c filepath
  File path of the configuration file used as input for this script
  
  The file should contain JSON in the format
    {
      db: {
        // connection information for the database where the transactions should go
        dbname: <database_name>
        user: <username>
        password: <password>
      },
      // File containing category JSON from Mint website
      input_file: <filepath>
    }
    EOF
    
    exit 0
    when '--config'
      config_filepath = arg
  end
end

if config_filepath.nil? 
  puts 'Missing config filepath. Try the --help option for more details.'
elsif not File.exist?(config_filepath)
  puts 'Config file does not exist. Cannot map data without it!'
else
  all_arguments_specified = true
end

if not all_arguments_specified
  exit 0
end

File.open(config_filepath) do |input_file|
  config = JSON.parse(input_file.readlines.join)
  db_connection_info = config['db']
  categories_filepath = config['input_file']
end

if not File.exists?(categories_filepath)
  printf("JSON input file '%s' does not exist.\n", categories_filepath)
  exit 0
end

connection = DbConnection.new
connection.open_connection(db_connection_info['dbname'], db_connection_info['user'], db_connection_info['password'])
connection.prepare_statements
begin
  categories = {}
  File.open(categories_filepath) { |f| categories = JSON.parse(f.readlines.join) }
  categories.each do |master|
    assign_parent_id(connection, master, nil)
  end
ensure
  connection.close_connection
end
