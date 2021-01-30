#!/bin/bash

[ $# -eq 0 ] && echo 'Database server HOST and PORT arguments are required' && exit 1

DB_SERVER=$1:$2
DB_NAME='public_data'
DB_USER='db_admin'

echo -n "Please enter db_admin user password: "
read -s DB_PWD

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

setores_path="${parent_path}/ibge/setor_censitario"
populacao_path="${parent_path}/ibge/populacao_municipio"
resultados_path="${parent_path}/ibge/resultados"


echo 'Importing setores censitarios:'
cd ${setores_path}
for file in *.sql; do
    echo $file
  psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" -f $file || exit 1
done
cd - > /dev/null
echo

echo 'Importing populacao:'
cd ${populacao_path}
for file in *.csv; do
  echo $file
  filename="${file%.*}"
  psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" \
    -c "\copy ibge.populacao_municipio_${filename} FROM '${file}' WITH DELIMITER ',' CSV HEADER;" \
    || exit 1
done
cd - > /dev/null
echo

# echo 'Importing basico:'
# cd ${resultados_path}/basico
# for file in *.csv; do
#   echo $file
#   psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" \
#     -c "\copy ibge.basico FROM '${file}' WITH DELIMITER ';'  NULL as '' CSV HEADER encoding 'ISO-8859-1';" \
#     || exit 1
# done
# cd - > /dev/null
# echo

echo 'Importing domicilio_02:'
cd ${resultados_path}/domicilio_02
for file in *.csv; do
  echo $file
  psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" \
    -c "\copy ibge.domicilio_02 FROM '${file}' WITH DELIMITER ';' NULL as 'X' CSV HEADER;" \
    || exit 1
done
cd - > /dev/null
echo

echo 'Importing pessoa_renda:'
cd ${resultados_path}/pessoa_renda
for file in *.csv; do
  echo $file
  psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" \
    -c "\copy ibge.pessoa_renda FROM '${file}' WITH DELIMITER ';' NULL as 'X' CSV HEADER;" \
    || exit 1
done
cd - > /dev/null
echo

psql "postgresql://$DB_USER:$DB_PWD@$DB_SERVER/$DB_NAME" \
    -c "VACUUM ANALYZE" \
    || exit 1