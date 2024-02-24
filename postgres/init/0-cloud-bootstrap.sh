#!/bin/bash

# Add an admin role that replicates the admin role of managed postgres providers
# like Cloud SQL. This makes it easier to switch to managed postgres later.

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOF
    CREATE USER $ADMIN_USER WITH CREATEDB CREATEROLE PASSWORD '$ADMIN_PASSWORD';
    SET ROLE $ADMIN_USER;
    CREATE DATABASE cohere;
EOF

exit 0
