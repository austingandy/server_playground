require 'socket'
require 'uri'

WEB_ROOT = './public'

CONTENT_TYPE_MAPPING = {
	'html' => 'text/html',
	'txt' => 'text/plain',
	'png' => 'image/png',
	'jpg' => 'image/jpeg'
}

DEFAULT_CONTENT_TYPE = 'application/octet-stream'

def content_type(path)
	ext = File.extname(path).split('.').last
	CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

def requested_file(request_line)
	request_uri = request_line.split(" ")[1]
	path = URI.unescape(URI(request_uri).path)
	clean = []
	parts = path.split("/")

	parts.each do |part|
		next if part.empty? || part == '.'
		part == '..' ? clean.pop : clean << part
	end

	File.join(WEB_ROOT, *clean)
end

server = TCPServer.new 5678

def write_successful_file_response(sock, file)
	sock.print "HTTP/1.1 200\r\n"
	sock.print "Content-Type: #{content_type(file)}\r\n"
	sock.print "Content-Length: #{file.size}\r\n"
	sock.print "Connection: close\r\n"
	sock.print "\r\n"
	IO.copy_stream(file, sock)
end

def write_failed_message_response(sock, message)
	sock.print "HTTP/1.1 404 Not Found\r\n" +
                 "Content-Type: text/plain\r\n" +
                 "Content-Length: #{message.size}\r\n" +
                 "Connection: close\r\n" +
                 "\r\n"
    sock.print(message)
end

while session = server.accept
	request = session.readpartial(2048)
	# params = {}
	# request.split('?').last.split(' ').first.split('&').each{|input|
	# 	k, v = input.split('=')
	# 	params[URI.unescape(k)] = URI.unescape(v)
	# }
	STDERR.puts request

	path = requested_file(request)

	if File.exist?(path) && !File.directory?(path)
		File.open(path, "rb") do |file|
			write_successful_file_response(session, file)
		end
	else
		message = "File not found\n"
		write_failed_message_response(session, message)
	end

	session.close
end