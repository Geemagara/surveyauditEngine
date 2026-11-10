{smcl}
{* *! version 2.1.0  09Nov2026}{hline}
{help manpage:surveyaudit} — Automated master pipeline execution and log-auditing toolkit for Stata

{marker syntax}{title:Syntax}

{p 8 17 2}
{cmd:surveyaudit} [{cmd:,} {opt rootpath(string)}]


{marker description}{title:Description}

{pstd}
{cmd:surveyaudit} is a production-grade toolbox designed to automate the execution, error tracking, and auditing of multi-stage Stata do-file pipelines, tailored for complex household and socio-economic survey processing (such as KIHBS, LSMS, DHS).

{pstd}
In traditional master scripts, a single syntax error, memory restriction, or merge mismatch in an individual section script halts the entire multi-hour run. {cmd:surveyaudit} introduces software-engineering CI/CD practices—including fault-tolerant execution trapping, low-level log parsing, and dynamic Markdown executive report generation—directly into Stata environments.


{marker options}{title:Options}

{phang}
{opt rootpath(string)} specifies the root folder path of the survey project. When provided, the command automatically resolves dependent paths and executes {cmd:init.do}.


{marker workflow}{title:Workflow}

{pstd}
The generic workflow for executing a survey processing pipeline using {cmd:surveyaudit} is as follows:

{phang}
1. Run initialization or pass rootpath:{p_end}
{p 8 12 2}
{cmd:. surveyaudit, rootpath("C:\KNBS\KIHBS_2025_26")}

{pstd}
The command sequentially loops through your configured queue of section do-files, logs return codes, extracts error tails, and compiles a master executive audit report ({cmd:00_Do_Files_Submission_Status_Report.md}).


{marker author}{title:Author}

{pstd}
George Magara{break}
Kenya National Bureau of Statistics (KNBS)
{p_end}
