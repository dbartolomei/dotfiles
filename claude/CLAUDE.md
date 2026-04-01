# System-Wide Claude Code Instructions

## Date Handling

**CRITICAL: Always verify current date/time before using it.**

Before generating any code, documentation, or output that includes dates, times, or timestamps:

1. **Always run `date` command first** to verify current system date/time
2. **Show the verified date** in your response when relevant
3. **Use timezone-aware commands** when needed for specific timezones

### Examples:

```bash
# Verify current date/time
date

# Get formatted date
date '+%Y-%m-%d %H:%M:%S'

# Specific timezone (example: Puerto Rico)
TZ=America/Puerto_Rico date
```

### When to check:
- Timestamps in code
- Date calculations
- Scheduled tasks
- Time-based logic
- Copyright years
- Version dates
- Log entries
- Any date-related output

## Git Commits

- **NEVER add `Co-Authored-By` lines to commit messages.** No credit attribution for AI assistance.

---

*This file applies to all projects. Project-specific CLAUDE.md files will override these rules when needed.*
