# |
# o---------------------------------------------------------------------o
# |
# | MAD makefile
# |
# o---------------------------------------------------------------------o
# |
# | Methodical Accelerator Design
# |
# | Copyright (c) 2011+ CERN, mad@cern.ch
# |
# | For more information, see http://cern.ch/mad
# |
# o---------------------------------------------------------------------o
# |
# | $Id$
# |

# For makefile documentation, please read make/README
# For information and bug report, please contact mad@cern.ch
#
# See below for examples of using madx Makefile (see also make/README):
#   - toggle yes/no flags to set up your configuration
#   - by default madx uses the fortran compiler for linking (i.e. LD = FC)
#   - note that gfortran 4.4 or higher is required to compile madx

# clean all build files generated by Lahey 32 bits compiler for madx32
#   - depends on OSTYPE (detected), FC and ARCH !!!
# make FC=lf95 ARCH=32 cleanall

# show all the infomation collected by the makefile for Intel 64 bits compilers
#   - depends on user setup, ARCH is detected !!!
# make CC=icc FC=ifort infoall

# use complilers famillies shortcuts (default COMP=gnu)
# make COMP=gnu   infoall (equiv. to CC=gcc CXX=g++ FC=gfortran)
# make COMP=intel infoall (equiv. to CC=icc CXX=icc FC=ifort on Unix)
# make COMP=intel infoall (equiv. to CC=icl CXX=icl FC=ifort on Windows)

# build madx32 static online version for debug using Nag fortran compiler/linker
# make FC=nagfor ARCH=32 STATIC=yes ONLINE=yes DEBUG=yes

# build madx64 online version using Intel ifort compiler/linker and show commands
# make FC=ifort ONLINE=yes SHOW=yes

# build madx32 static online version using gfortran44 as compiler/linker
# make FC=gfortran44 FCNAME=gfortran ARCH=32 STATIC=yes ONLINE=yes

###################
# Project settings

PROJECT  := madx

# online version - includes SDDS I/O: yes/no (default is no)
ONLINE   := no

# alternative DA package: yes/no (default is yes)
NTPSA    := no

# use garbage collector: yes/no (default is no)
USEGC    := no

#################
# Build settings
#

# architecture bit: detect/32/64 (default is detect)
ARCH     := detect

# debugging mode: yes/no (default is no)
DEBUG    := no

# profiling mode: yes/no (default is no)
PROFILE  := no

# link with static libs: yes/no (default is no)
STATIC   := no

# plugin dynamic loading: yes/no (default is no)
PLUGIN   := no

# OpenMP activation: yes/no (default is no, GCC, Intel and LLVM only)
OPENMP   := no

# OPENMPFILES is set in Makefile_f90 for MAD-X
# OPENMPFILES := $(wildcard src/*)
# OPENMPFILES := $(notdir $(shell grep -l -e '^\#pragma  *omp' -e '^\!\$$OMP' src/*))

# Sanitizer activation: yes/no (default is no, requires GCC >= 4.8)
# to visualize the ouput, use scripts/asan_symbolize.py
SANITIZE := no

#############################
# Compilers, Linkers, Testers settings
# see make/compiler.* for supported compilers
# COMP=gnu   sets CC=gcc,     CXX=g++,     FC=gfortran (default)
# COMP=intel sets CC=icc/icl, CXX=icc/icl, FC=ifort    (use icl on Windows)

# C compiler (default is gcc)
CC  	:= gcc

# C++ compiler (default is g++)
CXX 	:= g++

# Fortran compiler (default is gfortran)
FC  	:= gfortran

# Linker (default is Fortran compiler, deferred)
LD   	 = $(FC)

# Main is in fortran (default is no)
FCMAIN 	:= no

# Tester (default is numdiff)
ND  	:= numdiff

####################
# Includes settings

# makefiles to include (in this order, all optional, here are default names)
FILE_PRE  := Makefile_pre          # user's preprocessing extra stuff
FILE_VER  := VERSION               # setup project VERSION, VERSION_NUM and VERSION_DATE
FILE_CPP  := Makefile_cpp          # setup project specific CPPFLAGS defines
FILE_C    := Makefile_c            # setup project CC_SRC and CC_HDR
FILE_CXX  := Makefile_cxx          # setup project CXX_SRC and CXX_HDR
FILE_F90  := Makefile_f90          # setup project FC_SRC
FILE_LIB  := Makefile_lib          # setup project LIBS paths and libs
FILE_SYS  := Makefile_sys          # setup project System specific stuffs
FILE_TEST := Makefile_test         # setup project tests
FILE_POST := Makefile_post         # user's postprocessing extra stuff

####################
# Makefile includes

makedir := make
include $(makedir)/make.inc

# end of makefile
