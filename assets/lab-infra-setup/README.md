# Lab Infrastructure Setup

These scripts provision the per-user Snowflake roles required for the Liquidity Risk HOL. They are intended to be run **once** by an administrator before the lab session begins.

Each participant gets their own `COCO_CLI_SANDBOX_ROLE_<username>` with grants to create databases, warehouses, and use Cortex AI features. Participants then create their own database and warehouse as the first step of Exercise 1.

## Scripts

| Script | Run As | Purpose |
|--------|--------|---------|
| `01-create-role-and-grants.sql` | USERADMIN / ACCOUNTADMIN | Creates per-user role with all required grants |
| `02-create-warehouse.sql` | SYSADMIN | Creates per-user LIQUIDITY_RISK_WH_&lt;username&gt; and grants usage |
| `99-teardown.sql` | ACCOUNTADMIN / USERADMIN | Drops all lab resources after the session |

## Execution Order

```bash
# Run in Snowsight or via SnowSQL
01-create-role-and-grants.sql   # repeat per participant (see batch section in file)
02-create-warehouse.sql         # optional shared warehouse
```

## What Each Participant Gets

After running scripts 01 and 02 for a user, their `COCO_CLI_SANDBOX_ROLE_<username>` has:

| Privilege | Purpose |
|-----------|---------|
| CREATE DATABASE ON ACCOUNT | Create LIQUIDITY_RISK_DB in Exercise 1 |
| CREATE WAREHOUSE ON ACCOUNT | Create additional warehouses if needed |
| SNOWFLAKE.CORTEX_USER database role | Cortex Analyst, semantic views, agents |
| CREATE SNOWFLAKE INTELLIGENCE ON ACCOUNT | Register agent to CoWork in Exercise 4 |
| USAGE + MODIFY on SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT | Add agents to CoWork |
| USAGE + OPERATE on LIQUIDITY_RISK_WH_&lt;username&gt; | Per-user warehouse for all exercises |

## What Participants Create Themselves (Exercise 1)

- `LIQUIDITY_RISK_DB` database with schemas: RAW, TRANSFORMED, PRESENTATION, RAW_SANDBOX

## Post-Lab Cleanup

Run `99-teardown.sql` for each participant to drop their database, warehouses, and role.
