require 'pg'

class DbConnection
  def initialize
    @categories = Hash.new
    @accounts = Hash.new
  end

  def open_connection (db_name, username, password)
    @connection = PG.connect(
      :dbname => db_name,
      :user => username,
      :password => password
    )
  end

  def close_connection
    @connection.close
    clear_hashes
  end

  def prepare_statements
    @connection.prepare('select_transaction', 'select count(*) from transactions where date = $1 and ' +
      'amount = $2 and original_description = $3 and transaction_type = $4')
    @connection.prepare('insert_transaction', 'insert into transactions (date, description, amount, ' +
      'category_id, original_description, transaction_type, account_id, created_at, updated_at) ' +
      'values ($1, $2, $3, $4, $5, $6, $7, now(), now())')
    @connection.prepare('select_category', 'select id, name from categories where lower(name) like lower($1)')
    @connection.prepare('insert_category', 'insert into categories (name, parent_id, is_master_category, ' +
      'created_at, updated_at) values ($1, null, false, now(), now()) RETURNING ID;')
    @connection.prepare('select_account', 'select id, name from accounts where lower(name) like lower($1)')
    @connection.prepare('insert_account', 'insert into accounts (name, created_at, updated_at) ' +
      'values ($1, now(), now()) RETURNING ID;')

  end

  def num_matching_transactions(date, amount, original_description, type)
    result = @connection.exec_prepared('select_transaction',
      [ 
        date,
        amount,
        original_description,
        translate_type(type)
      ]
    )
    return result.getvalue(0,0).to_i
  end

  def transaction_record_exists?(date, amount, original_description, type)
    return num_matching_transactions(date, amount, original_description, type) > 0
  end

  def get_category_id(category_name)
    return get_hashed_id(category_name, @categories, 'select_category', 'insert_category')
  end

  def get_account_id(account_name)
    return get_hashed_id(account_name, @accounts, 'select_account', 'insert_account')
  end

  def add_transaction(date, amount, category_id, description, original_description, type, account_id)
    result = @connection.exec_prepared('insert_transaction', 
      [
        date,
        description,
        amount,
        category_id,
        original_description,
        translate_type(type),
        account_id
      ]
    )
  end

  private 
    def translate_type(type)
      return (type == 'credit') ? 1 : 0
    end

    def clear_hashes
      @categories.clear
      @accounts.clear
    end

    def get_hashed_id(key, hash, select_statement, insert_statement)
      k = key.downcase
      
      unless hash.has_key?(k)
        result = @connection.exec_prepared(select_statement, [key])
        
        if result.cmd_tuples > 0
          hash[k] = result.getvalue(0, 0).to_i
        else
          result = @connection.exec_prepared(insert_statement, [key])
          hash[k] = result.getvalue(0, 0).to_i 
        end
      end

      return hash[k]
    end
end
