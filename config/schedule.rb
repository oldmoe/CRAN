env :GEM_PATH, ENV['GEM_PATH']
env :PATH, ENV['PATH']
set :output, "./logs/cron_log.log"

every :day, :at => '12:00am' do
  rake "run_indexer"
end
