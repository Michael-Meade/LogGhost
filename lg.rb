require 'ipaddr'
require 'optparse'
class LogEditor
    def initialize(rip: nil, path: "/.env", meth: "GET", remove: nil)
        # replace IP
        @rip  = rip
        @path = path
        @meth = meth
    end
    def log
        File.readlines("access.log").to_a
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
        File.open("access-n.log", 'a') { |file| file.write(text) }
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
#LogEditor.new(rip: "135.125.246.189", path: "/robots.txt").replace
options = {}
OptionParser.new do |parser|
  parser.on("--ip IP", "change IP") do |ip|
    options[:ip] = ip
  end
  parser.on("--path [PATH]", "change PATH") do |path|
    options[:path] = path
  end
  parser.on("--meth [METH]", "change METHOD") do |m|
    options[:meth] = m
  end
  parser.on("-rm", "remove") do |m|
    options[:rm] = true
  end
end.parse!

lg = LogEditor.new(rip: options[:ip], path: options[:path])
if options[:rm]
    lg.remove
else
    lg.replace
end