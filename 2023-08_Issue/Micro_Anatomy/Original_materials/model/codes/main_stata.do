**********************************************************************
* Guntin, Ottonello and Perez (2022)
* This codes runs all the .do files of the paper related to the 
* model section

* Computes moments used for calibration and model exercises
* Output: Excel files in '/model/input' folder

**********************************************************************

cls
clear all
set mem 200m
set more off

ssc install ginidesc, replace
ssc install fastxtile, replace

global user = "/Users/rafaelguntin/Dropbox/papers/GuOP_consumption/replication_files_revision" /* change this to run all the code */

******** Empirical Moments for Model Calibration and Exercises ********

* Italy calibration
do $user/model/codes/data_moments/ITA_calibration_moments.do

* Mexico calibration
do $user/model/codes/data_moments/MEX_calibration_moments.do

* Model exercise moments
do $user/model/codes/data_moments/moments_exercise.do
