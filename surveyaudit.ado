*! version 2.3.0  10Nov2026
*! Harmonized with KIHBS 2025/26 init.do framework & robust subcommand update
program define surveyaudit
    version 18
    
    * --- ROBUST SUBCOMMAND / OPTION UPDATE CHECK ---
    * Support both "surveyaudit update" (no comma) and "surveyaudit, update" (with comma)
    gettoken subarg rest : 0, parse(" ,")
    if "`subarg'" == "update" {
        local do_update = 1
    }
    else {
        * Check if update option is passed after comma
        local do_update = 0
        capture syntax, [ rootpath(string) dopath(string) logpath(string) docpath(string) update ]
        if "`update'" != "" {
            local do_update = 1
        }
    }

    if `do_update' {
        di as text "========================================================="
        di as text "CHECKING FOR SURVEYAUDIT UPDATES FROM GITHUB..."
        di as text "========================================================="
        
        * 1. Get local version from installed surveyaudit.ado
        capture findfile surveyaudit.ado
        if _rc != 0 {
            di as error "Could not locate local installation of surveyaudit.ado."
            exit 601
        }
        local local_ado_path "`r(fn)'"
        
        local local_ver = ""
        file open fh using "`local_ado_path'", read
        file read fh line
        * Read first few lines to find version tag
        forvalues k = 1/5 {
            if strpos("`line'", "*! version") {
                local local_ver = trim(subinstr("`line'", "*! version", "", .))
                continue, break
            }
            file read fh line
        }
        file close fh
        
        di as text "Locally installed version tag: `local_ver'"
        
        * 2. Download remote version file from GitHub
        local remote_ver_url "https://raw.githubusercontent.com/Geemagara/surveyauditEngine/main/version.txt"
        local temp_ver_file "`c(tmpdir)/remote_version.txt'"
        
        capture copy "`remote_ver_url'" "`temp_ver_file'", replace
        if _rc != 0 {
            di as error "Failed to connect to GitHub repository to check for updates. Check your internet connection."
            exit 601
        }
        
        * 3. Read remote version
        file open rfh using "`temp_ver_file'", read
        file read rfh remote_ver
        file close rfh
        local remote_ver = trim("`remote_ver'")
        
        di as text "Latest remote version on GitHub: `remote_ver'"
        
        * 4. Compare and update if newer
        if "`local_ver'" != "`remote_ver'" {
            di as result "New version available (`remote_ver'). Updating package..."
            capture net from "https://raw.githubusercontent.com/Geemagara/surveyauditEngine/main/"
            capture net install surveyaudit, replace
            if _rc == 0 {
                di as result "========================================================="
                di as result "UPDATE SUCCESSFUL! surveyaudit is now at version `remote_ver'."
                di as result "========================================================="
            }
            else {
                di as error "Update installation failed. Please check network permissions."
                exit _rc
            }
        }
        else {
            di as result "surveyaudit is already up to date (version `local_ver')."
        }
        capture erase "`temp_ver_file'"
        exit 0
    }

    * Re-parse standard pipeline execution syntax
    syntax, [ rootpath(string) dopath(string) logpath(string) docpath(string) update ]

    di as text "========================================================="
    di as text "STARTING STATA-SURVEYAUDITENGINE PIPELINE"
    di as text "========================================================="

    * 1. Check if project environment is initialized (globals from init.do)
    if "$gsdDo" == "" {
        if "`rootpath'" != "" {
            di as text "Initializing project environment from: `rootpath'/Do/init.do"
            capture do "`rootpath'/Do/init.do"
            if _rc != 0 {
                di as error "Failed to execute init.do at `rootpath'/Do/init.do. Please check path or run init.do manually."
                exit 601
            }
        }
        else {
            * Try running init.do from standard working directory path
            capture do "Do/init.do"
            if _rc != 0 {
                capture do "init.do"
            }
            if "$gsdDo" == "" {
                di as error "Project globals (e.g., $gsdDo) are not defined. Please run init.do first or pass rootpath("...")."
                exit 198
            }
        }
    }

    * Override paths if explicit options are provided
    if "`dopath'" != "" {
        global gsdDo "`dopath'"
    }
    if "`logpath'" != "" {
        global gsdLog "`logpath'"
    }
    if "`docpath'" != "" {
        global gsdDocs "`docpath'"
    }

    * Ensure maxvar is set for wide survey merges
    set maxvar 32767
    set more off

    * Define master submission status report path using init.do global
    local summary_md "${gsdDocs}/00_Do_Files_Submission_Status_Report.md"

    * Initialize status report with description
    capture mkdir "${gsdDocs}"
    file open sum_fh using "`summary_md'", write replace
    file write sum_fh "# Do Files Submission Status Report" _n _n
    file write sum_fh "This automated audit pipeline sequentially executes all section do-files, ensuring a single script failure won't crash the entire run. Successful modules complete cleanly without generating redundant error files, while failing scripts automatically log their return codes and the final 25 lines of failed code. Crucially, the pipeline also tracks and captures a detailed summary of successfully merged versus missing household and household-member sections from the merging task. Everything is then consolidated into a single 00_Do_Files_Submission_Status_Report.md for rapid review and debugging." _n _n
    file write sum_fh "---" _n _n
    file close sum_fh

    * 2. Define your full pipeline do-files queue
    local dofiles ///
        01_Cover_Page ///
        02_anonymize ///
        03-1_sections_splitting ///
        05-1_Section_B1_HhmRosterDemographics ///
        05-3_Section_B3_Emigration ///
        05-4_Section_C_Education ///
        05-5_Section_D1_Labour ///
        05-6_Section_D2_LabourB4Displacement ///
        05-7_Section_E1_HealthCare&Insurance ///
        05-8_Section_E2_Disability ///
        05-9_Section_E2R_Fertility ///
        05-10_Section_E3_Births&Deaths ///
        05-11_Section_F_Anthropometry ///
        05-11_Section_F_Anthropometry_BMI_5-19 ///
        05-11_Section_F_Anthropometry_BMI_Adult ///
        05-12_Section_G_ICT_hhm ///
        05-13_Section_H_DomesticTourism ///
        05-14_Section_I_CreditLoansFinInclusion ///
        05-15_Section_SC_SocialCohesion ///
        05-16_Section_MH_MentalHealth ///
        05-17_Section_J_Housing ///
        05-18_Section_K_WaterSanitation ///
        05-19_Section_L_EnergyUse ///
        05-19_Section_L_EnergyUse_Tabulations ///
        05-20_Section_M_Agriculture ///
        05-21_Section_N_Livestock ///
        05_SectionMN_AgricultureC_Tabulations ///
        05-22_Section_O_Hh_Enterprise ///
        05-23_Section_P_Transfers ///
        05-24_Section_Q_SocialProtection ///
        05-25_Section_R_RecentShocks ///
        05-26_Section_S_FoodSecurity ///
        05-27_Section_T_Hh_Justice ///
        05-28_Section_U_Hh_ICT ///
        05-29_Section_NRM_NaturalResourceMgt ///
        03-2_sections_Merging

    * 3. Loop through, execute safely without halting, and generate reports
    local i = 0
    foreach f of local dofiles {
        local ++i
        di as text "---------------------------------------------------------"
        di as text "Running: `f'.do ..."
        
        * Capture full log cleanly using gsdLog global from init.do
        local log_file "${gsdLog}/`f'.log"
        capture log close log_`i'
        log using "`log_file'", replace name(log_`i') text
        
        * Execute the do-file safely (capturing any error code without crashing the loop)
        capture noisily do "${gsdDo}/`f'.do"
        local rc = _rc
        
        capture log close log_`i'
        
        * Define individual AI-ready Markdown report path using gsdDocs global
        local md_file "${gsdDocs}/`f'_Error_Report.md"
        
        * Wrap report generation in capture to ensure loop resilience
        capture noisily {
            * ONLY generate individual error report if the script actually failed
            if `rc' != 0 {
                file open fh using "`md_file'", write replace
                
                file write fh "# AI Auditor Diagnostic Report: `f'.do" _n _n
                file write fh "## Execution Metadata" _n
                file write fh "* **Target Script:** `f'.do" _n
                file write fh "* **Return Code (_rc):** `rc'" _n
                file write fh "* **Status:** FAILED / HALTED" _n _n
                
                file write fh "## Captured Issues & Error Summary" _n
                file write fh "* **Primary Return Code Triggered:** r(`rc')" _n
                file write fh "* **Captured Log Tail / Failure Context:**" _n
                file write fh "```text" _n
                
                * Ensure logs are closed to release file locks
                capture log close _all
                
                * Read log file and extract final 25 lines
                capture file open read_fh using "`log_file'", read
                if _rc == 0 {
                    local total_lines = 0
                    file read read_fh line
                    while r(eof) == 0 {
                        local ++total_lines
                        file read read_fh line
                    }
                    file close read_fh
                    
                    capture file open read_fh using "`log_file'", read
                    if _rc == 0 {
                        local current = 0
                        file read read_fh line
                        while r(eof) == 0 {
                            local ++current
                            if `current' >= (`total_lines' - 25) {
                                file write fh `"`line'"' _n
                            }
                            file read read_fh line
                        }
                        file close read_fh
                    }
                }
                file write fh "```" _n
                file close fh
            }
            
            * Appending module status to master status report
            file open sum_fh using "`summary_md'", write append
            file write sum_fh "## Module `i`: `f'.do" _n
            file write sum_fh "* **Return Code (_rc):** `rc'" _n
            if `rc' == 0 {
                file write sum_fh "* **Status:** SUCCESS" _n _n
                
                * Special hook: If this is the merging module, embed the structured merge summary table
                if "`f'" == "03-2_sections_Merging" {
                    capture confirm file "${gsdDocs}/_merge_summary_capture.txt"
                    if _rc == 0 {
                        file write sum_fh "* **Merging Summary:**" _n
                        tempfile merge_temp
                        * Read and inject the captured merge summary file
                        capture file open read_merge using "${gsdDocs}/_merge_summary_capture.txt", read
                        if _rc == 0 {
                            file read read_merge merge_line
                            while r(eof) == 0 {
                                file write sum_fh "`merge_line'" _n
                                file read read_merge merge_line
                            }
                            file close read_merge
                        }
                        file write sum_fh _n
                    }
                }
            }
            else {
                file write sum_fh "* **Status:** FAILED / HALTED" _n
                file write sum_fh "* **Primary Error:** r(`rc')" _n
                file write sum_fh "* **Error Trace Log:**" _n
                file write sum_fh "```text" _n
                
                capture file open read_fh using "`log_file'", read
                if _rc == 0 {
                    local total_lines = 0
                    file read read_fh line
                    while r(eof) == 0 {
                        local ++total_lines
                        file read read_fh line
                    }
                    file close read_fh
                    
                    capture file open read_fh using "`log_file'", read
                    if _rc == 0 {
                        local current = 0
                        file read read_fh line
                        while r(eof) == 0 {
                            local ++current
                            if `current' >= (`total_lines' - 25) {
                                file write sum_fh `"`line'"' _n
                            }
                            file read read_fh line
                        }
                        file close read_fh
                    }
                }
                file write sum_fh "```" _n _n
            }
            file write sum_fh "---" _n _n
            file close sum_fh
        }
        
        if `rc' != 0 {
            di as error "  [FAILED] `f'.do completed with return code `rc'. Error report generated."
        }
        else {
            di as result "  [SUCCESS] `f'.do completed cleanly."
        }
    }

    di as text "========================================================="
    di as text "PIPELINE COMPLETE."
    di as text "STATUS REPORT SAVED TO: ${gsdDocs}/00_Do_Files_Submission_Status_Report.md"
    di as text "========================================================="
end
