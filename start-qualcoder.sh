#!/bin/bash

# Starte Xvfb (virtueller Display-Server) auf Display :0 (Port 5900)
Xvfb :0 -screen 0 1024x768x16 &

# Starte Fluxbox als Fenster-Manager
fluxbox &

# Aktiviere die virtuelle Umgebung und starte QualCoder
source env/bin/activate
qualcoder &

# Starte noVNC, um die GUI im Browser zugänglich zu machen
websockify --web /noVNC 8080 localhost:5900

