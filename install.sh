#!/data/data/com.termux/files/usr/bin/bash
#Script for installing pacman.

info(){
echo -e "\033[1;36m\n# $1\033[0m"
}

commet(){
echo -e "\033[0;32m# $1\033[0m"
}

error(){
echo -e "\033[1;31m# $1\033[0m"
}

set -e

install_packages(){
  info 'System and package updates.'
  pkg update -y
  pkg upgrade -y

  info 'Installing packages.'
  pkg install build-essential asciidoc gpgme nettle wget curl -y
}

install_pacman(){
  info 'Directory creation.'
  dir=$PREFIX/var/cache/
  if [[ -d $dir ]]; then
    commet "Found: $dir"
  else
    mkdir $dir
    commet "Create: $dir"
  fi

  info 'Installing pacman.'
  if [[ ! -d pacman ]]; then
    error 'Not found: pacman.'
    exit 2
  fi
  cd pacman
  if [[ -z $1 || "$1" == "config" ]]; then
    ./configure --prefix=$PREFIX
  fi
  if [[ -z $1 || "$1" == "make" ]]; then
    set +e
    while :
    do
      make
      if (( "$?" == "0" )); then
        break
      else
        commet 'Error correction.'
        if [[ -z "`grep '$(AM_V_CCLD)$(LINK) $(pacman_OBJECTS) $(pacman_LDADD) $(LIBS) -landroid-glob' src/pacman/Makefile`" ]]; then
          sed -i 's/$(AM_V_CCLD)$(LINK) $(pacman_OBJECTS) $(pacman_LDADD) $(LIBS)/$(AM_V_CCLD)$(LINK) $(pacman_OBJECTS) $(pacman_LDADD) $(LIBS) -landroid-glob/' src/pacman/Makefile
        fi
        if [[ -z "`grep '$(AM_V_CCLD)$(LINK) $(pacman_conf_OBJECTS) $(pacman_conf_LDADD) $(LIBS) -landroid-glob' src/pacman/Makefile`" ]]; then
          sed -i 's/$(AM_V_CCLD)$(LINK) $(pacman_conf_OBJECTS) $(pacman_conf_LDADD) $(LIBS)/$(AM_V_CCLD)$(LINK) $(pacman_conf_OBJECTS) $(pacman_conf_LDADD) $(LIBS) -landroid-glob/' src/pacman/Makefile
        fi
      fi
    done
    set -e
  fi
  if [[ -z $1 || "$1" == "ins" ]]; then
    make install
  fi
  cd ..
}

settings_pacman(){
  info 'Pacman settings.'
  wget --inet4-only http://mirror.archlinuxarm.org/aarch64/core/pacman-mirrorlist-20210307-1-any.pkg.tar.xz
  pacman -U pacman-mirrorlist-20210307-1-any.pkg.tar.xz --noconfirm
  rm pacman-mirrorlist-20210307-1-any.pkg.tar.xz
  sed -i 's+RootDir     = /data/data/com.termux/files/usr/+RootDir     = /data/data/com.termux/files/+' $PREFIX/etc/pacman.conf
  sed -i 's/#this//' $PREFIX/etc/pacman.conf

  info 'Run pacman.'
  pacman -Syu
  pacman -S filesystem --noconfirm
}

if [[ "$1" == "help" ]]; then
  info 'Help'
  commet 'When running a specific command, only that command will be executed.'
  commet 'Commands:'
  commet '  upd - installing and updating packages.'
  commet '  ins - installing pacman.'
  commet '    config - run the configure script.'
  commet '    make - run make.'
  commet '    ins - run make install'
  commet '  set - setting up pacman.'
else
  if [[ -z $1 || "$1" == "upd" ]]; then
    install_packages
  fi
  if [[ -z $1 || "$1" == "ins" ]]; then
    install_pacman $2
  fi
  if [[ -z $1 || "$1" == "set" ]]; then
    settings_pacman
  fi
  info 'Done.'
fi
