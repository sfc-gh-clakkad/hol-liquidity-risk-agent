-- =====================================================
-- 02: Create Per-User Warehouse
-- =====================================================
-- Run as: SYSADMIN
-- Purpose: Creates LIQUIDITY_RISK_WH_<username> for each participant.
--          Run AFTER 01-create-role-and-grants.sql.
--
-- USAGE: Replace <username> with each participant's Snowflake
--        username, or use the batch script at the bottom.
-- =====================================================

USE ROLE SYSADMIN;

-- ===========================================
-- SINGLE USER SETUP (repeat per participant)
-- ===========================================

SET user_name = '<username>';  -- e.g., 'jmorrison'
SET wh_name = 'LIQUIDITY_RISK_WH_' || $user_name;
SET role_name = 'COCO_CLI_SANDBOX_ROLE_' || $user_name;

CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($wh_name)
WITH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE;

GRANT USAGE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE IDENTIFIER($role_name);
GRANT OPERATE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE IDENTIFIER($role_name);


-- ===========================================
-- BATCH SETUP (for multiple participants)
-- ===========================================
-- Generate warehouse creation + grants for all provisioned roles:
--
-- SELECT
--   'SET user_name = ''' || REPLACE(NAME, 'COCO_CLI_SANDBOX_ROLE_', '') || ''';' || CHR(10) ||
--   'SET wh_name = ''LIQUIDITY_RISK_WH_' || REPLACE(NAME, 'COCO_CLI_SANDBOX_ROLE_', '') || ''';' || CHR(10) ||
--   'CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($wh_name) WITH WAREHOUSE_SIZE=''MEDIUM'' AUTO_SUSPEND=300 AUTO_RESUME=TRUE INITIALLY_SUSPENDED=TRUE;' || CHR(10) ||
--   'GRANT USAGE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE ' || NAME || ';' || CHR(10) ||
--   'GRANT OPERATE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE ' || NAME || ';'
-- FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
-- WHERE NAME LIKE 'COCO_CLI_SANDBOX_ROLE_%'
--   AND DELETED_ON IS NULL;
