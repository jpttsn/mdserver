http = require 'http'
express = require 'express'
fs = require 'fs'
io = require 'socket.io'
marked = require 'marked'


#options

verbose = false
process.argv.forEach (val, index, array) ->
	if val == "-v" or val == "--verbose"
		verbose = true

# server general

app = express()
app.use express.static __dirname + '/www'
server = http.createServer app
port = 3000
server.listen port
if verbose
	console.log("Listening on port " + port)

# rendering sugar

pre = '<!doctype html public="display of affection"><meta charset="utf-8">
<script src="lib/MathJax/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
<script type="text/x-mathjax-config">
MathJax.Hub.Config({tex2jax: {inlineMath: [["$","$"]] }});
</script>
<title>mdserver: '

post = '

<script src="lib/jquery-2.0.3.min.js"></script>
<script src="socket.io/socket.io.js"></script> 
<script> $(document).ready(function() {
	var socket = io.connect();
	socket.on("please", function (what) {
		if (what === "refresh") {document.location.reload(true);}
	});
}); </script>'

# watch src/ and render

fs.watch "src/", {persistent: true}, (event, filename) ->
	if filename.split('.').pop() == "md"
		fs.readFile "src/" + filename, {encoding: "utf8"}, (err, data) ->
			if err
				throw err
			marked data, { highlight: null, gfm: true }, (err, html) ->
				fs.writeFile "www/" + filename.slice(0, -3), pre + filename + '</title>' + html + post, (err) ->
					if err
						throw err
					if verbose
						console.log "Rendered " + filename
	else
		if verbose
			console.log "Won't render " + filename

# watch www/ and refresh

socket = io.listen server, {log: false}
socket.set 'log level', 1

socket.on 'connection', (socket) ->
	fs.watch "www/", {persistent: true}, (event, filename) ->
		if verbose
			console.log "Refreshing " + filename
		socket.emit 'please', 'refresh'