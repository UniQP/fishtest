#!/bin/sh
# Backup MongoDB to AWS S3, download a backup with:
# ${VENV}/bin/fetch_file s3://fishtest/backup/archive/<YYYYMMDD>/dump.tar.gz -o dump.tar.gz

# Load the variables with the AWS keys, cron uses a limited environment
. ${HOME}/.profile

cd ${HOME}/backup
for db_name in "fishtest_new" "admin" "fishtest" "fishtest_testing"; do
  mongodump --db=${db_name} --excludeCollection="pgns" --gzip
done
tar -cv dump | gzip -1 > dump.tar.gz
rm -rf dump

date_utc=$(date +%Y%m%d --utc)
mkdir -p archive/${date_utc}
mv dump.tar.gz archive/${date_utc}
${VENV}/bin/s3put -b fishtest -p ${HOME} archive/${date_utc}/dump.tar.gz
# Keep only the latest archive locally
mv archive/${date_utc}/dump.tar.gz .
