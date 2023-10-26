

capture program drop randomization_inference

program randomization_inference, rclass
version 14.2


// DEFINE THE INPUT PARAMETERS AND THEIR DEFAULT VALUE

   syntax,[alpha(real 0.05)   ///  alpha level
	 share(real 0.5)    ///  share not_treated
	]
	
//  GENERATE THE RANDOM DATA AND TEST THE NULL HYPOTHESIS

   cap drop treat
   g treat = rbinomial(1,`share')
        
// TEST THE NULL HYPOTHESIS

   quietly regress $y treat $controls, $error
   test treat

   
// RETURN RESULTS
    return scalar beta = _b[treat]
    return scalar pvalue = r(p)
    return scalar reject = (r(p)<`alpha')  
 
end
