#!/bin/bash

[ $# -eq 0 ] && echo 'Database server HOST and PORT arguments are required' && exit 1

DB_SERVER=$1:$2
DB_NAME='public_data'
DB_USER='db_admin'

echo -n "Please enter db_admin user password: "
read -s DB_PWD

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

for FILE in ${parent_path}/*.sql; do
  psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" -f $FILE
done