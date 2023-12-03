/* Importing train data */
filename mycsv '/home/u63539974/sasuser.v94/DS 6371 - Stats I/Unit 14/train.csv';
proc import datafile=mycsv
            out= train  /* Specify the name of your SAS dataset */
            dbms=csv   /* Specify the file format (CSV) */
            replace;   /* Replace if the dataset already exists */
run;

/* Importing test data */
filename mycsv '/home/u63539974/sasuser.v94/DS 6371 - Stats I/Unit 14/test.csv';
proc import datafile=mycsv
            out= test  /* Specify the name of your SAS dataset */
            dbms=csv   /* Specify the file format (CSV) */
            replace;   /* Replace if the dataset already exists */
run;

/* Printing train */
proc print data = train;
run;

/* Printing test */
proc print data = test;
run;

/* Setting SalePrice to blank for test */
data test;
	set test;
	SalePrice = .;
;

/* Appending train and test */
data train2;
	set train test;
run;

/* Printing train2 (train and test appended) */
proc print data = train2;
run;
/*  Continue everything else you were doing   */



/* Running a MLR for all */
proc glm data = train2 plots = all;
	class RoofStyle  Exterior1st Exterior2nd MasVnrType;
	model SalePrice = RoofStyle Exterior1st Exterior2nd MasVnrType LotArea / cli solution;
	output out = results p = Predict;
run;



/* Handling SalePrice that is negative */
data results2;
	set results;
	if Predict > 0 then SalePrice = Predict;
	if Predict < 0 then SalePrice = 10000;
	keep id SalePrice;
where id > 1460;
;

/* Evaluating the SalePrice */
proc means data = results2;
	var SalePrice;
run;

/* Exporting results */
proc export data=results2
  outfile="/home/u63539974/sasuser.v94/DS 6371 - Stats I/Unit 14/results2.csv"
  dbms=csv
  replace;
run;

/* 1. Simple Linear Regression */

/* Scatter Plot Matrix */
proc sgscatter data=train2;
   	matrix SalePrice MSSubClass LotArea OverallQual OverallCond;
run;

proc sgscatter data=train2;
   	matrix SalePrice YearBuilt YearRemodAdd MasVnrArea BsmtFinSF1;
run;

proc sgscatter data=train2;
   	matrix SalePrice BsmtFinSF2 BsmtUnfSf TotalBsmtSF '1stFlrSF'n '2ndFlrSF'n;
run;

proc sgscatter data=train2;
   	matrix SalePrice LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath ;
run;

proc sgscatter data=train2;
   	matrix SalePrice FullBath HalfBath BedroomAbvGr KitchenAbvGr TotRmsAbvGrd;
run;

proc sgscatter data=train2;
   	matrix SalePrice Fireplaces GarageYrBlt GarageCars GarageArea WoodDeckSF;
run;

proc sgscatter data=train2;
   	matrix SalePrice OpenPorchSF EnclosedPorch '3SsnPorch'n ScreenPorch PoolArea;
run;

proc sgscatter data=train2;
   	matrix SalePrice MiscVal MoSold YrSold;
run;


/* Logging the most promising explanatory variables */
data train2;
set train2;
OverallQual_log = log(OverallQual);
OverallCond_log = log(OverallCond);
TotalBsmtSF_log = log(TotalBsmtSF);
FirstFlrSf_log = log('1stFlrSf'n);
SecondFlrSF_log = log('2ndFlrSf'n);
GrLivArea_log = log(GrLivArea);
FullBath_log = log(FullBath);
TotRmsAbvGrd_log = log(TotRmsAbvGrd);
GarageArea_log = log(GarageArea);
SalePrice_log = log(SalePrice);
run;

/* Regenerating Scatter Plot of Log Transformations */

proc sgscatter data=train2;
   	matrix SalePrice OverallQual_log OverallCond_log TotalBsmtSF_log FirstFlrSf_log SecondFlrSF_log;
run;

proc sgscatter data=train2;
   	matrix SalePrice GrLivArea_log FullBath_log TotRmsAbvGrd_log GarageArea_log;
run;

/* Scatter plots of log-transformed variables with log-transformed SalePrice */
proc sgscatter data=train2;
   	matrix SalePrice_log OverallQual_log OverallCond_log TotalBsmtSF_log FirstFlrSf_log SecondFlrSF_log;
run;

proc sgscatter data=train2;
   	matrix SalePrice_log GrLivArea_log FullBath_log TotRmsAbvGrd_log GarageArea_log;
run;

/* Building Simple Linear Regression Model of visually correllated log-transformed explanatory and log-transformed dependent variabe SalePrice */
proc glm data = train2 plots = all;
	model SalePrice_log = GrLivArea_Log / cli solution;
run;

proc glmselect data=train2;
  model SalePrice_log = GrLivArea_Log / selection=Stepwise(stop=CV) cvmethod = random(5) stats = adjrsq;
run;


proc glm data = train2 plots = all;
	model SalePrice_log = FirstFlrSF_log / cli solution;
run;

proc glm data = train2 plots = all;
	model SalePrice_log = TotalBsmtSF_log / cli solution;
run;

proc glm data = train2 plots = all;
	model SalePrice_log = GarageArea_log / cli solution;
run;


/* Let's build the simple linear regression model again with SalePrice_log ~ GrLivArea_log but without the outliers */

proc glm data = train2 plots = all;
	model SalePrice_log = GrLivArea_Log / cli solution;
run;

/* attempting to back transform */
/* Fit log-log model */
proc reg data=train2;
   model SalePrice_log = GrLivArea_Log / clb;
   output out=reg_results predicted=ln_y_pred;
run;

/* Back-transform coefficients */
data reg_results;
   set reg_results;
   exp_intercept = exp(5.668124686);
   exp_slope = exp(GrLivArea_Log);
run;

/* Back-transform predictions */
data reg_results;
   set reg_results;
   y_pred = exp(ln_y_pred);
run;

proc glmselect data=train2;
  model SalePrice_log = GrLivArea_Log / selection=Stepwise(stop=CV) cvmethod = random(5) stats = adjrsq;
run;

data train2Q1NoOutliers;
	set train2;
	where ID ~= 1299 and ID ~= 524 and ID ~= 31 and ID ~= 643 
		and ID ~= 725 and ID ~= 913 and ID ~= 495 and ID ~= 1095 
		and ID~= 494 and ID ~= 911 and ID ~= 1039 and ID ~= 798 
		and ID ~= 536 and ID ~= 534 ;
run;

proc glm data = train2Q1NoOutliers plots = all;
	model SalePrice_log = GrLivArea_Log / clm cli solution;
run;




proc sgscatter data=train2Q1NoOutliers;
   	matrix SalePrice_log GrLivArea_Log;
run;

/* attempting to back transform */
/* Fit log-log model */
proc reg data=train2Q1NoOutliers plots = all;
   model SalePrice_log = GrLivArea_Log / clb;
   output out=reg_results predicted=ln_y_pred;
run;

/* Back-transform coefficients */
data reg_results;
   set reg_results;
   exp_intercept = exp(5.56207);
   exp_slope = exp(GrLivArea_Log);
run;

/* Back-transform predictions */
data reg_results;
   set reg_results;
   y_pred = exp(ln_y_pred);
run;


/* Y_pred */
data results_SLR;
	set reg_results;
	SalePrice = y_pred;
	keep id SalePrice;
where id > 1460;
;

/* Exporting results */
proc export data=results_slr
  outfile="/home/u63539974/sasuser.v94/DS 6371 - Stats I/Unit 14/results_slr.csv"
  dbms=csv
  replace;
run;

proc glmselect data=train2Q1NoOutliers;
  model SalePrice_log = GrLivArea_Log /  selection=Stepwise(stop=CV) cvmethod = random(5) stats = adjrsq;
run;


/* After removing some outliers I'd say the assumptions are not too messed up */ 
/* Let's see if we can find that one that is sticking way out */

proc reg data=train2Q1NoOutliers  plots(only label) =(CooksD RStudentByLeverage);
   model SalePrice_log = GrLivArea_Log; /* can also use INFLUENCE option */
run;


/* Multiple Linear Regression: SalePrice~GrLiveArea+FullBath */

/* Scatter Plot */
proc sgscatter data=train2;
   	matrix SalePrice GrLivArea FullBath;
run;

proc sgscatter data=train2;
   	matrix SalePrice_log GrLivArea_log FullBath;
run;

proc sgscatter data=train2;
   	matrix SalePrice_log GrLivArea_log FullBath_log;
run;

/* MLR */
proc reg data = train2;
	model SalePrice = GrLivArea FullBath;
run;

proc reg data = train2;
	model SalePrice_log = GrLivArea_log FullBath;
run;

proc reg data = train2;
	model SalePrice_log = GrLivArea_log FullBath_log;
run;


proc glm data = train2 plots = all;
	model SalePrice_log = GrLivArea_log FullBath_log / cli solution;
run;

/* Looking for outliers */

proc reg data=train2  plots(only label) =(CooksD RStudentByLeverage);
   model SalePrice_log = GrLivArea_log FullBath_log; /* can also use INFLUENCE option */
run;

/* Eliminating some outliers */
data train2Q2NoOutliers;
	set train2;
	where ID ~= 1299;
	
	/*and ID ~= 524 and ID ~= 31 and ID ~= 643 
		and ID ~= 725 and ID ~= 913 and ID ~= 495 and ID ~= 1095 
		and ID~= 494 and ID ~= 911 and ID ~= 1039 and ID ~= 798 
		and ID ~= 536 and ID ~= 534 ;*/
run;


/* Runnning model without outlier */
proc glm data = train2Q2NoOutliers plots = all;
	model SalePrice_log = GrLivArea_log FullBath / cli solution;
run;


/* Back Transforming */
proc reg data=train2Q2NoOutliers;
   model SalePrice_log = GrLivArea_log FullBath / clb;
   output out=mlr_results predicted=ln_y_pred;
run;

/* Back-transform coefficients */
data mlr_results;
   set mlr_results;
   exp_intercept = exp(6.50763);
   exp_slope_log_x1 = exp(GrLivArea_log);
run;

/* Back-transform predictions */
data mlr_results;
   set mlr_results;
   y_pred = exp(ln_y_pred);
run;

/* Y_pred */
data mlr_results;
	set mlr_results;
	SalePrice = y_pred;
	keep id SalePrice;
where id > 1460;
;

/* Handling SalePrice that is negative */
data mlr_results;
	set mlr_results;
	if predicted > 0 then SalePrice = y_pred;
	if predicted < 0 then SalePrice = exp(6.77615) + exp(GrLivArea_log) + exp(1);
	keep id SalePrice;
where id > 1460;
;

/* Exporting results */
proc export data=mlr_results
  outfile="/home/u63539974/sasuser.v94/DS 6371 - Stats I/Unit 14/results_mlr.csv"
  dbms=csv
  replace;
run;


proc glmselect data=train2Q2NoOutliers;
  model SalePrice_log = GrLivArea_log FullBath /  selection=Stepwise(stop=CV) cvmethod = random(5) stats = adjrsq;
run;



/* Question 3 */
proc glmselect data=train2;
  model SalePrice_log = OverallQual_log GrLivArea_log FirstFlrSf_log LotArea FullBath 
         / selection=Stepwise(stop=CV)
           cvmethod=random(5)
           stats=adjrsq;
run;




/* attempting to back transform */
/* Fit log-log model */
proc reg data=train2 plots = all;
   model SalePrice_log = OverallQual_log GrLivArea_log FirstFlrSf_log LotArea FullBath  / clb;
   output out=Cust_reg_results predicted=ln_y_pred;
run;

/* Back-transform coefficients */
data train2;
   set Cust_reg_results;
   exp_intercept = exp(6.51035);
   exp_slope_log_x1 = exp(OverallQual_log);
   exp_slope_log_x2 = exp(GrLivArea_log);
   exp_slope_log_x3 = exp(FirstFlrSf_log);
run;

/* Back-transform predictions */
data Cust_reg_results;
   set Cust_reg_results;
   y_pred = exp(ln_y_pred);
run;


/* Y_pred */
data Cust_reg_results;
	set Cust_reg_results;
	SalePrice = y_pred;
	keep id SalePrice;
where id > 1460;
;

/* Exporting results */
proc export data=Cust_reg_results
  outfile="/home/u63539974/sasuser.v94/DS 6371 - Stats I/Unit 14/Cust_results_mlr.csv"
  dbms=csv
  replace;
run;


proc glmselect data=train2Q2NoOutliers;
  model SalePrice_log = OverallQual_log GrLivArea_log FirstFlrSf_log LotArea FullBath /  selection=Stepwise(stop=CV) cvmethod = random(5) stats = adjrsq;
run;


