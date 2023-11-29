proc print data= train;
run;

/*Question 1*/
/*Filter our dataset and Log Transform*/
data train2;
set train;
where Neighborhood contains "Edwards" 
	or Neighborhood contains"NAmes" 
	or Neighborhood contains "BrkSide";
run; 

proc print data= train2;
run;

/*Plot with Outliers*/
proc sgplot data=train2;
 scatter x=GrLivArea y=SalePrice / group=Neighborhood;
run;

/* Build Model 1 with outliers*/
proc reg data= train2;
model SalePrice = GrLIvArea / vif clb cli clm; 
run;

data train2;
set train2;
lPrice = log(SalePrice);
lLivArea = log(GrLivArea);
run;


/* Build Model 2 with outliers*/
proc glm data = train2 plots = all;
where Neighborhood;
class Neighborhood (REF = "BrkSide");
model SalePrice = Neighborhood|GrLivArea/solution clparm;
run; 


/* Remove Outliers */
data trainNoOutliers;
set train2;
keep Id Neighborhood GrLivArea SalePrice;
where Id ~= 524 and Id ~= 643 and Id~= 725 and Id~= 1299 and Id~= 1299;  
run;

/*Plot without Outliers*/
title 'Scatter plot without outlieers: SalePrice vs. GrLlvArea';
proc sgplot data=trainNoOutliers;
 scatter x=GrLivArea y=SalePrice / group=Neighborhood;
run;

/* Run Model Without Outliers */
Proc reg data= trainNoOutliers;
model SalePrice = GrLivArea/ vif clb cli clm; 
run;

proc glm data=trainNoOutliers alpha=0.05 plots = All;
class Neighborhood;
model SalePrice = GrLivArea / solution;
run;

/* Plot the scatter plot without outliers */
title ‘Scatter plot without outliers: SalePrice v. GrLIvArea’;
PROC sgplot DATA=trainNoOutliers;
scatter x=GrLIvArea y=SalePrice;
run;

/*Develop a third model without outliers*/
proc glm data= trainNoOutlier plots = all;
class neighborhood (REF = "BrkSide");
model SalePrice = GrLIvArea|Neighborhood / solution clparm cli;
run;

/* Comparing Competing Models*/
proc glmselect data = trainNoOutlier plots = all;
where Neighborhood;
class Neighborhood (REF = "BrkSide");
model SalePrice = Neighborhood|GrLivArea @2/ selection = Stepwise(stop = cv) 
cvmethod = random(5) stats = adjrsq;;
run;




