http = require 'http'
express = require 'express'
fs = require 'fs'
io = require 'socket.io'
marked = require 'marked'


# server general

app = express()
app.use express.static __dirname + '/www'
server = http.createServer app
port = 3000
server.listen port
console.log("Listening on port " + port)

# rendering sugar

pre = '<!doctype html public="embarassment"><meta charset="utf-8"><title>mdserver</title>'

post = '
<script src="lib/jquery-2.0.3.min.js"></script>
<script src="socket.io/socket.io.js"></script> 
<script>$(document).ready(function() {
	var socket = io.connect();
	socket.on("please", function (what) {
		if (what === "refresh") {document.location.reload(true);
	}});
});</script>'

# watch src/ and render

fs.watch "src/", {persistent: true}, (event, filename) ->
	if filename.split('.').pop() == "md"
		fs.readFile "src/" + filename, {encoding: "utf8"}, (err, data) ->
			if err
				throw err
			marked data, { highlight: null }, (err, html) ->
				fs.writeFile "www/" + filename.slice(0, -3), pre + html + post, (err) ->
					if err
						throw err
					console.log "Rendered " + filename
	else
		console.log "Won't render " + filename

# watch www/ and refresh

socket = io.listen server, {log: false}
socket.set 'log level', 1

socket.on 'connection', (socket) ->
	fs.watch "www/", {persistent: true}, (event, filename) ->
		console.log "Refreshing " + filename
		socket.emit 'please', 'refresh'