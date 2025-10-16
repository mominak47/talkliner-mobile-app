#!/usr/bin/env python3
"""
Simple HTTP server for serving the Talkliner web client
"""
import http.server
import socketserver
import webbrowser
import os
import sys
from pathlib import Path

PORT = 8000

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add CORS headers for API requests
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

def main():
    # Change to the www directory
    www_dir = Path(__file__).parent
    os.chdir(www_dir)
    
    # Create server
    with socketserver.TCPServer(("", PORT), CustomHTTPRequestHandler) as httpd:
        print(f"🎙️ Talkliner Web Server")
        print(f"📁 Serving directory: {www_dir}")
        print(f"🌐 Server running at: http://localhost:{PORT}")
        print(f"📄 Available files:")
        
        # List available HTML files
        html_files = list(www_dir.glob("*.html"))
        for html_file in html_files:
            print(f"   • http://localhost:{PORT}/{html_file.name}")
        
        print(f"\n🚀 Recommended: http://localhost:{PORT}/index-local.html")
        print(f"💡 Press Ctrl+C to stop the server")
        
        # Try to open browser automatically
        try:
            webbrowser.open(f'http://localhost:{PORT}/index-local.html')
            print(f"🌍 Opened browser automatically")
        except:
            pass
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print(f"\n👋 Server stopped")
            sys.exit(0)

if __name__ == "__main__":
    main()
