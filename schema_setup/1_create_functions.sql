GRANT USAGE ON SCHEMA ibge_v1 TO anonymous,app_admin,app_org_manager;

CREATE FUNCTION ibge_v1.vicinity_population(latitude numeric, longitude numeric, radius integer)
RETURNS TABLE("2010" numeric, "2019" numeric, "2020" numeric) AS $$
  SELECT
    SUM(d.v001) as "2010",
    SUM(d.v001 + (d.v001 * (est_2019.populacao / censo.populacao - 1))) as "2019",
    SUM(d.v001 + (d.v001 * (est_2020.populacao / censo.populacao - 1))) as "2020"
  FROM ibge.setor_censitario as setor
  INNER JOIN ibge.domicilio_02 as d
    ON setor.cd_geocodi = d.cod_setor
  INNER JOIN ibge.populacao_municipio_censo_2010 as censo
    ON setor.cd_geocodm = censo.cd_geocodm
  INNER JOIN ibge.populacao_municipio_est_2019 as est_2019
    ON setor.cd_geocodm = est_2019.cd_geocodm
  INNER JOIN ibge.populacao_municipio_est_2020 as est_2020
    ON setor.cd_geocodm = est_2020.cd_geocodm
  WHERE ST_DWithin(
    setor.geom::geography,
    ST_TRANSFORM(ST_SetSRID(ST_POINT(longitude,latitude), 4326), 4674)::geography,
    radius,
    false
  );
$$ LANGUAGE SQL IMMUTABLE security definer;


CREATE FUNCTION ibge_v1.municipality_population(latitude numeric, longitude numeric)
RETURNS TABLE(cd_geocodm text, nome text, "2010" numeric, "2019" numeric, "2020" numeric) AS $$
  SELECT
    setor.cd_geocodm,
    est_2020.nome,
    censo.populacao as "2010",
    est_2019.populacao as "2019",
    est_2020.populacao as "2020"
  FROM ibge.setor_censitario as setor
  INNER JOIN ibge.populacao_municipio_censo_2010 as censo
    ON setor.cd_geocodm = censo.cd_geocodm
  INNER JOIN ibge.populacao_municipio_est_2019 as est_2019
    ON setor.cd_geocodm = est_2019.cd_geocodm
  INNER JOIN ibge.populacao_municipio_est_2020 as est_2020
    ON setor.cd_geocodm = est_2020.cd_geocodm
  WHERE ST_Within(
    ST_TRANSFORM(ST_SetSRID(ST_POINT(longitude,latitude), 4326), 4674),
    setor.geom
  );
$$ LANGUAGE SQL IMMUTABLE security definer;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA ibge_v1 TO app_admin,app_org_manager;

