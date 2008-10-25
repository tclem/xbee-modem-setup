# jd barnhart 2008
# jd at jdbarnhart dot com
#
# setup Xbee Modems 
# 

# Xbee modems ship in router configuration, but can be configured as routers or coordinators with the 
# digi X-CTU software (windows only). A coordinator is necessary to configure a mesh, however 
# for direct communication between modems a coordinator is unnecessary. 
# So for two Xbee modems, the as shipped router firmware works fine.
#
# The purpose of this script:
#
# An Xbee module will only communicate with other 
# modules having the same channel (CH parameter), 
# PAN ID (ID parameter) and destination address 
# (DH + DL parameters).  Reading settings these parameters 
# is the purpose of this script
# 
# This could be thought of as 3 layers: Channel, Pan ID and Destination Address low and high: DL/DH
#
# Note: when a constant is not set, that constant is not written, only read
#
### Step 1
# 
# download and install ruby serial port library http://ruby-serialport.rubyforge.org/
#
### Step 2
# 
# add an xbee shield with xbee shield with both jumpers in usb position (nearest the board edge) to the arduino
# connect the arduino to your computer run this script
# the result should look similar to this:

# using tty.usbserial-A60048pt
# 
# Connected to: serial port
# cmd: ATVR, result: 1220 OK 
# cmd: ATCH, result: 16 OK 
# cmd: ATID, result: 555 OK 
# cmd: ATSL, result: 4052D736 OK 
# cmd: ATSH, result: 13A200 OK 
# cmd: ATDL, result: 4052DAF7 OK 
# cmd: ATDH, result: 13A200 OK 
# cmd: ATNI, result: VISCONTI OK 
# serial port closed


# 
# what is all this?

# ATVR =>firmware version
# ATCH => channel (from 1-16)
# ATID => pan id, or Personal Area Network ID
# ATSL => serial number low (record this)
# ATSH => serial number high (record this)
# ATDL => destination low (assign the serial number low of the target modem to this)
# ATDH => destination high (assign the serial number high of the target modem to this)
# ATNI => networking identification (assign a human readable name... not necessary but very handy)
#
# take a note of the serial low and high, since these will be assigned to destination high and low of the other (destination) modem
#

#### Step Three

# Enter your configurations
# and run the script

# set these five parameters
# Channel
CH = "" # 11 - 26 for XBee modules and 12 - 23 for XBee Pro modules.
# Pan ID
ID = "" # 0 - 65535
# Destination Address Low -- should be the serial low of the modem you wish to send to... run this script to find out
DL = ""
# Destination Address High -- should be the serial low of the modem you wish to send to....run this script to find out
DH = ""
# Networking Identification
NI = "" # anything memorable up to 20 characters 


# Step Four

# run the script and then repeat for your other modem.
# 



#
# determine the usb address


Dir.chdir("/dev")
USB = Dir.glob("tty.usbserial*")
puts "using #{USB}"
puts




commands = [
 { :ATVR => ""}, # firmware version
 { :ATCH => CH}, # channel
 { :ATID => ID}, # pan id 
 { :ATSL => ""}, # serial number low (cannot be changed)
 { :ATSH => ""}, # serial number high (cannot be changed)
 { :ATDL => DL}, # destination address low
 { :ATDH => DH}, # destination address high
 { :ATNI => NI}  # 
]




require 'rubygems'
Kernel::require 'serialport'


class Xbee


  @@mutex = Mutex.new

  def initialize(options = {})
    @@mutex.synchronize do
      begin
        # dev/tty will most likely be different for you
        @port = SerialPort.new(options[:port] || "/dev/#{USB}", options[:baud] || 9600, options[:bits] || 8, options[:stop] || 1, SerialPort::NONE)
        @debug = options[:debug]
        # timeout is touchy
        @port.read_timeout = 100
      rescue Errno::EBUSY
        raise "Cannot connect to the serial port is busy or unavailable."
      end
    end

    if @port.nil?
      $stderr.puts "Cannot connect to usbserial"
    else
      puts "Connected to: serial port" if @debug
    end
    setup
  end

  def close
    @port.close
  end
  
  ## 
  # enter AT Command Mode
  
  def setup
    @port.write("+++")
    sleep 1.2
  end
  
  ## 
  # Write each command

  def cmd(cmd)
    @port.write(cmd + "\r")
    verify(cmd)
  end

  ## 
  # Verify each command

  def verify(cmd)
    result = @port.read
    print_result(cmd, result)
  end
  
  #
  ## Print each result
  
  def print_result(cmd, result)
    puts "cmd: #{cmd} result: #{result}"
  end
    


end

  p = Xbee.new(:debug => true)
    

  commands.each do |command| 
    command.each do |k,v|
      p.cmd("#{k.to_s}#{v}, \r") 
      if v != ""
        p.cmd("#{k.to_s},WR \r") 
      end
    end
  end

  p.close
  puts "serial port closed"
  
  
  
  
#  Reference
#  
#  ID  The network ID of the Xbee module.  0 - 0xFFFF  Default: 3332
#  CH  The channel of the Xbee module.  0x0B - 0x1A  Default: 0X0C
#  SH and SL The serial number of the Xbee module (SH gives the high 32 bits, SL the low 32 bits). Read-only.  0 - 0xFFFFFFFF   (for both SH and SL)  Default: different for each  module
#  MY The 16-bit address of the module.  0 - 0xFFFF  Default: 0
#  DH and DL The destination address for wireless communication  (DH is the high 32 bits, DL the low 32).  0 - 0xFFFFFFFF   (for both DH and DL)  0 (for both DH and  DL)
#  BD    The baud rate used for serial communication with the  Arduino board or computer.  Default: 3 (9600)
#  0 (1200 bps)  
#  1 (2400 bps)  
#  2 (4800 bps)  
#  3 (9600 bps)  
#  4 (19200 bps)  
#  5 (38400 bps)  
#  6 (57600 bps)  
#  7 (115200 bps)  3 (9600 baud)  
  


