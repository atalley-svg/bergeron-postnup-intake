-- =============================================================================
-- Bergeron Intake Form -- Supabase Schema
-- Table: marital_agreement_intakes
--
-- Stores prenup/postnup intake questionnaire responses.
-- This is a SEPARATE table from any existing divorce-related tables.
-- Clients access the form via a unique token (?token=abc123) for save/resume.
-- =============================================================================

-- 1. Create the table
CREATE TABLE IF NOT EXISTS marital_agreement_intakes (
    id              uuid            PRIMARY KEY DEFAULT gen_random_uuid(),
    client_name     text            NOT NULL,
    spouse_name     text,
    matter_type     text            DEFAULT 'Marital Property Agreement',
    status          text            DEFAULT 'draft'
                                    CHECK (status IN ('draft', 'final')),
    token           text            UNIQUE NOT NULL,
    responses       jsonb           DEFAULT '{}'::jsonb,
    files_metadata  jsonb           DEFAULT '[]'::jsonb,
    current_step    integer         DEFAULT 1,
    created_at      timestamptz     DEFAULT now(),
    updated_at      timestamptz     DEFAULT now(),
    submitted_at    timestamptz,
    ip_address      text,
    user_agent      text
);

-- 2. Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_marital_agreement_intakes_token
    ON marital_agreement_intakes (token);

CREATE INDEX IF NOT EXISTS idx_marital_agreement_intakes_client_name
    ON marital_agreement_intakes (client_name);

-- 3. Auto-update updated_at on every row change
CREATE OR REPLACE FUNCTION update_marital_agreement_intakes_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_marital_agreement_intakes_updated_at
    ON marital_agreement_intakes;

CREATE TRIGGER trg_marital_agreement_intakes_updated_at
    BEFORE UPDATE ON marital_agreement_intakes
    FOR EACH ROW
    EXECUTE FUNCTION update_marital_agreement_intakes_updated_at();

-- 4. Row Level Security -- service_role only (no anon access)
ALTER TABLE marital_agreement_intakes ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if re-running this script
DROP POLICY IF EXISTS service_role_select ON marital_agreement_intakes;
DROP POLICY IF EXISTS service_role_insert ON marital_agreement_intakes;
DROP POLICY IF EXISTS service_role_update ON marital_agreement_intakes;

CREATE POLICY service_role_select
    ON marital_agreement_intakes
    FOR SELECT
    TO service_role
    USING (true);

CREATE POLICY service_role_insert
    ON marital_agreement_intakes
    FOR INSERT
    TO service_role
    WITH CHECK (true);

CREATE POLICY service_role_update
    ON marital_agreement_intakes
    FOR UPDATE
    TO service_role
    USING (true)
    WITH CHECK (true);

-- 5. Table comment
COMMENT ON TABLE marital_agreement_intakes IS
    'Stores prenuptial and postnuptial agreement intake questionnaire responses. '
    'Each row represents one client intake session identified by a unique token. '
    'The responses column holds all form answers as flexible JSONB. '
    'This table is separate from divorce-related tables and is accessed '
    'exclusively through the service_role (no anonymous access).';
