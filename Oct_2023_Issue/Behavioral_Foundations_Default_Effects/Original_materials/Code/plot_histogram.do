*This do file plots the histogram for number of benchmark plans in market-year (Appendix Figure 11)
*Final products: Histogram_benchmark_plan_weighted.eps; Histogram_benchmark_plan_unweighted.eps

import excel "/Users/AdelinaWang/Desktop/Histogram_to_Graph.xlsx", sheet("Sheet1") firstrow

twoway bar WeightedbyBeneficiary obs_fin, xlabel(0(5)15) graphregion(color(white)) title("# of Benchmark Plans in Market-Year" "Weighted by # of Beneficiaries") xtitle("# of Benchmark Plans") ytitle("Fraction")
graph export "/Users/AdelinaWang/Desktop/Histogram_benchmark_plan_weighted.eps"

twoway bar Unmweighted obs_fin, xlabel(0(5)15) graphregion(color(white)) title("# of Benchmark Plans in Market-Year" "Unmweighted") xtitle("# of Benchmark Plans") ytitle("Fraction")
graph export "/Users/AdelinaWang/Desktop/Histogram_benchmark_plan_unweighted.eps"

