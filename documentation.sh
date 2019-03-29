#!/bin/sh
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb
#
# this script is started either from a cronjob or a webhook and it updates
# http://www.fieldtriptoolbox.org/reference/
# http://www.fieldtriptoolbox.org/reference/configuration

LOCKFILE=$HOME/documentation.lock
LOGFILE=$HOME/documentation.log

# prevent concurrent builds
while [ -e $LOCKFILE ] ; do
  LOCKTIME=$(( $(date +"%s") - $(stat -c "%Y" $LOCKFILE) ))
  if [ "$LOCKTIME" -gt "300" ]; then
    echo removing stale lock
    rm $LOCKFILE
  else
    echo waiting for previous build to complete
    sleep 10
  fi
done

# make sure that these exist
[ -e $LOGFILE  ] || touch $LOGFILE
[ -e $LOCKFILE ] || touch $LOCKFILE


TARGETDIR=$HOME/fieldtrip/release/website
MATLABSCRIPT=$HOME/fieldtrip_reference.m

# create the MATLAB script
cat > $MATLABSCRIPT << EOF
try,
% set up the path
restoredefaultpath
addpath('$HOME/fieldtrip/release/github');
addpath('$HOME/fieldtrip/release/github/connectivity');
addpath('$HOME/fieldtrip/release/github/contrib/misc');
addpath('$HOME/fieldtrip/release/github/contrib/nutmegtrip');
addpath('$HOME/fieldtrip/release/github/contrib/spike');
addpath('$HOME/fieldtrip/release/github/engine');
addpath('$HOME/fieldtrip/release/github/external/artinis');
addpath('$HOME/fieldtrip/release/github/fileio');
addpath('$HOME/fieldtrip/release/github/forward');
addpath('$HOME/fieldtrip/release/github/inverse');
addpath('$HOME/fieldtrip/release/github/peer');
addpath('$HOME/fieldtrip/release/github/plotting');
addpath('$HOME/fieldtrip/release/github/preproc');
addpath('$HOME/fieldtrip/release/github/qsub');
addpath('$HOME/fieldtrip/release/github/realtime/example');
addpath('$HOME/fieldtrip/release/github/realtime/online_eeg');
addpath('$HOME/fieldtrip/release/github/realtime/online_meg');
addpath('$HOME/fieldtrip/release/github/realtime/online_mri');
addpath('$HOME/fieldtrip/release/github/specest');
addpath('$HOME/fieldtrip/release/github/statfun');
addpath('$HOME/fieldtrip/release/github/trialfun');
addpath('$HOME/fieldtrip/release/github/utilities');
ft_defaults

% create the reference documentation
system('cd $TARGETDIR && git pull');
system('rm $TARGETDIR/reference/*.md');
ft_documentationreference('$TARGETDIR/reference');
ft_documentationindex('$TARGETDIR/reference/configuration.md');
system('cd $TARGETDIR && git add reference/*.md && git commit -m "updated reference documentation"');
system('cd $TARGETDIR && git push');

% create the reference documentation
% system('mkdir -p $TARGETDIR');
% system('rm $TARGETDIR/*.md');
% ft_documentationreference('$TARGETDIR');
% ft_documentationindex('$TARGETDIR/configuration.md');
% system('scp $TARGETDIR/*.md roboos@www.fieldtriptoolbox.org:/home/mrphys/roboos/website/reference');

end % try
exit
EOF

# schedule the MATLAB script for execution
# note that it uses my own matlab_sub, which deals with mem and time
/home/mrphys/roboos/bin/matlab_sub --walltime 8:00:00 --mem 4gb $MATLABSCRIPT
date > $LOGFILE
rm $LOCKFILE

