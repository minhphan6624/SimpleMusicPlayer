# Simple GUI Music Player

This is a simple GUI music player created as a project for an introduction to programming class. The program is written in Ruby and uses the Gosu library for its graphical interface.

## What it does

The music player has a basic user interface with controls for playing music. It supports different genres of music such as Null, Pop, Classic, Jazz, and Rock. The interface includes different containers for artwork, main controls, track list, volume control, and a footer. The dimensions and positions of these containers are defined in the code.

## How to run the program

To run the program, you need to have Ruby and Gosu installed on your machine. If you don't have them installed, you can install them as follows:

### Windows
#### 1. Install Ruby
  - Visit https://rubyinstaller.org/
  - Download the latest version of the Ruby+Devkit installer (for example, Ruby+Devkit 3.x.x-x (x64)).
  - Run the installer to install Ruby (Ensure "Add Ruby executables to your PATH" is checked)
#### 2. Install MSYS2 and Development Toolchain:
  - Download the MSYS2 installer from the MSYS2 website https://www.msys2.org/
  - Run the installer and follow the prompts to install MSYS2 (default directory is C:\msys64).
  - Open the MSYS2 shell by running msys2.exe from the Start menu or the installation directory.
  - Update the package database and core system packages using `pacman -Syu`
  - Close and reopen the MSYS2 shell if prompted.
  - Run the update command again to ensure all packages are up to date `pacman -Su`
  - Run the following command to install necessary dependencies
    `pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-pkg-config mingw-w64-x86_64-sdl2 mingw-w64-x86_64-sdl2_image mingw-w64-x86_64-sdl2_mixer mingw-w64-x86_64-sdl2_ttf`
#### 3. Install Gosu gem
  - run `gem install gosu` to install Gosu
