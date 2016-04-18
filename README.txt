Nevermore is a webserver, written in Ruby, designed for a networking class. 
As such, it has no security, uses an XML config file, and doesn't support
all filetypes. 

Running it is simple. 
Type: 
	$ ruby webserver.rb
and the server will begin.

From there, you may telnet in or use a browser window to open localhost 2880.
The browser will serve any resources placed in the "stuff" folder,  including
many filetypes that are not listed in the get_content_type method.

Nevermore implements server side caching (MAX_HASH_SIZE is the variable that
controls the size of the hash) and persistent connections. 

Because my Internet was down when I was coding this, I've written a few lines
on a parody of "The Raven" (by Poe, if you're an uncultured swine who didn't
already know that). This is a work in progress that will likely be finished after
the semester is over. Unless my Internet goes down again and I can't complete
the homework.