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
  The RubyInstaller should prompt you to install MSYS2 and its development toolchain. If not, you can manually install it by running `ridk install` in Command Prompt and following the instructions
#### 3. Install Gosu 
  Run `gem install gosu` to install Gosu. Since there no other dependencies used in this program, installing bundler is not necessary
#### 4. Installation Validation
  To validate that ruby and gosu have ben installed, run `ruby -v` and `gem list gosu` to check for each tool respectively. In terms of MSYS2, if you can open the 64-bit command line then it's already installed successfully.
#### 5. Run the program
  To run the program, navigate to the directory where the music_player.rb file is located and run `ruby music_player.rb`
