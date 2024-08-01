#!/bin/bash
#
#PBS -l walltime=00:05:00
#PBS -l mem=100Mb
#
# this script is started either from a cronjob or a webhook and it updates
# http://www.fieldtriptoolbox.org/citation/

echo Executing $0

# specify working directories
PROJECTDIR=/project/3011231.02/
LOCKFILE=$PROJECTDIR/fieldtrip/citations.lock
LOGFILE=$PROJECTDIR/fieldtrip/citations.log
WEBSITEDIR=$PROJECTDIR/fieldtrip/website
SCRIPTDIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

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


# set up the appropriate conda environment
source /opt/optenv.sh
module load anaconda3
source activate citations

cd $WEBSITEDIR/_data/citedby || exit
$SCRIPTDIR/update-citations.py

cd $WEBSITEDIR || exit
git checkout master || exit
git pull origin master || exit
git add _data/citedby/*.yml
git commit -am "added papers from Pubmed that cite FieldTrip"
git push origin master

date > $LOGFILE
rm $LOCKFILE
