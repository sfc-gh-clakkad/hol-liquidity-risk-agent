# Company Background: GlobalBank Treasury Risk

## About Your Company

**GlobalBank** is a large commercial bank with a significant treasury operation managing liquidity positions across multiple geographies and business units. Your Treasury Risk team is responsible for ensuring compliance with Basel III liquidity regulations.

### Key Business Metrics

| Metric | Value |
|--------|-------|
| **Total Assets** | $150B |
| **Liquid Asset Buffer (HQLA)** | $30B |
| **Daily Cash Flows** | $2-5B in/out |
| **Business Units** | US Treasury, EU Treasury, Asia Treasury, Global Trading |
| **Employees** | 5,000+ total; Treasury Risk team: 20 analysts |
| **Regulatory Framework** | Basel III (LCR minimum: 100%) |
| **Counterparties** | 2,000+ across Bank, Corporate, Sovereign, Institutional |

---

## Current Technical Environment

### Data Infrastructure

| Component | Technology | Notes |
|-----------|------------|-------|
| Risk Systems | Legacy in-house platform | Batch processing, overnight runs |
| Position Management | Internal systems + Bloomberg | Real-time feeds, but no integrated analytics |
| LCR Calculation | Excel + VBA macros | Manual, error-prone, 2-day lag |
| Reporting | Static PDF reports | Generated weekly by quant team |
| What-If Analysis | Separate request to quant team | Takes 2-4 weeks per scenario |
| Data Warehouse | Oracle + Teradata | Fragmented, no single source of truth |

### Pain Points You've Identified

1. **LCR reporting lag:** Calculations take 2 business days due to manual Excel processes
2. **No real-time visibility:** Executives cannot see current liquidity position on demand
3. **What-if bottleneck:** Stress scenarios require a separate team and take weeks to complete
4. **Ad-hoc questions:** James asks liquidity questions that take days for analysts to answer manually
5. **Fragmented data:** Position data, cash flows, and market data live in separate systems
6. **Audit concerns:** Excel-based calculations are difficult to audit and reproduce

---

## POC Requirements from Leadership

### Must Have (P0)

- [ ] Real-time LCR calculation (current ratio, 30/60/90/150-day forecast)
- [ ] Natural language queries for executives ("What is our LCR today?")
- [ ] Ability to trigger LCR recalculation via chat interface
- [ ] What-if scenario execution through natural language
- [ ] Basel III compliant HQLA classification (Level 1, 2A, 2B with haircuts)

### Should Have (P1)

- [ ] Multi-business-unit breakdown (US/EU/Asia Treasury)
- [ ] Counterparty concentration analysis
- [ ] Historical LCR trend analysis
- [ ] Self-service experience in Snowflake Intelligence (CoWork)

### Nice to Have (P2)

- [ ] Streamlit operational dashboard
- [ ] Custom stress scenario definition
- [ ] Automated regulatory report generation

---

## Key Stakeholders You'll Present To

### Executive Sponsor

**James Morrison, Head of Treasury Risk**
- 25 years in banking, former trader turned risk manager
- Frustrated by the 2-day lag in LCR reporting
- Wants to ask questions AND trigger actions in one interface
- *"I want to say 'recalculate LCR' and have it happen instantly"*
- *"Show me what happens if Asian outflows spike 30% -- right now, not in two weeks"*

### Regulatory Lead

**Priya Sharma, Regulatory Reporting Lead**
- Responsible for Basel III compliance reporting to regulators
- Needs calculation accuracy with full audit trail
- Wants consistent, reproducible LCR numbers
- *"If the regulator asks how we got this number, I need to trace every step"*
- *"The HQLA haircuts must match Basel III exactly -- Level 1 at 0%, Level 2A at 15%, Level 2B at 25-50%"*

### Technical Stakeholder

**Tom Nguyen, VP Treasury Operations**
- Owns data infrastructure and operational processes
- Wants to understand data lineage and computation logic
- Concerned about reliability and failover
- *"Show me the SQL. I need to know what the AI is actually doing"*
- *"How does the what-if scenario isolate from production data?"*

### Your Team

**4 Risk Analysts** in Treasury Risk
- Quantitative backgrounds, strong in Excel and Python
- Currently spend 60% of time on data gathering and reconciliation
- Want to focus on analysis rather than data plumbing
- Skeptical that AI can handle regulatory-grade calculations

---

## Success Criteria

James defined these during your requirements meeting:

| Criterion | Target |
|-----------|--------|
| **LCR Query Response** | Under 10 seconds |
| **Recalculation Trigger** | Under 5 minutes via chat |
| **What-If Execution** | Under 5 minutes via chat |
| **Accuracy** | Matches manual Excel within 0.1% |
| **Self-Service** | No SQL or technical knowledge required |
| **Audit Trail** | Full lineage from raw data to final LCR |

---

## Why Snowflake + Cortex Code?

You've been evaluating platforms and see potential in:
- **Snowflake Notebooks** - Scalable LCR computation replacing Excel/VBA
- **Cortex Analyst + Semantic Views** - Natural language queries over structured data
- **Cortex Agents with Custom Tools** - Combined query AND action capabilities
- **Snowflake Intelligence (CoWork)** - Executive self-service chat interface
- **Stored Procedures as Tools** - Wrap notebook execution for agent invocation

Your job is to prove this can work for GlobalBank's Treasury Risk team.
