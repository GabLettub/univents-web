#!/bin/bash
set -e

# Clone Flutter SDK if not already present
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
fi

# Add Flutter to path for current session
export PATH="$HOME/flutter/bin:$PATH"

# Pre-cache Flutter and accept licenses
flutter doctor
yes | flutter doctor --android-licenses
flutter precache
