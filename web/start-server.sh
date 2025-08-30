#!/bin/bash

echo "Starting StayMithra Password Reset Server..."
echo

# Check if Node.js is available
if command -v node &> /dev/null; then
    echo "Using Node.js server..."
    node server.js
elif command -v python3 &> /dev/null; then
    echo "Using Python server..."
    python3 server.py
elif command -v python &> /dev/null; then
    echo "Using Python server..."
    python server.py
else
    echo "Error: Neither Node.js nor Python found!"
    echo "Please install Node.js or Python to run the server."
    exit 1
fi
