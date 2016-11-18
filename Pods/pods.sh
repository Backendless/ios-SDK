#!/bin/sh

git tag '3.0.44'
git push --tags
pod trunk push Backendless.podspec
pod trunk push Backendless-ios-SDK.podspec
pod trunk push Backendless-osx-SDK.podspec
pod trunk push Backendless-Light.podspec
