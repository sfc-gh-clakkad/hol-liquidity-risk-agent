-- =====================================================
-- Lab Infrastructure Setup — Liquidity Risk HOL
-- =====================================================
-- Run as: ACCOUNTADMIN
-- Purpose: Provisions a per-user role, warehouse, and all grants
--          needed for exercises 1-5. Each participant gets:
--            • COCO_CLI_SANDBOX_ROLE_<username>
--            • LIQUIDITY_RISK_WH_<username>  (Medium, auto-suspend 5 min)
--            • CREATE DATABASE / CREATE WAREHOUSE on account
--            • SNOWFLAKE.CORTEX_USER database role
--            • USAGE + MODIFY on the shared Snowflake Intelligence object
--
-- USAGE:
--   1. Set the user_name variable below for each participant.
--   2. Run the entire script (or use the batch generator at the bottom).
-- =====================================================

USE ROLE ACCOUNTADMIN;

-- ───────────────────────────────────────────────────────
-- ONE-TIME ACCOUNT SETUP (idempotent, run once)
-- ───────────────────────────────────────────────────────
CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT;

-- Email notification integration (for SEND_LCR_SUMMARY procedure)
CREATE NOTIFICATION INTEGRATION IF NOT EXISTS LCR_EMAIL_INTEGRATION
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('*');


-- ───────────────────────────────────────────────────────
-- PER-USER SETUP (repeat for each participant)
-- ───────────────────────────────────────────────────────

SET user_name = '<username>';  -- e.g., 'jmorrison'
SET role_name = 'COCO_CLI_SANDBOX_ROLE_' || $user_name;
SET wh_name  = 'LIQUIDITY_RISK_WH_' || $user_name;

-- 1. Create role and assign to user
USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS IDENTIFIER($role_name);
GRANT ROLE IDENTIFIER($role_name) TO ROLE SYSADMIN;
GRANT ROLE IDENTIFIER($role_name) TO USER IDENTIFIER($user_name);

-- 2. Account-level privileges
USE ROLE ACCOUNTADMIN;
GRANT CREATE DATABASE ON ACCOUNT TO ROLE IDENTIFIER($role_name);
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE IDENTIFIER($role_name);

-- 3. Cortex AI access
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE IDENTIFIER($role_name);

-- 4. Snowflake Intelligence access
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE IDENTIFIER($role_name);
GRANT MODIFY ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE IDENTIFIER($role_name);

-- 5. Email notification integration access
GRANT USAGE ON INTEGRATION LCR_EMAIL_INTEGRATION TO ROLE IDENTIFIER($role_name);

-- 6. Create and grant warehouse
USE ROLE SYSADMIN;
CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($wh_name)
WITH
    WAREHOUSE_SIZE   = 'MEDIUM'
    AUTO_SUSPEND     = 300
    AUTO_RESUME      = TRUE
    INITIALLY_SUSPENDED = TRUE;

GRANT USAGE   ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE IDENTIFIER($role_name);
GRANT OPERATE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE IDENTIFIER($role_name);


-- ───────────────────────────────────────────────────────
-- BATCH GENERATOR (for multiple participants)
-- ───────────────────────────────────────────────────────
-- Run the SELECT below to produce the full setup script
-- for every user matching a naming pattern (e.g., HOL_%).
--
-- SELECT
--   '-- === ' || NAME || ' ===' || CHR(10) ||
--   'SET user_name = ''' || NAME || ''';' || CHR(10) ||
--   'SET role_name = ''COCO_CLI_SANDBOX_ROLE_' || NAME || ''';' || CHR(10) ||
--   'SET wh_name   = ''LIQUIDITY_RISK_WH_' || NAME || ''';' || CHR(10) ||
--   'USE ROLE USERADMIN;' || CHR(10) ||
--   'CREATE ROLE IF NOT EXISTS IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT ROLE IDENTIFIER($role_name) TO ROLE SYSADMIN;' || CHR(10) ||
--   'GRANT ROLE IDENTIFIER($role_name) TO USER ' || NAME || ';' || CHR(10) ||
--   'USE ROLE ACCOUNTADMIN;' || CHR(10) ||
--   'GRANT CREATE DATABASE ON ACCOUNT TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT MODIFY ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'USE ROLE SYSADMIN;' || CHR(10) ||
--   'CREATE WAREHOUSE IF NOT EXISTS IDENTIFIER($wh_name) WITH WAREHOUSE_SIZE=''MEDIUM'' AUTO_SUSPEND=300 AUTO_RESUME=TRUE INITIALLY_SUSPENDED=TRUE;' || CHR(10) ||
--   'GRANT USAGE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT OPERATE ON WAREHOUSE IDENTIFIER($wh_name) TO ROLE IDENTIFIER($role_name);'
--   AS setup_sql
-- FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
-- WHERE NAME LIKE 'HOL_%'
--   AND DELETED_ON IS NULL;
