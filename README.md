## Package Status

| Bintray | Linux & Mac | Windows | 
|:--------:|:---------:|:-------------:|
|[ ![Download](https://api.bintray.com/packages/piponazo/piponazo/XmpSdk%3Apiponazo/images/download.svg) ](https://bintray.com/piponazo/piponazo/XmpSdk%3Apiponazo/_latestVersion)|[![Build Status](https://travis-ci.org/piponazo/conan-xmpsdk.svg?branch=master)](https://travis-ci.org/piponazo/conan-xmpsdk)|[![Build status](https://ci.appveyor.com/api/projects/status/7h0e8d3daqhtbujk/branch/master?svg=true)](https://ci.appveyor.com/project/piponazo/conan-xmpsdk-bj992/branch/master)|

# conan-xmpsdk

Conan recipe for handling the XMP SDK

# Notes about the provided packages

The CMake code of the XMP SDK is far from being ideal and the README provided in their instructions
ask to the users to prepare a bunch on things before being able to configure and compile the code.

I tried to simplify their CMake as much as possible to be able to compile the SDK for the 3 main
platforms: Linux, Mac OSX and Windows. However, I've found some limitations.

## Mac OSX

They are relying on the specification of a OSX SDK version to make things work, but it seems that
the code is not adapted to work with recent versions of the OSX SDK. I tried with several
combinations of xcode and the macosx version and I just left in the travis files the one that works.
