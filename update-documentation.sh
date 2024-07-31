#!/usr/bin/env bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb
#
# this script is started either from a cronjob or a webhook and it updates
# http://www.fieldtriptoolbox.org/reference/
# http://www.fieldtriptoolbox.org/reference/configuration

# specify working directories
PROJECTDIR=/project/3011231.02/
FIELDTRIPDIR=$PROJECTDIR/fieldtrip/fieldtrip
WEBSITEDIR=$PROJECTDIR/fieldtrip/website

LOCKFILE=$PROJECTDIR/fieldtrip/documentation.lock
LOGFILE=$PROJECTDIR/fieldtrip/documentation.log

# prevent concurrent builds
while [[ -e $LOCKFILE ]] ; do
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
[[ -e $LOGFILE  ]] || touch $LOGFILE
[[ -e $LOCKFILE ]] || touch $LOCKFILE

MATLABSCRIPT=$HOME/fieldtrip_reference.m

# create the MATLAB script
cat > $MATLABSCRIPT << EOF
try,
% set up the path
restoredefaultpath
addpath('$FIELDTRIPDIR');
addpath('$FIELDTRIPDIR/connectivity');
addpath('$FIELDTRIPDIR/contrib/misc');
addpath('$FIELDTRIPDIR/contrib/nutmegtrip');
addpath('$FIELDTRIPDIR/contrib/spike');
addpath('$FIELDTRIPDIR/engine');
addpath('$FIELDTRIPDIR/external/artinis');
addpath('$FIELDTRIPDIR/fileio');
addpath('$FIELDTRIPDIR/forward');
addpath('$FIELDTRIPDIR/inverse');
addpath('$FIELDTRIPDIR/peer');
addpath('$FIELDTRIPDIR/plotting');
addpath('$FIELDTRIPDIR/preproc');
addpath('$FIELDTRIPDIR/qsub');
addpath('$FIELDTRIPDIR/realtime/example');
addpath('$FIELDTRIPDIR/realtime/online_eeg');
addpath('$FIELDTRIPDIR/realtime/online_meg');
addpath('$FIELDTRIPDIR/realtime/online_mri');
addpath('$FIELDTRIPDIR/specest');
addpath('$FIELDTRIPDIR/statfun');
addpath('$FIELDTRIPDIR/trialfun');
addpath('$FIELDTRIPDIR/utilities');
ft_defaults

% create the reference documentation
system('cd $WEBSITEDIR && git pull');
% system('rm $WEBSITEDIR/reference/*.md');
% ft_documentationreference('$WEBSITEDIR/reference');
% system('cd $WEBSITEDIR && git add reference/*.md && git commit -m "updated reference documentation"');
ft_documentationconfiguration('$WEBSITEDIR/configuration.md');
system('cd $WEBSITEDIR && git add configuration.md && git commit -m "updated configuration index"');
system('cd $WEBSITEDIR && git push');

end % try
exit
EOF

# schedule the MATLAB script for execution
# note that it uses my own matlab_sub, which deals with mem and time
$HOME/bin/matlab_sub --walltime 8:00:00 --mem 4gb $MATLABSCRIPT

date > $LOGFILE
rm $LOCKFILE
