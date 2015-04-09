module Helper

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

        # filename = filename.split(/\//)[0...-1].join("/")
        byday = filetable[filename] ||= {}
        metrics = byday[day] ||= { :churn => 0, :adds => 0, :deletes => 0 }
        metrics[:adds] += adds.to_i
        metrics[:deletes] += deletes.to_i
        metrics[:churn] += adds.to_i + deletes.to_i
        metrics[:fname] = filename
      end
    end
    
    filetable
  end
  
  def aggregate_churn(filetable)
    filetable.values.each do | entries |
      sum = 0
      size = 0
      entries.keys.sort.each do | date |
        size += entries[date][:adds] - entries[date][:deletes]
        entries[date][:size] = size
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
  
end

