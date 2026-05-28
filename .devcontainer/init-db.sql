-- Create the odoo role if it doesn't exist
DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'odoo') THEN
      CREATE ROLE odoo WITH LOGIN PASSWORD 'odoo' CREATEDB;
   END IF;
END
$$;
