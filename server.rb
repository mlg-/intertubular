require 'sinatra'
require 'pg'
require 'pry'
require 'sinatra/flash'

enable :sessions

def db_connection
  begin
    connection = PG.connect(dbname: "urls")
    yield(connection)
  ensure
    connection.close
  end
end

def all_urls
  db_connection do |conn|
    conn.exec("SELECT * FROM urls;")
  end
end

def check_for_duplicates(db_column, url)
  binding.pry
  db_connection do |conn|
    conn.exec_params("SELECT $1 FROM urls WHERE $1=$2;", [db_column, url])
  end
end

def create_short_url
  # random_url = ""
  # 4.times do 
  #   random_url += ("a".."z").to_a.sample
  #   random_url += ("0".."9").to_a.sample
  # end
  random_url = "f7o1d6v4"
  if check_for_duplicates("short_url", random_url)
    binding.pry
  end
end

get "/" do
  erb :index, locals: { urls: all_urls }
end

post "/" do
  long_url = params[:long_url]
  short_url = create_short_url

  db_connection do |conn|
    conn.exec_params("INSERT INTO URLS (long_url, short_url) VALUES ($1, $2)", [long_url, short_url])
  end
  redirect "/"
end
