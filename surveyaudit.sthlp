{smcl}
{* *! version 2.2.0  10Nov2026}{hline}
{help manpage:surveyaudit} — Automated master pipeline execution and log-auditing toolkit for Stata

{marker syntax}{title:Syntax}

{p 8 17 2}
{cmd:surveyaudit} [{cmd:,} {opt rootpath(string)} {opt dopath(string)} {opt logpath(string)} {opt docpath(string)} {opt update}]


{marker description}{title:Description}

{pstd}
{cmd:surveyaudit} is a production-grade toolbox designed to automate the execution, error tracking, and auditing of multi-stage Stata do-file pipelines. It is tailored specifically for complex household and socio-economic survey processing (such as KIHBS, LSMS, and DHS) where pipelines span dozens of sequential data cleaning, transformation, and merging modules.

{pstd}
In traditional master scripts, a single syntax error, memory constraint violation, or wide-format merge mismatch in an individual section script halts the entire multi-hour run. {cmd:surveyaudit} introduces software-engineering CI/CD practices—including fault-tolerant execution trapping, low-level log parsing via native text streams, and dynamic Markdown executive report generation—directly into Stata environments.


{marker options}{title:Options}

{phang}
{opt rootpath(string)} specifies the root folder path of the survey project. When provided, the command automatically resolves dependent directories and executes {cmd:init.do} to configure environment globals.

{phang}
{opt dopath(string)} explicitly overrides and specifies the directory path containing your individual section do-files.

{phang}
{opt logpath(string)} explicitly specifies the directory path where execution log files are written and captured.

{phang}
{opt docpath(string)} explicitly specifies the directory path where individual error reports and the master Markdown status report are saved.

{phang}
{opt update} queries the GitHub repository for the latest version, compares it against the locally installed version, and automatically updates the package if a newer release is available.


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
{cmd:. surveyaudit, update}

{pstd}
The command sequentially loops through your configured queue of section do-files. Successful modules complete cleanly, while failing scripts automatically capture their return codes ({cmd:_rc}) without halting the execution loop. For any failing script, native low-level file commands scan the corresponding log file, extract the final 25 lines of failure context, and compile an independent Markdown diagnostic report.

{pstd}
Finally, all module execution statuses, error traces, and wide-format merge summaries are consolidated into a single master executive audit report ({cmd:00_Do_Files_Submission_Status_Report.md}) for rapid review and debugging.


{marker technical}{title:Technical Architecture & Low-Level Operations}

{pstd}
Unlike standard statistical scripts, {cmd:surveyaudit} leverages advanced Stata programming features:
* {bf:Error Isolation:} Utilizes {cmd:capture noisily do} to isolate script-level failures, ensuring return codes are safely intercepted.
* {bf:File I/O Stream Manipulation:} Uses native {cmd:file open}, {cmd:file read}, and {cmd:file write} commands to inspect plaintext log files line-by-line, avoiding memory overflow issues when processing massive execution logs.
* {bf:Merge Tracking Hooks:} Dynamically captures household and household-member merge output statistics and injects them directly into markdown summaries.


{marker remarks}{title:Remarks}

{pstd}
1. {bf:Folder Structure:} A clean, structured directory layout (separating do-files, logs, raw data, and documentation reports) is recommended to maximize the automation and auditing features of this toolkit.

{pstd}
2. {bf:Active Development & Feedback:} As an open-source tool for applied quantitative researchers, feedback, bug reports, and suggestions for feature enhancements are always welcome.


{marker citation}{title:Citation}

{pstd}
If you utilize this software package in your research or institutional data production pipeline, please cite it accordingly:

{phang}
Magara, G. 2026. {it:surveyaudit: Automated master pipeline execution and log-auditing toolkit for Stata}. GitHub Repository / Open-Source Utility.


{marker author}{title:Author}

{pstd}
George Magara{break}
Kenya National Bureau of Statistics (KNBS) / Independent Quantitative Data Architect{break}
Please report bugs, issues, and feature requests via your repository issue tracker or project support channels.


{marker also_see}{title:Also see}

{pstd}
Manual:  {hi:[P] capture}, {hi:[P] file}, {hi:[R] log}, {hi:[P] version}
{p_end}
