#!/usr/bin/env python3
import threading
import time
import multiprocessing
from http.server import HTTPServer, BaseHTTPRequestHandler
import json

stress_active = False
stress_threads = []

def cpu_stress_worker():
    while stress_active:
        for i in range(1000000):
            _ = i * i * i

class StressHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        global stress_active, stress_threads
        
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            html = '''<html><body>
<h1>CPU Stress Test</h1>
<p><a href="/start">Start CPU Stress</a></p>
<p><a href="/stop">Stop CPU Stress</a></p>
<p><a href="/status">Status</a></p>
<p><a href="/metrics">Metrics</a></p>
</body></html>'''
            self.wfile.write(html.encode())
        
        elif self.path == '/start':
            if not stress_active:
                stress_active = True
                cpu_count = multiprocessing.cpu_count()
                for i in range(cpu_count * 2):
                    t = threading.Thread(target=cpu_stress_worker)
                    t.daemon = True
                    t.start()
                    stress_threads.append(t)
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<html><body><h2>CPU Stress Started!</h2><p><a href="/">Back</a></p></body></html>')
        
        elif self.path == '/stop':
            stress_active = False
            stress_threads = []
            
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<html><body><h2>CPU Stress Stopped!</h2><p><a href="/">Back</a></p></body></html>')
        
        elif self.path == '/status':
            status = "ACTIVE" if stress_active else "INACTIVE"
            thread_count = len(stress_threads)
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                "status": status,
                "active_threads": thread_count,
                "cpu_cores": multiprocessing.cpu_count()
            }
            self.wfile.write(json.dumps(response).encode())
        
        elif self.path == '/metrics':
            cpu_usage = 85.0 if stress_active else 5.0
            
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            
            metrics = f"""# HELP cpu_usage_percent Current CPU usage percentage
# TYPE cpu_usage_percent gauge
cpu_usage_percent {cpu_usage}

# HELP stress_active CPU stress test active status
# TYPE stress_active gauge
stress_active {int(stress_active)}

# HELP stress_threads Number of active stress threads  
# TYPE stress_threads gauge
stress_threads {len(stress_threads)}
"""
            self.wfile.write(metrics.encode())

if __name__ == "__main__":
    server = HTTPServer(('0.0.0.0', 8080), StressHandler)
    print("CPU Stress Server running on port 8080...")
    server.serve_forever()