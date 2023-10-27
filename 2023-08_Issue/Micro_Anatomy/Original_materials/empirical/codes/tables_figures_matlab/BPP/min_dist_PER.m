function obj = min_dist_PER(param,vec_cc,omega,T,rho)


fm = mom_BPP_PER(param,T);

[a,b] = size(omega);
wgt = zeros(a,b);
for i=1:b
   wgt(i,i) = omega(i,i); %1
end

obj = (vec_cc - fm)'*inv(wgt)*(vec_cc - fm);


end