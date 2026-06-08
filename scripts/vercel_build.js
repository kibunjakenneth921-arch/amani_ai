const { spawnSync } = require('child_process');
const { existsSync } = require('fs');
const path = require('path');

const flutterDir = path.join(process.cwd(), 'flutter');
const flutterBin = path.join(flutterDir, 'bin', 'flutter');
const isWindows = process.platform === 'win32';

function run(command, args, options = {}) {
  console.log(`Running: ${command} ${args.join(' ')}`);
  const result = spawnSync(command, args, {
    stdio: 'inherit',
    env: options.env || process.env,
    shell: true,
  });
  if (result.error) {
    console.error(`Error spawning ${command}:`, result.error);
    throw result.error;
  }
  if (result.status !== 0) {
    throw new Error(`Command failed with exit code ${result.status}: ${command} ${args.join(' ')}`);
  }
  return result;
}

function ensureFlutter() {
  // Check if flutter already exists globally
  console.log('Checking for Flutter SDK...');
  const result = spawnSync('flutter', ['--version'], {
    stdio: 'ignore',
    shell: true,
  });
  
  if (result.status === 0) {
    console.log('Found Flutter in PATH');
    return 'flutter';
  }

  // Check if we have a local clone
  if (existsSync(flutterBin)) {
    console.log('Found local Flutter clone');
    return flutterBin;
  }

  // Clone Flutter
  console.log('Cloning Flutter SDK...');
  try {
    run('git', ['clone', 'https://github.com/flutter/flutter.git', '-b', 'stable', flutterDir]);
  } catch (e) {
    console.error('Failed to clone Flutter:', e.message);
    throw e;
  }

  return flutterBin;
}

function addDartDefines(args, keys) {
  for (const key of keys) {
    const value = process.env[key];
    if (value) {
      args.push(`--dart-define=${key}=${value}`);
    }
  }
}

function main() {
  const flutter = ensureFlutter();

  run(flutter, ['--version']);
  run(flutter, ['channel', 'stable']);
  run(flutter, ['upgrade', '--force']);
  run(flutter, ['pub', 'get']);

  // Ensure web platform is configured
  console.log('Configuring Flutter for web...');
  run(flutter, ['create', '.', '--platforms', 'web']);

  const buildArgs = ['build', 'web', '--release'];
  addDartDefines(buildArgs, [
    'GEMINI_API_KEY',
    'GEMINI_API_URL',
    'OPENAI_API_KEY',
    'FIREBASE_API_KEY',
    'FIREBASE_AUTH_DOMAIN',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_STORAGE_BUCKET',
    'FIREBASE_MESSAGING_SENDER_ID',
    'FIREBASE_APP_ID',
    'FIREBASE_MEASUREMENT_ID',
  ]);

  run(flutter, buildArgs);
  console.log('Build complete!');
}

main().catch(e => {
  console.error('Build failed:', e.message);
  process.exit(1);
});

