-- GRANT USAGE ON SCHEMA ibge_v1 TO anonymous;

-- CREATE VIEW ibge_v1.setores AS
--   SELECT cod_setor FROM ibge.basico;
-- GRANT SELECT ON ibge_v1.setores TO anonymous;

-- CREATE VIEW ibge_v1.moradores AS
--   SELECT
--     cod_setor,
--     v001 as total
--   FROM ibge.domicilio_02;
-- GRANT SELECT ON ibge_v1.moradores TO anonymous;

-- CREATE VIEW ibge_v1.pessoas_renda AS
--   SELECT
--     cod_setor,
--     v009 as classe_a,
--     (v007 + v008) as classe_b,
--     V006 as classe_c,
--     (v004 + v005) as classe_d,
--     (v001 + v002 + v003 + v010) as classe_e
--   FROM ibge.pessoa_renda;
-- GRANT SELECT ON ibge_v1.pessoas_renda TO anonymous;
