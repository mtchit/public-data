#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

raw_path="${parent_path}/raw/ibge"

common_states="go ro ac am rr pa ap ma pi rn pb se ba mg es rj pr sc rs ms mt to ce pe al df"
all_states="sp ${common_states}"

setores_path="${parent_path}/ibge/setor_censitario"

mkdir -p $setores_path
for state in $all_states; do
  unzip ${raw_path}/setor_censitario/${state}.zip \
    -d ${setores_path}/${state} \
    || exit 1

  cd ${setores_path}/${state}
  for file in *; do
    extension="${file##*.}"
    mv "$file" "setores.${extension}" || exit 1
  done
  cd - > /dev/null

  input_shape="/source_data/ibge/setor_censitario/${state}/setores.shp"
  target="ibge.setor_censitario"
  output_sql="/source_data/ibge/setor_censitario/${state}.sql"
  convertion_cmd="shp2pgsql -s 4674 -a -g geom -W LATIN1"
  docker run -i --rm \
    -v ${parent_path}:/source_data \
    postgis/postgis:12-3.0-alpine \
    bash -c "${convertion_cmd} ${input_shape} ${target} > ${output_sql}" \
    || exit 1

  rm -rf ${setores_path}/${state} || exit 1
done

resultados_path="${parent_path}/ibge/resultados"
# basico_path="${resultados_path}/basico"
domicilio_path="${resultados_path}/domicilio_02"
pessoa_renda_path="${resultados_path}/pessoa_renda"

# mkdir -p $basico_path
mkdir -p $domicilio_path
mkdir -p $pessoa_renda_path


treat_resultados () {
  uf_name=$1
  file_suffix=$2

  unzip ${raw_path}/resultados/${uf_name}.zip \
  -d ${resultados_path}/${uf_name} \
  || exit 1

  find ${resultados_path}/${uf_name} -mindepth 2 -type f -exec mv -- '{}' ${resultados_path}/${uf_name} \; || exit 1

  # sed 's/,/./g' "${resultados_path}/${uf_name}/Basico_${file_suffix}.csv" \
  #   > "${basico_path}/${uf_name}.csv" \
  #   || exit 1

  cp "${resultados_path}/${uf_name}/Domicilio02_${file_suffix}.csv" \
    "${domicilio_path}/${uf_name}.csv" \
    || exit 1
  cut -d ";" -f 135 --complement "${resultados_path}/${uf_name}/PessoaRenda_${file_suffix}.csv" \
    | sed 's/"X"/X/g' \
    > "${pessoa_renda_path}/${uf_name}.csv" \
    || exit 1

  rm -rf ${resultados_path}/${uf_name} || exit 1
}


for uf in $(echo ${common_states} | tr a-z A-Z); do
  treat_resultados $uf $uf
done

# SP
treat_resultados "SP_Exceto_a_Capital" "SP2"
treat_resultados "SP_Capital" "SP1"