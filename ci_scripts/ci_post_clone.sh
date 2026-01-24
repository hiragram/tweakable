#!/bin/sh

# Xcode Cloud post-clone script
# プラグインとマクロの検証をスキップする

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
