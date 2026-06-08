#!/bin/bash
# Start Firebase emulators for local integration testing.
# Requires Firebase CLI installed and initialized.
set -e

echo "Starting Firebase emulators..."
firebase emulators:start --only firestore,functions,hosting

# In another terminal, run Flutter tests against emulator, or run Node-based tests.
# Example: flutter test integration tests that point to emulator endpoints.
