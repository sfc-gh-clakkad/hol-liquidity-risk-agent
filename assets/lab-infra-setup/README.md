# Lab Infrastructure Setup

These scripts provision the per-user Snowflake roles required for the Liquidity Risk HOL. They are intended to be run **once** by an administrator before the lab session begins.

Each participant gets their own `COCO_CLI_SANDBOX_ROLE_<username>` with grants to create databases, warehouses, and use Cortex AI features. Participants then create their own database and warehouse as the first step of Exercise 1.

## Scripts

| Script | Run As | Purpose |
|--------|--------|---------|
| `00-lab-setup.sql` | ACCOUNTADMIN | Creates per-user role, warehouse, and all required grants |
| `99-teardown.sql` | ACCOUNTADMIN | Drops all lab resources after the session |

## Running from the Command Line

### Prerequisites

Install the [Snowflake CLI](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index) (`snow`) or [SnowSQL](https://docs.snowflake.com/en/user-guide/snowsql):

```bash
# Snowflake CLI (preferred)
pip install snowflake-cli-labs

# or SnowSQL
# https://docs.snowflake.com/en/user-guide/snowsql-install-config
```

### Single user setup (Snowflake CLI)

```bash
# Replace <username> with the participant's Snowflake username
snow sql -f assets/lab-infra-setup/00-lab-setup.sql \
  -D "user_name='jmorrison'" \
  --role ACCOUNTADMIN
```

If your CLI connection doesn't default to ACCOUNTADMIN, pass the connection explicitly:

```bash
snow sql -f assets/lab-infra-setup/00-lab-setup.sql \
  -D "user_name='jmorrison'" \
  --connection admin_conn
```

### Single user setup (SnowSQL)

```bash
# Start SnowSQL as ACCOUNTADMIN
snowsql -a <account> -u <admin_user> -r ACCOUNTADMIN

# Then inside the SnowSQL prompt:
!define user_name='jmorrison'
!source assets/lab-infra-setup/00-lab-setup.sql
```

Or run non-interactively:

```bash
snowsql -a <account> -u <admin_user> -r ACCOUNTADMIN \
  -D user_name='jmorrison' \
  -f assets/lab-infra-setup/00-lab-setup.sql
```

### Batch provisioning (multiple users)

```bash
# Loop over a list of usernames
for USER in jmorrison agarcia kwilson; do
  snow sql -f assets/lab-infra-setup/00-lab-setup.sql \
    -D "user_name='${USER}'" \
    --role ACCOUNTADMIN
done
```

Or generate batch SQL from existing users (see the batch generator section at the bottom of `00-lab-setup.sql`) and pipe it:

```bash
# 1. Run the batch generator query to produce setup SQL
snow sql -q "SELECT <batch_query_from_script>" --role ACCOUNTADMIN -o output_format=tsv \
  | snow sql --stdin --role ACCOUNTADMIN
```

### Teardown

```bash
# Single user
snow sql -f assets/lab-infra-setup/99-teardown.sql \
  -D "user_name='jmorrison'" \
  --role ACCOUNTADMIN

# Batch teardown
for USER in jmorrison agarcia kwilson; do
  snow sql -f assets/lab-infra-setup/99-teardown.sql \
    -D "user_name='${USER}'" \
    --role ACCOUNTADMIN
done
```

### Running in Snowsight (UI)

1. Open a new SQL worksheet
2. Set role to **ACCOUNTADMIN**
3. Paste the contents of `00-lab-setup.sql`
4. Replace `<username>` with the participant's username
5. Run All

## What Each Participant Gets

After running the setup for a user, their `COCO_CLI_SANDBOX_ROLE_<username>` has:

| Privilege | Purpose |
|-----------|---------|
| CREATE DATABASE ON ACCOUNT | Create LIQUIDITY_RISK_DB_&lt;username&gt; in Exercise 1 |
| CREATE WAREHOUSE ON ACCOUNT | Create additional warehouses if needed |
| SNOWFLAKE.CORTEX_USER database role | Cortex Analyst, semantic views, agents |
| USAGE + MODIFY on SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT | Register agent to CoWork in Exercise 4 |
| USAGE + OPERATE on LIQUIDITY_RISK_WH_&lt;username&gt; | Per-user warehouse for all exercises |

## What Participants Create Themselves (Exercise 1)

- `LIQUIDITY_RISK_DB_<username>` database with schemas: RAW, TRANSFORMED, PRESENTATION, RAW_SANDBOX

## Post-Lab Cleanup

Run `99-teardown.sql` for each participant to drop their database, warehouse, and role.
