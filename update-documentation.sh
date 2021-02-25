#!/usr/bin/env bash
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

TRUNK=$HOME/fieldtrip/release/fieldtrip
TARGETDIR=$HOME/fieldtrip/release/website
MATLABSCRIPT=$HOME/fieldtrip_reference.m

# create the MATLAB script
cat > $MATLABSCRIPT << EOF
try,
% set up the path
restoredefaultpath
addpath('$TRUNK');
addpath('$TRUNK/connectivity');
addpath('$TRUNK/contrib/misc');
addpath('$TRUNK/contrib/nutmegtrip');
addpath('$TRUNK/contrib/spike');
addpath('$TRUNK/engine');
addpath('$TRUNK/external/artinis');
addpath('$TRUNK/fileio');
addpath('$TRUNK/forward');
addpath('$TRUNK/inverse');
addpath('$TRUNK/peer');
addpath('$TRUNK/plotting');
addpath('$TRUNK/preproc');
addpath('$TRUNK/qsub');
addpath('$TRUNK/realtime/example');
addpath('$TRUNK/realtime/online_eeg');
addpath('$TRUNK/realtime/online_meg');
addpath('$TRUNK/realtime/online_mri');
addpath('$TRUNK/specest');
addpath('$TRUNK/statfun');
addpath('$TRUNK/trialfun');
addpath('$TRUNK/utilities');
ft_defaults

% create the reference documentation
system('cd $TARGETDIR && git pull');
system('rm $TARGETDIR/reference/*.md');
ft_documentationreference('$TARGETDIR/reference');
ft_documentationconfiguration('$TARGETDIR/reference/configuration.md');
system('cd $TARGETDIR && git add reference/*.md && git commit -m "updated reference documentation"');
system('cd $TARGETDIR && git push');

end % try
exit
EOF

# schedule the MATLAB script for execution
# note that it uses my own matlab_sub, which deals with mem and time
$HOME/bin/matlab_sub --walltime 8:00:00 --mem 4gb $MATLABSCRIPT
date > $LOGFILE
rm $LOCKFILE
