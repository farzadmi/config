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

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi
