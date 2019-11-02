#!/usr/bin/env mruby

# usage: bicompile.rb src/main.rb build/main.mrb

class Bi::Compile
  attr_reader :included_files, :line_count, :index, :code
  def initialize(mainfile,load_path=[])
    @mainfile = File.basename(mainfile)
    @load_path = [ File.dirname(mainfile) ] + load_path
    @included_files = {}
    @index = []
    @line_count = 0
    @code = ""
  end

  def run
    read @mainfile
    @header = "begin\n"
    @code = @header + @code
    @code +=<<EOS
rescue => e
  _FILE_INDEX_ = #{@index.to_s}
  table = []
  _FILE_INDEX_.reverse_each{|i|
    filename = i[0]
    start_line = i[1]
    end_line = i[2]
    table.fill filename, (start_line..end_line)
  }

  puts "\#{e.class}: \#{e.message}"
  e.backtrace.each{|b|
    m = b.chomp.split(":")
    if m.size < 2
      puts b
    else
      line = m[1].to_i - #{@header.lines.size} -1
      message = m[2..-1].join(":")
      original_filename = table[line]
      original_line = table[0..line].count original_filename
      puts "\#{original_filename}:\#{original_line}:\#{message}"
    end
  }
end
EOS
  end

  def write(line)
    @code << line + "\n"
    @line_count += 1
  end

  def memory(file)
    path = File.expand_path file
    return false if @included_files[path]
    @included_files[path] = true
  end

  def read(filename)
    filename = filename+".rb" unless filename.end_with? ".rb"

    filepath = nil
    @load_path.find{|l|
      f = File.join(l,filename)
      if File.exists? f
        filepath = f
        break
      end
    }

    puts "read #{filepath}"
    unless filepath
      puts "#{filepath} not found"
      return
    end

    unless memory filepath
      puts "#{filepath} already included."
      return
    end

    s = File.read(filepath).split "\n"
    s << "# #{filepath}"
    start_line = @line_count
    s.each{|l|
      if l.start_with? "$LOAD_PATH"
        write "# #{l}"
      elsif l.start_with? "require"
        next_file = l.chomp
        next_file.slice! "require"
        next_file.gsub! '"', ''
        next_file.gsub! "'", ''
        next_file.gsub! ' ', ''
        write "# #{l}"
        self.read next_file
      else
        write l
      end
    }

    @index << [filename,start_line,@line_count-1]
  end

  def handle_error_log(error_log)
    table = []
    @index.reverse_each{|i|
      filename = i[0]
      start_line = i[1]
      end_line = i[2]
      table.fill filename, (start_line..end_line)
    }

    error_log.each_line{|l|
      m = l.chomp.split(":")
      if m.size < 2
        puts l
      else
        line = m[1].to_i - @header.lines.size - 1
        message = m[2..-1].join(":")
        original_filename = table[line]
        if original_filename
          original_line = table[0..line].count original_filename
          puts "#{original_filename}:#{original_line}:#{message}"
        else
          puts l
        end
      end
    }
  end
end

class Restorer
  def initialize
    tmp = []


    fileline = {}
    @index = tmp.each.with_index.map{|filename,i|
      fileline[filename] = fileline[filename].to_i + 1
      "#{filename}:#{fileline[filename]}"
    }
  end

  def restore(message)
    m = message.chomp.split(":")
    if m.size < 2
      print "#{message}"
    else
      line = m[1].to_i + 1
      text = m[2..-1].join(":")
      puts "#{@index[line]}:#{text}"
    end
  end
end


if $0 == __FILE__
  infile = ARGV[0]
  outfile = ARGV[1]

  exit 1 if infile.to_s.empty? or outfile.to_s.empty?

  exit 1 unless infile.end_with? ".rb"

  compile = Bi::Compile.new infile
  compile.run

  dir = File.dirname outfile
  dirs = dir.split File::SEPARATOR
  dirs.inject(""){|sum,d|
    new_dir = sum.empty? ? d : File.join(sum,d)
    Dir.mkdir new_dir unless Dir.exist? new_dir
    new_dir
  }

  tmpfile = File.join dir, "_" + File.basename(infile)
  File.open(tmpfile,"w"){|f| f.write compile.code }

  cmd = "mrbc -g -o #{outfile} #{tmpfile}"
  puts cmd
  compile_log = `#{cmd} 2>&1`

  if $? != 0
    puts "compile failed..."
    compile.handle_error_log compile_log
    exit 1
  else
    File.delete tmpfile
    puts "delete #{tmpfile}"
  end

end
