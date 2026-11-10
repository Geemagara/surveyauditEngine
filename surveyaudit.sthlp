{smcl}
{* *! version 2.3.0  10Nov2026}{hline}
{help manpage:surveyaudit} — Automated master pipeline execution and log-auditing toolkit for Stata

{marker syntax}{title:Syntax}

{p 8 17 2}
{cmd:surveyaudit} [{it:update}] [{cmd:,} {opt rootpath(string)} {opt dopath(string)} {opt logpath(string)} {opt docpath(string)} {opt update}]


{marker description}{title:Description}

{pstd}
{cmd:surveyaudit} is a production-grade toolbox designed to automate the execution, error tracking, and auditing of multi-stage Stata do-file pipelines. It is tailored specifically for complex household and socio-economic survey processing (such as KIHBS, LSMS, and DHS) where pipelines span dozens of sequential data cleaning, transformation, and merging modules.

{pstd}
In traditional master scripts, a single syntax error, memory constraint violation, or wide-format merge mismatch in an individual section script halts the entire multi-hour run. {cmd:surveyaudit} introduces software-engineering CI/CD practices—including fault-tolerant execution trapping, low-level log parsing via native text streams, and dynamic Markdown executive report generation—directly into Stata environments.


{marker options}{title:Options & Subcommands}

{phang}
{opt update} (used as {cmd:surveyaudit update} or {cmd:surveyaudit, update}) queries the GitHub repository for the latest version, compares it against the locally installed version, and automatically updates the package if a newer release is available.

{phang}
{opt rootpath(string)} specifies the root folder path of the survey project. When provided, the command automatically resolves dependent directories and executes {cmd:init.do} to configure environment globals.

{phang}
{opt dopath(string)} explicitly overrides and specifies the directory path containing your individual section do-files.

{phang}
{opt logpath(string)} explicitly specifies the directory path where execution log files are written and captured.

{phang}
{opt docpath(string)} explicitly specifies the directory path where individual error reports and the master Markdown status report are saved.


{marker workflow}{title:Workflow}

{pstd}
The generic workflow for executing a survey processing pipeline using {cmd:surveyaudit} is as follows:

{phang}
1. Initialize your project root path or run your setup script.{p_end}
{phang}
2. Execute the complete multi-module audit pipeline with a single command:{p_end}
{p 8 12 2}
{cmd:. surveyaudit, rootpath("C:\KNBS\KIHBS_2025_26")}

{pstd}
To check for and install updates automatically from GitHub:
{p 8 12 2}
{cmd:. surveyaudit update}


{marker author}{title:Author}

{pstd}
George Magara{break}
Kenya National Bureau of Statistics (KNBS) / Independent Quantitative Data Architect
{p_end}
