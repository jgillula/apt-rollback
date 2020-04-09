# apt-rollback

Undo the last APT command or a specified one

    Usage: apt-rollback [--last <n>] [--remove/--reinstall package-name] [--help]

      --last       Undo the last <n> APT commands
                   Supports the undo of the only Install, Remove and Purge commands
    
      --remove     Remove an INSTALLED package and related configuration files
                   Removing also all its first installed dependencies

      --reinstall  Reinstall a REMOVED package,
                   and all its first installed dependences
                   Reproducing exactly its first installation

      --help       Print the help

## TO INSTALL

    wget https://gitlab.com/fabio.dellaria/apt-rollback/-/raw/master/apt-rollback -O ./apt-rollback && chmod +x ./apt-rollback

## TO USE

    ./apt-rollback

## A Little Demo

![Demo Image](https://gitlab.com/fabio.dellaria/apt-rollback/-/raw/master/apt-rollback.gif)
