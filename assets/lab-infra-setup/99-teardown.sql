-- =====================================================
-- 99: Teardown (Post-Lab Cleanup)
-- =====================================================
-- Run as: ACCOUNTADMIN
-- Purpose: Removes all lab resources after the session.
--          Only run this AFTER the lab is complete.
--
-- USAGE: Replace <username> with each participant's
--        Snowflake username, or use the batch section.
-- =====================================================

USE ROLE ACCOUNTADMIN;

SET user_name = '<username>';
SET role_name = 'COCO_CLI_SANDBOX_ROLE_' || $user_name;
SET wh_name = 'LIQUIDITY_RISK_WH_' || $user_name;
SET db_name = 'LIQUIDITY_RISK_DB_' || $user_name;

-- Drop per-user resources (database, warehouse)
DROP DATABASE IF EXISTS IDENTIFIER($db_name);
DROP WAREHOUSE IF EXISTS IDENTIFIER($wh_name);

-- Revoke grants from per-user role
REVOKE CREATE DATABASE ON ACCOUNT FROM ROLE IDENTIFIER($role_name);
REVOKE CREATE WAREHOUSE ON ACCOUNT FROM ROLE IDENTIFIER($role_name);
REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE IDENTIFIER($role_name);
REVOKE USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT FROM ROLE IDENTIFIER($role_name);
REVOKE MODIFY ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT FROM ROLE IDENTIFIER($role_name);

-- Drop the per-user role
USE ROLE USERADMIN;
DROP ROLE IF EXISTS IDENTIFIER($role_name);


-- ===========================================
-- Per-user warehouses are dropped above.
-- ===========================================


-- ===========================================
-- BATCH TEARDOWN (for multiple participants)
-- ===========================================
-- Generate teardown statements for all HOL users:
--
-- SELECT
--   'SET user_name = ''' || REPLACE(NAME, 'COCO_CLI_SANDBOX_ROLE_', '') || ''';' || CHR(10) ||
--   'SET role_name = ''' || NAME || ''';' || CHR(10) ||
--   'SET wh_name   = ''LIQUIDITY_RISK_WH_' || REPLACE(NAME, 'COCO_CLI_SANDBOX_ROLE_', '') || ''';' || CHR(10) ||
--   'SET db_name   = ''LIQUIDITY_RISK_DB_' || REPLACE(NAME, 'COCO_CLI_SANDBOX_ROLE_', '') || ''';' || CHR(10) ||
--   'USE ROLE ACCOUNTADMIN;' || CHR(10) ||
--   'DROP DATABASE IF EXISTS IDENTIFIER($db_name);' || CHR(10) ||
--   'DROP WAREHOUSE IF EXISTS IDENTIFIER($wh_name);' || CHR(10) ||
--   'REVOKE CREATE DATABASE ON ACCOUNT FROM ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'REVOKE CREATE WAREHOUSE ON ACCOUNT FROM ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'REVOKE DATABASE ROLE SNOWFLAKE.CORTEX_USER FROM ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'REVOKE USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT FROM ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'REVOKE MODIFY ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT FROM ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'USE ROLE USERADMIN;' || CHR(10) ||
--   'DROP ROLE IF EXISTS IDENTIFIER($role_name);'
-- FROM SNOWFLAKE.ACCOUNT_USAGE.ROLES
-- WHERE NAME LIKE 'COCO_CLI_SANDBOX_ROLE_%'
--   AND DELETED_ON IS NULL;
