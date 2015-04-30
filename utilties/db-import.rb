require 'getoptlong'
require 'json'
require 'csv'
require './db-connection.rb'
require './dedupper.rb'

=begin
  input config file
  open database connection
  open transaction file
    foreach row in file
      if exists, skip
      else create enter in db
  close connection
=end

options = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

config_filepath = nil
transactions_filepath = nil
db_connection_info = nil
all_arguments_specified = false

options.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
db-import.rb -c filepath

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
      // at minimum, the input file needs to contain the following columns:
      //    Date, Description, Original Description, Amount, Transaction Type, Category, Account Name
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
  puts 'Config file does not exist. Cannot generate data without it!'
else
  all_arguments_specified = true
end

if not all_arguments_specified
  exit 0
end

File.open(config_filepath) do |input_file|
  config = JSON.parse(input_file.readlines.join)
  db_connection_info = config['db']
  transactions_filepath = config['input_file']
end

if not File.exists?(transactions_filepath)
  printf("Transaction input file '%s' does not exist.\n", transactions_filepath)
  exit 0
end

connection = DbConnection.new
connection.open_connection(db_connection_info['dbname'], db_connection_info['user'], db_connection_info['password'])
connection.prepare_statements
total_added = 0
dedup = Dedupper.new
begin
  CSV.foreach(transactions_filepath, {:headers=>true}) do |row|
    date = row['Date']
    category = row['Category']
    amount = row['Amount'].to_f.round(2)
    description = row['Description']
    original_description = row['Original Description']
    type = row['Transaction Type']
    account_name = row['Account Name']

    printf("%s, %.2f, %s, %s, %s, %s, %s", date, amount, category, description, original_description, type, account_name)
    
    if account_name.include?('(dup)')
      print "...dup - skipped\n"
      next
    end

    num_records = connection.num_matching_transactions(date, amount, original_description, type)
    key = sprintf("%s-%.2f-%s-%s", date, amount, original_description, type)    
    dedup.add_key(key, num_records) unless dedup.has_key?(key)
    dedup.increment_seen(key)
    
    if dedup.should_add_record?(key)
      category_id = connection.get_category_id(category)
      account_id = connection.get_account_id(account_name)
      connection.add_transaction(date, amount, category_id, description, original_description, type, account_id)
      dedup.increment_record_count(key)
      total_added += 1
      print "...added\n"
    else 
      print "...skipped\n"
    end
  end 
ensure
  connection.close_connection
end

printf("%d records added\n", total_added)
