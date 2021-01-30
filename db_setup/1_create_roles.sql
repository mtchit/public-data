
CREATE ROLE anonymous noinherit nologin;
CREATE ROLE app_admin noinherit nologin;
CREATE ROLE app_org_manager noinherit nologin;

GRANT anonymous TO postgrest;
GRANT app_admin TO postgrest;
GRANT app_org_manager to postgrest;


