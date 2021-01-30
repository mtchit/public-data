#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

setores_base_url='https://geoftp.ibge.gov.br/organizacao_do_territorio/malhas_territoriais/malhas_de_setores_censitarios__divisoes_intramunicipais/censo_2010/setores_censitarios_shp'
resultados_base_url='ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2010/Resultados_do_Universo/Agregados_por_Setores_Censitarios'

raw_path="${parent_path}/raw/ibge"

common_states="ro ac am rr pa ap to ma pi ce rn pb al se ba mg es rj pr sc rs ms mt df"
states_minus_go="sp pe ${common_states}"
states_minus_sp_pe="go ${common_states}"

mkdir -p ${raw_path}/setor_censitario
for state in $states_minus_go; do
  if ! [[ -s "${raw_path}/setor_censitario/${state}.zip" ]]; then
    wget -O ${raw_path}/setor_censitario/${state}.zip \
      ${setores_base_url}/${state}/${state}_setores_censitarios.zip \
      || exit 1
  fi
done

# Goiás
if ! [[ -s "${raw_path}/setor_censitario/go.zip" ]]; then
  wget -O ${raw_path}/setor_censitario/go.zip \
    "${setores_base_url}/go/go_setores%20_censitarios.zip" \
    || exit 1
fi


mkdir -p ${raw_path}/resultados
for uf in $(echo ${states_minus_sp_pe} | tr a-z A-Z); do
  if ! [[ -s "${raw_path}/resultados/${uf}.zip" ]]; then
    wget -O ${raw_path}/resultados/${uf}.zip \
      ${resultados_base_url}/${uf}_20171016.zip \
      || exit 1
  fi
done

if ! [[ -s "${raw_path}/resultados/PE.zip" ]]; then
  wget -O ${raw_path}/resultados/PE.zip \
      ${resultados_base_url}/PE_20200219.zip \
      || exit 1
fi

if ! [[ -s "${raw_path}/resultados/SP_Capital.zip" ]]; then
  wget -O ${raw_path}/resultados/SP_Capital.zip \
      ${resultados_base_url}/SP_Capital_20190823.zip \
      || exit 1
fi

if ! [[ -s "${raw_path}/resultados/SP_Exceto_a_Capital.zip" ]]; then
  wget -O ${raw_path}/resultados/SP_Exceto_a_Capital.zip \
      ${resultados_base_url}/SP_Exceto_a_Capital_20190207.zip \
      || exit 1
fi
