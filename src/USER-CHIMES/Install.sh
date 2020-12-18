# Install/unInstall package files in LAMMPS
# mode = 0/1/2 for uninstall/install/update

mode=$1

# enforce using portable C locale
LC_ALL=C
export LC_ALL

# arg1 = file, arg2 = file it depends on

action () {
  if (test $mode = 0) then
    rm -f ../$1
  elif (! cmp -s $1 ../$1) then
    if (test -z "$2" || test -e ../$2) then
      cp $1 ..
      if (test $mode = 2) then
        echo "  updating src/$1"
      fi
    fi
  elif (test -n "$2") then
    if (test ! -e ../$2) then
      rm -f ../$1
    fi
  fi
}

# all package files with no dependencies

for file in *.cpp *.h; do
  test -f ${file} && action $file
done

# edit 2 Makefile.package files to include/exclude package info

if (test $1 = 1) then

  if (test -e ../Makefile.package) then
      
    # Grab the stable ChIMES library files from the repo
      
    git clone ssh://git@mybitbucket.llnl.gov:7999/chms/chimes_calculator.git ../../lib/chimes/chimes_calculator
    cd ../../lib/chimes/chimes_calculator
    git checkout baec0773988 --quiet # Use this specific (stable) release
    cd -
    
    # Ensure package makefile is pointing to the right things
    
    sed -i -e 's|^PKG_INC =[ \t]*|&-I../../lib/chimes/chimes_calculator|' ../Makefile.package
    sed -i -e 's|^PKG_PATH =[ \t]*|&../lib/chimes/chimes_calculator/chimesFF.cpp|' ../Makefile.package
    sed -i -e 's|^PKG_LIB =[ \t]*|&-L../lib/chimes/chimes_calculator|' ../Makefile.package
  fi

  if (test -e ../Makefile.package.settings) then
    sed -i -e '/^include.*chimes.*$/d' ../Makefile.package.settings
    # multiline form needed for BSD sed on Macs
    sed -i -e '4 i \
include ..\/..\/lib\/chimes\/Makefile.lammps
' ../Makefile.package.settings
  fi

elif (test $1 = 0) then
    
    rm -rf ../../lib/chimes/chimes_calculator

  if (test -e ../Makefile.package) then
    sed -i -e 's/[^ \t]*chimes[^ \t]*//g' ../Makefile.package
  fi

  if (test -e ../Makefile.package.settings) then
    sed -i -e '/^include.*chimes.*$/d' ../Makefile.package.settings
  fi

fi
