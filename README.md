# apt-rollback

Undo the last APT command or a specified one


    Usage: apt-rollback [--last] [--remove/--reinstall package-name] [--help]

      --last       Undo the last APT command
                   Supports the undo of the only Install, Remove and Purge commands
    
      --remove     Remove an INSTALLED package and related configuration files
                   Removing also all its first installed dependencies

      --reinstall  Reinstall a REMOVED package,
                   and all its first installed dependences
                   Reproducing exactly its first installation

      --help       Print the help

### TO INSTALL:

    wget https://gitlab.com/fabio.dellaria/apt-rollback/-/raw/master/apt-rollback.sh && chmod +x ./apt-rollback.sh

### TO USE:

    ./apt-rollback.sh

### A Little Demo...

![Demo Image](https://gitlab.com/fabio.dellaria/apt-rollback/-/raw/master/apt-rollback.gif)
