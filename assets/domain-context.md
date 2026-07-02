# Domain Context: Basel III Liquidity Coverage Ratio

## What is LCR?

The **Liquidity Coverage Ratio (LCR)** is a Basel III regulatory requirement that ensures banks maintain sufficient High-Quality Liquid Assets (HQLA) to survive a 30-day stress scenario.

```
LCR = HQLA / Total Net Cash Outflows (over 30 days)
```

**Regulatory minimum: 100%** -- banks must hold at least enough liquid assets to cover 30 days of net outflows.

---

## HQLA Classification (Basel III)

| Level | Asset Types | Haircut | Examples |
|-------|------------|---------|----------|
| **Level 1** | Highest quality | 0% | Cash, central bank reserves, sovereign bonds (AA- or better) |
| **Level 2A** | High quality | 15% | Corporate bonds (AA- or better), covered bonds (AA- or better) |
| **Level 2B** | Moderate quality | 25-50% | Corporate bonds (BBB- to A+), equities in major indices, residential MBS |

**Composition limits:**
- Level 2 assets cap: 40% of total HQLA
- Level 2B assets cap: 15% of total HQLA

---

## Data Model

The solution uses the following data structure:

### Reference Tables (RAW schema)

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `ASSET_CLASSIFICATIONS` | Basel III HQLA level mappings | SECURITY_TYPE, HQLA_LEVEL, HAIRCUT_PERCENT |
| `BUSINESS_UNIT_REFERENCE` | Business unit hierarchy | BUSINESS_UNIT_ID, BUSINESS_UNIT_NAME, REGION |
| `COUNTERPARTY_DATA` | Counterparty information | COUNTERPARTY_ID, COUNTERPARTY_NAME, COUNTERPARTY_TYPE, REGION |
| `CURRENCY_REFERENCE` | Currency exchange rates | CURRENCY_CODE, EXCHANGE_RATE_TO_USD |
| `STRESS_SCENARIOS` | Predefined stress parameters | SCENARIO_ID, SCENARIO_NAME, STRESS_FACTOR |
| `WHAT_IF_DEFINITIONS_LOOKUP` | What-if scenario configurations | WHAT_IF_ID, WHAT_IF_NAME, REF_TBL, COL, VAL, FACTOR |

### Fact Tables (RAW schema)

| Table | Purpose | Key Columns | Approximate Size |
|-------|---------|-------------|------------------|
| `POSITIONS` | Investment positions for HQLA | POSITION_ID, BUSINESS_UNIT_ID, SECURITY_TYPE, POSITION_VALUE_USD, MATURITY_DATE | 10,000+ rows |
| `CASH_INFLOWS` | Expected cash receipts | INFLOW_ID, BUSINESS_UNIT_ID, COUNTERPARTY_ID, INFLOW_AMOUNT_USD, MATURITY_DATE | 10,000+ rows |
| `CASH_OUTFLOWS` | Expected cash payments | OUTFLOW_ID, BUSINESS_UNIT_ID, COUNTERPARTY_ID, OUTFLOW_AMOUNT_USD, MATURITY_DATE | 10,000+ rows |

### Output Tables (PRESENTATION schema)

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `LCR` | Production LCR forecast (150 days) | DAY_NUMBER, HQLA, TOTAL_NET_CASH_OUTFLOWS, LCR, CREATED_TIMESTAMP |
| `WHAT_IF_LCR` | Scenario-adjusted LCR results | WHAT_IF_ID, DAY_NUMBER, HQLA, TOTAL_NET_CASH_OUTFLOWS, LCR, CREATED_TIMESTAMP |

### Sandbox Tables (RAW_SANDBOX schema)

Clones of RAW tables used for what-if scenario isolation. The what-if process:
1. Clones base tables into sandbox
2. Applies multiplicative stress factors to amounts
3. Runs LCR calculation on stressed data
4. Writes results to WHAT_IF_LCR

---

## LCR Calculation Pipeline

### Notebook 1: `LIQUIDITY_FORECAST`

Computes the production LCR forecast over 150 days:

1. **HQLA Projection** (`run_hqla_projection`)
   - Starts from current positions
   - Applies Basel III haircuts by asset classification level
   - Projects value decay as positions mature over time
   - Zeroes out positions past their maturity date

2. **HQLA Summary** (`run_summary_hqla`)
   - Aggregates HQLA projections into daily totals
   - Unpivots from wide to long format

3. **Cashflow Projection** (`run_cashflow_projection`)
   - Projects inflows and outflows over N days
   - Filters out matured instruments

4. **Netting** (`run_netting`)
   - Combines inflows and outflows into net cash positions per day
   - Computes 30-day rolling net cash outflow

5. **LCR Calculation**
   - Final ratio: HQLA / Total Net Cash Outflows
   - Writes 150-day forecast to PRESENTATION.LCR

### Notebook 2: `LIQUIDITY_WHAT_IF_FORECAST_SANDBOX`

Computes scenario-adjusted LCR:

1. **Clone & Update** (`clone_and_update`)
   - Reads WHAT_IF_DEFINITIONS_LOOKUP for the given scenario ID
   - Builds multiplicative factor queries matching on region, business unit, counterparty type, or security type
   - Applies factors via MERGE to sandbox tables

2. **Run LCR Calculation** (same pipeline as above, but on sandbox data)

3. **Write Results** to WHAT_IF_LCR with the scenario ID

---

## Stored Procedure Pattern: Custom Agent Tools

The key innovation in this solution is wrapping notebook execution into stored procedures that a Cortex Agent can invoke as custom tools.

### Why?

- Cortex Agents can have multiple tools: text-to-SQL (query) AND stored procedures (action)
- The agent's orchestration logic decides which tool to use based on user intent
- This transforms the agent from read-only to action-capable

### Procedure 1: `RUN_LCR_FORECAST()`

- No parameters
- Executes the LIQUIDITY_FORECAST notebook with production tables
- Returns success message
- Agent invokes when user says: "recalculate LCR", "refresh the forecast", "run the pipeline"

### Procedure 2: `RUN_WHAT_IF_SCENARIO(WHAT_IF_ID VARCHAR)`

- Takes a scenario ID parameter
- Executes the LIQUIDITY_WHAT_IF_FORECAST_SANDBOX notebook
- Generates random sandbox suffix for isolation
- Returns success message with scenario details
- Agent invokes when user says: "run what-if scenario 2", "stress test Asian outflows", "run a scenario"

---

## What-If Scenarios Available

| ID | Name | Description |
|----|------|-------------|
| 1 | Market Stress | Broad market downturn affecting all asset values |
| 2 | Asia Outflow Spike | 30% increase in Asian treasury outflows |
| 3 | Counterparty Default | Major bank counterparty fails, reducing inflows |
| 4 | Regulatory Tightening | Increased haircuts on Level 2B assets |
| 5 | Combined Stress | Multiple simultaneous stress factors |

---

## Key Metrics Executives Ask About

- **LCR Today:** Current ratio (should be > 1.0 / 100%)
- **LCR Headroom:** How far above the 100% floor
- **LCR Trend:** 30/60/90/150-day forecast direction
- **HQLA Composition:** Breakdown by Level 1/2A/2B
- **Net Cash Outflows:** Total expected outflows over 30 days
- **Business Unit Breakdown:** Which unit contributes most to outflows
- **Counterparty Concentration:** Largest counterparty exposures
- **What-If Impact:** How scenarios change the LCR curve

---

## Success Criteria from James Morrison

> "I want one interface where I can ask questions AND trigger recalculations. No more waiting 2 days for a number, no more waiting 2 weeks for a stress test. I ask, it happens."

The prototype must demonstrate:
1. Natural language query answering in under 10 seconds
2. LCR recalculation triggered by a chat message
3. What-if scenario execution triggered by a chat message
4. Results displayed immediately after computation completes
5. All accessible through Snowflake Intelligence (CoWork)
