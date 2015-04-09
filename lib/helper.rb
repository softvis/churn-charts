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
      elsif line =~ / =\> /
        rename = line.split(/\t/)[2]
        puts ">>#{rename}<<"
        old_name = new_name = nil
        match = /(.*){(.*) =\> (.*)}(.*)/.match(rename)
        if match 
          old_name = (match[1] + match[2] + match[4]).gsub(/\/+/, "/")
          new_name = (match[1] + match[3] + match[4]).gsub(/\/+/, "/")
        else
          match = /(.*) =\> (.*)/.match(rename)
          old_name = match[1]
          new_name = match[2]
        end  
        entry = filetable.delete(old_name)
        filetable[new_name] = entry if entry != nil
        puts "renamed:\n#{old_name}\n#{new_name}\n\n"
      else
        # next if ! (line =~ /app/)
        next if ! (line =~ /(scala|rb|sh|json|java)$/)
        next if line =~ /lambda/
        adds, deletes, filename = line.split(/\t/)
        # filename = filename.split(/\//)[0...-1].join("/")
        byday = filetable[filename] ||= {}
        metrics = byday[day] ||= { :churn => 0, :adds => 0, :deletes => 0 }
        metrics[:adds] += adds.to_i
        metrics[:deletes] += deletes.to_i
        metrics[:churn] += adds.to_i + deletes.to_i
        metrics[:rname] = filename
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
          :fname => "/" + fname, 
          :rname => "/" + metrics[:rname],
          :date => date, 
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

