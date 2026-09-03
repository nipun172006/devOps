from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        message = b"<h1>Hello World from Python</h1>"

        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(message)


print("Python app is running on port 5000")
HTTPServer(("0.0.0.0", 5000), Handler).serve_forever()
