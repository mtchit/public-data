#!/bin/sh

echo "log_statement = 'all'" >> /var/lib/postgresql/data/postgresql.conf

psql \
    -U postgres \
    -c "create role db_admin createdb createrole noinherit login password '${ADMIN_PASS}'"


psql \
    -U postgres \
    -c "create role postgrest noinherit login password '${PGRST_PASS}'"
