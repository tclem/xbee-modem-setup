require 'serial'

class Xbee
  
  def initialize(opts={})
    @s = Serial.new({:buffer_until => "\r"})
    puts "connecting to xbee radio and configuring AT mode..."
    @s.write("+++")
    r = read_response
    puts "xbee says: #{r}"
    setup
  end
  
  def setup
    @commands = [
      {:cmd => "ATVR", :desc => "\t\tfirmware version", :value => nil},
      {:cmd => "ATCH", :desc => "\t\tchannel", :value => "F"},
      {:cmd => "ATID", :desc => "\t\tpan id", :value => "20F"},
      {:cmd => "ATSL", :desc => "serial# lo", :value => nil},
      {:cmd => "ATSH", :desc => "\tserial# hi", :value => nil},
      {:cmd => "ATDL", :desc => "\t\tdest address lo", :value => "FFFF"},
      {:cmd => "ATDH", :desc => "\t\tdest address hi", :value => nil},
      {:cmd => "ATNI", :desc => "\t\tnetwork id", :value => nil},
      ]
  end
  
  def show_settings
    puts "Current settings on this xbee radio:"
    @commands.each do |c|
      r = write_cmd(c[:cmd])
      puts "#{c[:cmd]}: 0x#{r} (#{r.to_i(16)})   #{c[:desc]}"
    end
  end
  
  def write_settings
    show_settings
    puts
    puts "Writing new settings to this xbee radio..."
    puts
    
    @commands.each do |c| 
      if c[:value].nil?
        next
      end
      #puts "going to write this: #{c[:cmd]}#{c[:value]}\tATWR\t#{c[:cmd]}"
      write_cmd("#{c[:cmd]}#{c[:value]}")
      write_cmd("ATWR")
      r = write_cmd(c[:cmd])
      puts "#{c[:cmd]}: 0x#{r} (#{r.to_i(16)})   #{c[:desc]}"
    end
    
    puts "Successfully configure xbee with new settings"
    
  end
  
  def reset_settings
    write_cmd("ATRE")
    write_cmd("ATWR")
    puts "Settings have been restored to factory defaults."
    puts
    show_settings
  end
  
  # Basic read/write operations
  def write_cmd(cmd)
    @s.write("#{cmd}\r")
    r = read_response
    r.slice!("\r")  # get rid of last <CR>
    r
  end
  
  def read_response
    begin
      r = @s.read!
      finished = true if r
    end until finished
    @s.clear_buffer!
    r
  end
  
  def method_missing(method, *args, &block)
    @s.send(method, *args)
  end
  
end

x = Xbee.new
x.show_settings
x.close

