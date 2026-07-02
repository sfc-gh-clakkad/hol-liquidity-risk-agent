-- =====================================================
-- 01: Create Per-User CoCo Role and Grants
-- =====================================================
-- Run as: USERADMIN (role creation), then ACCOUNTADMIN (grants)
-- Purpose: Creates a COCO_CLI_SANDBOX_ROLE_<username> for each
--          lab participant with all privileges needed to complete
--          exercises 1-5 autonomously (no elevated roles required).
--
-- USAGE: Replace <username> with each participant's Snowflake
--        username, or use the batch script at the bottom.
-- =====================================================

-- ===========================================
-- SINGLE USER SETUP (repeat per participant)
-- ===========================================

SET user_name = '<username>';  -- e.g., 'jmorrison'
SET role_name = 'COCO_CLI_SANDBOX_ROLE_' || $user_name;

-- Step 1: Create the role
USE ROLE USERADMIN;
CREATE ROLE IF NOT EXISTS IDENTIFIER($role_name);
GRANT ROLE IDENTIFIER($role_name) TO ROLE SYSADMIN;
GRANT ROLE IDENTIFIER($role_name) TO USER IDENTIFIER($user_name);

-- Step 2: Grant account-level privileges
USE ROLE ACCOUNTADMIN;

-- Database & warehouse creation (needed for Ex.1 DB ownership and Ex.3 agent warehouse)
GRANT CREATE DATABASE ON ACCOUNT TO ROLE IDENTIFIER($role_name);
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE IDENTIFIER($role_name);

-- Cortex AI access (needed for semantic views, Cortex Analyst, agents)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE IDENTIFIER($role_name);

-- Snowflake Intelligence / CoWork (needed for Ex.4 registration)
GRANT CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT TO ROLE IDENTIFIER($role_name);

-- Create Snowflake Intelligence object (one-time, idempotent) and grant access
CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT;
GRANT USAGE ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE IDENTIFIER($role_name);
GRANT MODIFY ON SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT TO ROLE IDENTIFIER($role_name);


-- ===========================================
-- BATCH SETUP (for multiple participants)
-- ===========================================
-- Generate GRANT statements for all users matching a pattern:
--
-- SELECT 
--   'SET role_name = ''COCO_CLI_SANDBOX_ROLE_' || NAME || ''';' || CHR(10) ||
--   'USE ROLE USERADMIN;' || CHR(10) ||
--   'CREATE ROLE IF NOT EXISTS IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT ROLE IDENTIFIER($role_name) TO ROLE SYSADMIN;' || CHR(10) ||
--   'GRANT ROLE IDENTIFIER($role_name) TO USER ' || NAME || ';' || CHR(10) ||
--   'USE ROLE ACCOUNTADMIN;' || CHR(10) ||
--   'GRANT CREATE DATABASE ON ACCOUNT TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE IDENTIFIER($role_name);' || CHR(10) ||
--   'GRANT CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT TO ROLE IDENTIFIER($role_name);'
-- FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
-- WHERE NAME LIKE 'HOL_%'
--   AND DELETED_ON IS NULL;
