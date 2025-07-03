-- NOTE: This file is now intentionally empty.
-- The PostgresSaver from @langchain/langgraph-checkpoint-postgres will create
-- all necessary tables and indexes when the setup() method is called.
--
-- The PostgresSaver requires multiple tables:
-- 1. checkpoints - Main table with checkpoint data
-- 2. checkpoint_blobs - For storing binary large objects
-- 3. checkpoint_writes - For tracking writes
-- 4. checkpoint_migrations - For schema versioning
--
-- See the PostgresSaver documentation for more details.

-- Grant permissions to the default PostgreSQL user for all tables that PostgresSaver will create
-- We're granting permissions on the schema level to ensure all tables are covered
GRANT ALL PRIVILEGES ON SCHEMA public TO CURRENT_USER;

-- Ensure permissions for specific tables that PostgresSaver will create
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO CURRENT_USER;

-- Allow the user to create new tables (needed for PostgresSaver.setup())
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO CURRENT_USER;
