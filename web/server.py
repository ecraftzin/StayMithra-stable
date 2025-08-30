#!/usr/bin/env python3
"""
Simple HTTP server to serve the password reset page.
Run this script to serve the reset-password.html file locally.

Usage:
    python server.py

The server will run on http://localhost:8000
"""

import http.server
import socketserver
import os
import sys

# Change to the web directory
web_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(web_dir)

PORT = 8000

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add CORS headers
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

    def do_GET(self):
        # Serve reset-password.html for any request
        if self.path == '/' or self.path.startswith('/reset-password'):
            self.path = '/reset-password.html'
        super().do_GET()

if __name__ == "__main__":
    try:
        with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
            print(f"Server running at http://localhost:{PORT}")
            print(f"Serving files from: {web_dir}")
            print("Press Ctrl+C to stop the server")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        sys.exit(0)
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)
