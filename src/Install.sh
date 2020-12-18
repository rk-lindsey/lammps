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
    sed -i -e 's|^PKG_INC =[ \t]*|&-I../../lib/chimes/|' ../Makefile.package
    sed -i -e 's|^PKG_PATH =[ \t]*|&-L../../lib/chimes/ |' ../Makefile.package
#    sed -i -e 's|^PKG_CPP_DEPENDS =[ \t]*|&-L../../lib/chimes/chimesFF.cpp |' ../Makefile.package
#    sed -i -e 's|^PKG_SYSINC =[ \t]*|&$(chimes_SYSINC) |' ../Makefile.package
#    sed -i -e 's|^PKG_SYSLIB =[ \t]*|&$(chimes_SYSLIB) |' ../Makefile.package
#    sed -i -e 's|^PKG_SYSPATH =[ \t]*|&$(chimes_SYSPATH) |' ../Makefile.package
  fi

  if (test -e ../Makefile.package.settings) then
      echo "here"
    sed -i -e '/^include.*chimes.*$/d' ../Makefile.package.settings
    # multiline form needed for BSD sed on Macs
    sed -i -e '4 i \
include ..\/..\/lib\/chimes\/Makefile.lammps
' ../Makefile.package.settings
  fi

elif (test $1 = 0) then

    pwd

  if (test -e ../Makefile.package) then
    sed -i -e 's/[^ \t]*chimes[^ \t]*//g' ../Makefile.package
  fi

  if (test -e ../Makefile.package.settings) then
    sed -i -e '/^include.*chimes.*$/d' ../Makefile.package.settings
  fi

fi
