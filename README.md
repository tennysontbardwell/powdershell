# Powder Shell

Created by Tennyson T Bardwell (ttb33), Quinn Halpin (qmh4), and Sitar Harel (sh927)

Created for CS 3110, Data Structures and Functional Programming, Fall 2016

## Installation

**NOTE:** Our system is known to run substantially slower on Macs which drastically reduces the creative experience. We've proudly shown our project to dozens of people who've collectively spent hours playing. We highly recommend using Linux to get the full effect of this project - even a virtual machine running Linux in Mac OS X will perform better than native Mac OS X.

This requires OCaml 4.03.0.

If you have opam install and set up for OCaml 4.03.0 then run `opam install utop yojson lambda-term oUnit` to install all dependencies. This can be run with `make install-dep`.

A fresh install of ubuntu should be able to run our project after `make install-ubuntu` is run. This will install OCaml and opam using apt-get and then install Powder Shell's dependencies.

### Docker

```bash
docker run --privileged -it --rm -v $(pwd):/code ubuntu
apt-get update
apt-get install make
cd /code
make install-ubuntu
```

## How To Run

### Launching the Game

Run `make` to compile and launch Powder Shell.
### Playing the Game

Launch the game and press `h` for help.

![Help Menu](media/help_menu.png "Help Menu")

The save file 'beach' is pre-loaded, load it by pressing load and entering 'beach'.

### Testing, Compiling, Cleaning

Run `make test` to compile and run test cases.

Run `make compile` if you wish to only compile. From here running `./main.bytes` will launch the game.

Run `make clean` to remove build files.

