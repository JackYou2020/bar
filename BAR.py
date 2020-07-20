import BaseHTTPServer
import urlparse
import os, sys
class RequestHandler(BaseHTTPServer.BaseHTTPRequestHandler):
    # page template
    PageTemplate = '''\
        <html>
        <body>
        <p>Welcome, {name}!</p>
        </body>
        </html>
    '''

    def do_GET(self):
        page = self.create_page()
        self.send_content(page)

    def create_page(self):
        #get params
        url_result = urlparse.urlparse(self.path)
        args = urlparse.parse_qs(url_result.query)
        name = 'every one' 
        if args:
            if args.get('name'):
                name = args.get('name')[0]
        page = self.PageTemplate.format(name = name)
        return page

    def send_content(self, content, status=200):
        self.send_response(status)
        self.send_header("Content-type", "text/html")
        self.send_header("Content-Length", str(len(content)))
        self.end_headers()
        self.wfile.write(content)


#----------------------------------------------------------------------
if __name__ == '__main__':
    serverAddress = ('', 8080)
    server = BaseHTTPServer.HTTPServer(serverAddress, RequestHandler)
    server.serve_forever()
