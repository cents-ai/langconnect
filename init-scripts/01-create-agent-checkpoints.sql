-- Create agent_checkpoints table for LangGraphJS persistence
CREATE TABLE IF NOT EXISTS agent_checkpoints (
  id SERIAL PRIMARY KEY,
  thread_id VARCHAR(255) NOT NULL,
  user_id VARCHAR(255) NOT NULL,
  config JSONB NOT NULL,
  state JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(thread_id)
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS agent_checkpoints_thread_id_idx ON agent_checkpoints(thread_id);
CREATE INDEX IF NOT EXISTS agent_checkpoints_user_id_idx ON agent_checkpoints(user_id);

-- Grant permissions to the default PostgreSQL user
GRANT ALL PRIVILEGES ON TABLE agent_checkpoints TO CURRENT_USER;
