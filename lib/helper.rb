require 'securerandom'


module Helper

  def read_log()
    filetable = {} 
 
    log_output = File.open(ARGV[0] || 'gitlog.txt', 'rb') { |f| f.read }
    log_lines = log_output.each_line.reject{ |line| line == "\n" }.map(&:chomp)

    unixtime = nil
    log_lines.each do |line|
      if line =~ /^--/ then
        unixtime = line.split(/--/)[1]
      else
        adds, deletes, filename = line.split(/\t/)
        
        next if ! (filename =~ /\.(scala|rb|sh|java|js|clj)(}*)$/)
        next if filename =~ /lambda/
        next if filename =~ /generated/

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
  
  
  def read_log2()
    cocommits = {}
    id_map = {}
    reverse_map = {} 
 
    log_output = File.open(ARGV[0] || 'gitlog.txt', 'rb') { |f| f.read }
    log_lines = log_output.each_line.reject{ |line| line == "\n" }.map(&:chomp)

    group = []
    log_lines.each do |line|
      if line =~ /^--/ then
        group = []
      else
        adds, deletes, filename = line.split(/\t/)
        
        # next if ! (filename =~ /app/)
        next if ! (filename =~ /\.(scala|rb|sh|java|js|clj)(}*)$/)
        next if filename =~ /lambda/
        next if filename =~ /generated/

        if match = filename.match(/(.*){(.*) =\> (.*)}(.*)/)
          oldname = (match[1] + match[2] + match[4]).gsub(/\/+/, "/")
          filename = (match[1] + match[3] + match[4]).gsub(/\/+/, "/")
          id_map[filename] = id_map[oldname] 
        elsif match = filename.match(/(.*) =\> (.*)/)
          oldname = match[1]
          filename = match[2]
          id_map[filename] = id_map[oldname] 
        end  

        this_id = id_map[filename] ||= SecureRandom.hex(16)
        reverse_map[this_id] = filename
 
        group.each do | other |
          key = [this_id, id_map[other]].sort.join("*")
          cocommits[key] = (cocommits[key] || 0) + 1
        end

        group << filename
        
      end
    end
    
    index_map = {}
    reverse_map.values.sort.each_with_index do | fname, findex |
      index_map[fname] = findex
    end
        
    data = []
    reverse_map.values.sort.combination(2).each do | pair|
      key = [id_map[pair[0]], id_map[pair[1]]].sort.join("*")
      if (weight = cocommits[key]) != nil && weight > 2 then
        data << {
          :name0 => pair[0],
          :name1 => pair[1],
          :index0 => index_map[pair[0]],
          :index1 => index_map[pair[1]],
          :weight => weight
        }
      end
    end  
    data
  end
  
end

