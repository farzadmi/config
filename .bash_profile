# Stephen Horst's Customized BASH profile
#
# A quick refresher on startup scripts:
# .profile is a POSIX compliant script only executed if .bash_profile is not present
# .bash_profile executes for login shells (ssh, console)
# .bashrc executes for interactive, non-login shells (xterm)

# On Ubuntu systems,
# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
# umask 022

# I just put everything in bashrc. Who wants to worry about multiple startup scripts...

echo "Loading .bash_profile..."

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    if [ `which tmux 2> /dev/null` -a -z "$TMUX" ]; then
        tmux -2 attach || tmux -2 new; exit
    fi
fi

# My GnuPG Public Key
export GPGKEY=E6D22ABA

# Append my custom compilation paths
machine=`uname -n`
export PATH="$HOME/opt/bin:/opt/bin:$PATH:$HOME/scripts"
if [ $machine == 'dreadnought.jpl.nasa.gov' ]; then
    export PATH="/opt/texlive/2013/bin/x86_64-linux:/opt/MATLAB/R2014a/bin:/opt/ADS2014_01/bin:$PATH:$HOME/tools/sausage/bin:$HOME/tools/Simulation/src"
elif [ $machine == 'uavproc.jpl.nasa.gov' ]; then
    export PATH="$PATH:$HOME/tools/Simulation/src"
elif [ $machine == 'mahuika.jpl.nasa.gov' ]; then
    export PATH="$PATH:$HOME/tools/Simulation/src:/opt/intel/bin"
fi

# Append custom compiled documentation
export MANPATH="$HOME/opt/share/man:$MANPATH"

# Append library paths
export LD_LIBRARY_PATH="$HOME/opt/lib:/opt/intel/lib/intel64:$LD_LIBRARY_PATH"
export FFTW_LIB_DIR="$HOME/opt/lib"
export FFTW_INC_DIR="$HOME/opt/include"

export AGILEESOFD_LICENSE_FILE=27778@cae-lmgr1:27778@cae-lmgr2:27778@cae-lmgr3
export HPEESOF_DIR=/opt/ADS2014_01

export INT_BIN="$HOME/opt/bin"
export INT_SCR="$HOME/opt/share/roi_pac"
export PATH="$PATH:$INT_BIN:$INT_SCR"

export PKG_CONFIG_PATH="$HOME/opt/lib/pkgconfig:$PKG_CONFIG_PATH"


# if running bash
#if [ -n "$BASH_VERSION" ]; then
    ## include .bashrc if it exists
    #if [ -f "$HOME/.bashrc" ]; then
	#. "$HOME/.bashrc"
    #fi
#fi
