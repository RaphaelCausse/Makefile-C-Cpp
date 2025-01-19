[![OS](https://img.shields.io/badge/os-linux-blue.svg)](https://shields.io/)

# MAKEFILE

Makefile template for small to medium sized C projects, for **Linux**.

You can build the project in two modes : **release** or **debug**.

By default, the build is in **debug** mode.

Please follow recommended project layout.


## TABLE OF CONTENTS
 
- [Project Layout](#project-layout)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Author](#author)


## PROJECT LAYOUT

To use this makefile template properly, please follow the project layout bellow.
```
──┬─[ Project ]
  │
  ├──── Makefile
  │
  ├──┬─[ src ]
  │  │
  │  ├──── *.c
  │  ├──── *.h
  │  ...
  │
  ...
```


## INSTALLATION

**Clone** this repository :
```
git clone https://github.com/RaphaelCausse/makefile.git
```
**Move** to the cloned directory :
```
cd makefile
```
**Copy** the Makefile in your project at root level of your project directory.
```
cp Makefile <path_to_your_project>
```


## USAGE

**Fill** the Makefile variables `TARGET_NAME` and `SOURCE_FILES` at the top.

**Update** the Makefile variables to match your needs.

**Build** the project in **release** mode :
```
make release
```
**Build** the project in **debug** mode :
```
make debug
```


## FEATURES

**Clean** the project by removing generated files :
```
make clean
make cleanall
```
**Display** info about the project :
```
make info
```
**Display** help message:
```
make help
```


## AUTHOR

Raphael CAUSSE
