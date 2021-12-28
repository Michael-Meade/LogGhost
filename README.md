
<div align="center">

**[ABOUT](https://github.com/Michael-Meade/LogGhost/blob/main/README.md#about) • 
[FEATURES](https://github.com/Michael-Meade/LogGhost/blob/main/README.md#features) • 
[COMMANDS](https://github.com/Michael-Meade/LogGhost/blob/main/README.md#commands)**


</div>

# LogGhost

It must be ran with root. 

# About
This tool is able to remove traces from Apache2 logs. It can either remove the entry completely or replace the IP with a randomly generated one. 
The tool is also able to change path and methods to anything the red teamer wants. The code will replace the '/var/log/apache2/access.log` file if it exists.

The tool can also replace any line that the redteamer wants in the Syslog file. By default it will remove any cron entries. 

The tool can also remove any traces in the .bash_history file. Before the red teamer enters any commands, the user must run `ruby message.rb --start`. This will copy the .bash_history file into a new file named .backup. After the command is finished running, the red teamer can enter any command they want. When they are finished red teaming, the user can run `ruby message.rb --end`, this will truncate the .bash_history file and copy over the contents of .backup to the .bash_history file. Everything that done after the --start command was ran will be gone from the log. Note: That there is a little bug that the message.rb script will still be in the log. This is because when you run the --end argument the command is not added to the .bash_history file until the process is finished.


# Features

|  Apache2 	|   bash_history	|   syslog	      |    
|---	      |---	            |---	            | 
| remove IP	| Remove commands |  remove cron  	|   	
| replace method & path  	    |   remove entries|   	 
| replace IP w/ random IP     |   	            |

# Commands
## Remove IP
```ruby
ruby lg.rb --ip 45.146.164.110 -rm
```

## Remove IP & change path
```ruby
ruby lg.rb --ip 193.142.146.242 --path test123.php
```
The command will change the IP, 192.142.146.242 to a random IP and change the orginal path to test123.php


## Change Method
```ruby
ruby lg.rb --ip 193.142.146.242 --meth POST
```

## Change meth, path
```ruby
ruby lg.rb --ip 193.142.146.242 --meth POST --path dew.php
```
