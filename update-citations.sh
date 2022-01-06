#!/bin/bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb
#
# this script is started either from a cronjob or a webhook and it updates
# http://www.fieldtriptoolbox.org/citation/

LOCKFILE=$HOME/citations.lock
LOGFILE=$HOME/citations.log

if [ "$(uname)" == "Darwin" ]; then
  STAT=$(which gstat)
  DATE=$(which gdate)
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  STAT=$(which stat)
  DATE=$(which date)
fi

# prevent concurrent execution
while [[ -e $LOCKFILE ]] ; do
  LOCKTIME=$(( $($DATE +"%s") - $($STAT -c "%Y" $LOCKFILE) ))
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

TARGETDIR=$HOME/fieldtrip/release/website

SCRIPTDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# module load anaconda3
conda activate citations

cd $TARGETDIR/_data/citedby || exit
$SCRIPTDIR/update-citations.py

cd $TARGETDIR
git add _data/citedby/*.yml
git commit -am "added papers from Pubmed that cite FieldTrip"
git push

date > $LOGFILE
rm $LOCKFILE
