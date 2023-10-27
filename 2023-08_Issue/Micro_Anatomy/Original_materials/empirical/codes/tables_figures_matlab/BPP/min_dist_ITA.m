function obj = min_dist_ITA(param,vec_cc,omega,T,rho)


fm = mom_BPP_ITA(param,T);


[a,b] = size(omega);
wgt = zeros(a,b);
for i=1:b
   wgt(i,i) = 1; %omega(i,i)
end

vec_cc(fm == 0) = 0;

obj = (vec_cc - fm)'*inv(wgt)*(vec_cc - fm);


end