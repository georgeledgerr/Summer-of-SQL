# Summer of SQL

Worked solutions and notes for the **Summer of SQL** 13-week challenge series, written in **Snowflake SQL**.

## The 13 weeks

| Week | Focus | Status |
|------|-------|--------|
| [01](Week-01) | SQL Murder Mystery | Complete |
| [02](Week-02) | Preppin' Data 2023, Weeks 1-4 | Complete |
| [03](Week-03) | Data with Danny: Foodie-Fi, Sections A & B | Not started |
| [04](Week-04) | Preppin' Data 2023, Weeks 5-8 | Not started |
| [05](Week-05) | Lego Creator: SQL portfolio project | Not started |
| [06](Week-06) | Data with Danny: Data Bank, Section A | Not started |
| [07](Week-07) | Preppin' Data 2023, Weeks 9-12 | Not started |
| [08](Week-08) | Data with Danny: Data Bank, Section B | Not started |
| [09](Week-09) | SQL Olympics: portfolio project | Not started |
| [10](Week-10) | SQL Olympics: dashboard build | Not started |
| [11](Week-11) | Preppin' Data 2023, Weeks 13-16 | Not started |
| [12](Week-12) | Data with Danny: Data Bank, Section C | Not started |
| [13](Week-13) | SQL portfolio project + dashboard build | Not started |

Detailed status per challenge lives in each week's README.

## Structure

Each week is a folder with a `README.md` (that week's challenges and status), and a `solutions/` folder holding one `.sql` file per challenge. A `notes.md` of takeaways is added as each week is completed.

```
Week-XX/
├── README.md
└── solutions/
    ├── challenge-01-<short-name>.sql
    └── challenge-02-<short-name>.sql
```

Every solution file opens with a standard header (challenge, link, date, what it tests) followed by a short note on the approach. Templates are in [_templates](_templates).

## Conventions

- Snowflake dialect throughout: `QUALIFY`, `IFF`, `LISTAGG`, `DATEDIFF`, and friends.
- Uppercase keywords, one consistent comma style per file.
- No datasets committed, only SQL and notes.
