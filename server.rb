require 'sinatra'
require 'json'
require 'date'


helpers do

  def read_log()
    filetable = {}
 
    log_output = File.open('gitlog.txt', 'rb') { |f| f.read }
    log_lines = log_output.each_line.reject{ |line| line == "\n" }.map(&:chomp)

    day = nil
    log_lines.each do |line|
      if line =~ /^--/ then
        unixtime = line.split(/--/)[1]
        day = DateTime.strptime(unixtime,'%s').strftime("%Y-%m-%d")
      else
        # next if ! (line =~ /app/)
        next if ! (line =~ /(scala|rb|sh|json|java)$/)
        next if line =~ /lambda/
        next if line =~ /=\>/
        adds, deletes, filename = line.split(/\t/)
        # filename = filename.split(/\//)[0...-1].join("/")
        filename = "/" + filename
        byday = filetable[filename] ||= {}
        metrics = byday[day] ||= { :churn => 0 }
        metrics[:churn] += adds.to_i + deletes.to_i
      end
    end
    
    filetable
  end
  
  def aggregate_churn(filetable)
    filetable.values.each do | entries |
      sum = 0
      entries.keys.sort.each do | date |
        sum += entries[date][:churn]
        entries[date][:churnA] = sum 
      end
    end
    filetable
  end
  
  def flatten_entries(filetable)
    data = []
    filetable.keys.sort.each_with_index do | fname, findex |
      filetable[fname].each do | date, metrics |
        data << { 
          :findex => findex,
          :fname => fname, 
          :date => date, 
          :churn => metrics[:churn], 
          :churnA => metrics[:churnA] 
        }
      end
    end
    data
  end

end

get '/' do
  erb :index
end

get '/matrix' do
  erb :matrix
end

get '/data.js' do
  content_type :json
  flatten_entries(aggregate_churn(read_log())).to_json
end
