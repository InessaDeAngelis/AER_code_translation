********************************************************************************

	* MASTER REPLICATION FILE FOR "Worth Your Weight" (Macchi)
	* Last updated: March 25 2023 
	* EM
	
********************************************************************************

/*  This do file contains code that does the following input for replicating all figures and tables in "Worth your Weight" (Macchi): 
	Step 1: installs STATA packages 
	Step 2: generates the data sets used 
	Step 3: replicates all the main figures 
	Step 4: replicates all the main tables
	Step 5: replicates the appendix figures 
	Step 6: replicates the appendix tables 

*/

* Note for replicator: Running the do-file, after editing line 40 and 48, 
* reproduces all the figures and the tables in WYW, except Figure 1.


* To reproduce Figure 1, follow these steps:
**** 1) Download the DHS data as per the instructions in the README file.
**** 2) Place the data in a folder that can be accessed by the code.
**** 3) Update the path to the data file at line 76 of this do-file.
**** 4) Uncomment lines 76 and 77
**** 5) Open do file located at ./code/wyw_figures.do and uncomment lines 15 to 93
**** 6) Run do file

********************************************************************************

	clear all 
	set more off 
	set seed 1234	
	
	
	* Step 0: set up ado file for randomization inference
	
	* Set directory for data and code 
	foreach path in "/Users/emacch/Dropbox/Projects/WorthYourWeight/data/replication" { // This must be modified by the user to own path
		capture cd "`path'"
		if _rc == 0 macro def path `path'
		} 
	
	cd "$path"
		
	* Set ado path
	adopath + "/Applications/Stata/ado/personal/"   	// This must be modified by the user to own ado path
	log using wyw_replication, replace
	
	* Step 1: Install packages 
		do "./code/install_packages.do"

	* Step 2: Create analysis data
	
		* Beliefs experiment
		do "./code/create_wyw_beliefs.do"
		
		* Credit experiment
		do "./code/create_wyw_credit.do"
		
		* Summary stats database
		do "./code/create_wyw_sumstats.do"
		
		* Credit experiment replication
		do "./code/create_wyw_creditreplication.do"
		
	    * Beliefs accuracy sample
		do "./code/create_wyw_laypeoplesample2.do"
		
		* UNPS data
		do "./code/create_wyw_unps.do"
		
		* DHS data
//		use $path/rawdata-notpublic/IPUMS_DHS_IR_aggregate_2017.dta, clear     // UPDATE PATH NAME TO THE LOCATION OF THE DHS DATA
//		do "./code/create_wyw_dhs.do"
		
		* Malawi data
		do "./code/create_wyw_malawi.do"
		
	* Step 3: Generate main figures 
		do "./code/wyw_figures.do"
		graph close _all

	* Step 4: Generate main tables
		do "./code/wyw_tables.do"

	* Step 5: Generate appendix figures 
	    do "./code/wyw_appendix_figures.do"
		graph close _all

	* Step 6: Generate appendix tables
	    do "./code/wyw_appendix_tables.do"
		
		
	log close
	translate wyw_replication.smcl wyw_replication.pdf
	