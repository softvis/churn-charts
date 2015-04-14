
module Helper

  def read_log()
    filetable = {} 
 
    log_output = File.open('gitlog.txt', 'rb') { |f| f.read }
    log_lines = log_output.each_line.reject{ |line| line == "\n" }.map(&:chomp)

    unixtime = nil
    log_lines.each do |line|
      if line =~ /^--/ then
        unixtime = line.split(/--/)[1]
      else
        adds, deletes, filename = line.split(/\t/)
        
        # next if ! (filename =~ /app/)
        next if ! (filename =~ /(scala|rb|sh|json|java)(}*)$/)
        next if filename =~ /lambda/

        if match = filename.match(/(.*){(.*) =\> (.*)}(.*)/)
          oldname = (match[1] + match[2] + match[4]).gsub(/\/+/, "/")
          filename = (match[1] + match[3] + match[4]).gsub(/\/+/, "/")
          filetable[filename] = filetable.delete(oldname)
        elsif match = filename.match(/(.*) =\> (.*)/)
          oldname = match[1]
          filename = match[2]
          filetable[filename] = filetable.delete(oldname)
        end  

        entry = filetable[filename] ||= {}
        yield(entry, unixtime, filename, adds, deletes)
      end
    end
    
    filetable
  end
  
  
  def churn_by_file_by_day()
    # returns { fname => { day => { fname, churn } } }
    table = read_log() do | byday, unixtime, filename, adds, deletes |
      day = DateTime.strptime(unixtime,'%s').strftime("%Y-%m-%d")
      entry = byday[day] ||= { :churn => 0, :adds => 0, :deletes => 0 }
      entry[:fname] = filename      
      entry[:adds] += adds.to_i
      entry[:deletes] += deletes.to_i
      entry[:churn] += adds.to_i + deletes.to_i
    end

    table.values.each do | entries |
      entries.keys.sort.inject(0) do |churn, date|
        entries[date][:churnA] = churn + entries[date][:churn] 
      end 
      entries.keys.sort.inject(0) do |size, date|
        entries[date][:size] = size + entries[date][:adds] - entries[date][:deletes] 
      end 
    end
    
    table
  end
  
  def flatten_entries(filetable)
    data = []
    filetable.keys.sort.each_with_index do | fname, findex |
      filetable[fname].each do | date, metrics |
        data << { 
          :findex => findex,
          :date => date, 
          :fname => "/" + metrics[:fname],
          :size => metrics[:size],
          :adds => metrics[:adds],
          :deletes => metrics[:deletes],
          :churn => metrics[:churn], 
          :churnA => metrics[:churnA] 
        }
      end
    end
    data
  end  
  
  
  def churn_by_file()
    # returns { fname => { day => { fname, churn } } }
    table = read_log() do | entry, unixtime, filename, adds, deletes |
      entry[:fname] = filename      
      entry[:count] ||= 0
      entry[:count] += 1
      entry[:churn] ||= 0 
      entry[:churn] += adds.to_i + deletes.to_i
    end
    table.values
  end
  
end

