function fm = mom_BPP_ITA(param,T)

%% parameters
teta = param(1); % MA(1) coefficient
vareta = 0;
varcsi = param(2); % variance unobserved
zt = param(2+1:2+T-4); % variance permanent
et = param(2+T-4+1:2+T-4+T-2); % variance transitory
phit = param(2+T-4+T-2+1); % permanent elasticity coefficient
psit = param(2+T-4+T-2+2); % temporary elasticity coefficient
varv = param(2+T-4+T-2+2+1:2+T-4+T-2+2+8); % C error measurement

%% matrix second moments

dify  =zeros(T,T); % income
difcd =zeros(T,T); % consumption measure
difcme=zeros(T,T); % consumption error
difyc =zeros(T,T); % income and consumption
dif   =zeros(2*T,2*T); % all mom matrix

% income matrix

dify(1,1) = zt(1)+zt(1)+et(1)+teta^2*et(1)+et(1)+teta^2*et(1);
dify(2,2) = zt(1)+zt(1)+et(2)+teta^2*et(2)+et(1)+teta^2*et(1);
dify(3,3) = zt(1)+zt(1)+et(3)+teta^2*et(3)+et(2)+teta^2*et(2);
for j = 4:T-3
        dify(j,j) = zt(j-2)+zt(j-2)+et(j)+teta^2*et(j)+et(j-1)+teta^2*et(j-1); % diagonal = variance
end
dify(T-2,T-2) = zt(T-4)+zt(T-4)+et(T-2)+teta^2*et(T-2)+et(T-3)+teta^2*et(T-3);
dify(T-1,T-1) = zt(T-4)+zt(T-4)+et(T-2)+teta^2*et(T-2)+et(T-2)+teta^2*et(T-2);
dify(T,T) = zt(T-4)+zt(T-4)+et(T-2)+teta^2*et(T-2)+et(T-2)+teta^2*et(T-2);

dify(1,2) = -et(1)-teta^2*et(1);
for j=3:T-1 
    dify(j-1,j) = -et(j-1)-teta^2*et(j-1); % cov y_{t} y_{t+2} growth
end
dify(T-1,T-2)=-et(T-2)-teta^2*et(T-2);

for i = 2:T
for j=i:T
dify(j,i-1)=dify(i-1,j); % other terms
end
end

% consumption matrix

difcd(1,1)=phit(1)^2*zt(1)+phit(1)^2*zt(1)+psit(1)^2*et(1)+psit(1)^2*et(1)+2*varcsi;
difcd(2,2)=phit(1)^2*zt(1)+phit(1)^2*zt(1)+psit(1)^2*et(2)+psit(1)^2*et(2)+2*varcsi;
difcd(3,3)=phit(1)^2*zt(1)+phit(1)^2*zt(1)+psit(1)^2*et(3)+psit(1)^2*et(3)+2*varcsi;
for j=4:T-3   
    difcd(j,j)=phit(1)^2*zt(j-2)+phit(1)^2*zt(j-2)+psit(1)^2*et(j)+psit(1)^2*et(j)+2*varcsi;
end
difcd(T-2,T-2)=phit(1)^2*zt(T-4)+phit(1)^2*zt(T-4)+psit(1)^2*et(T-2)+psit(1)^2*et(T-2)+2*varcsi;
difcd(T-1,T-1)=phit(1)^2*zt(T-4)+phit(1)^2*zt(T-4)+psit(1)^2*et(T-2)+psit(1)^2*et(T-2)+2*varcsi;
difcd(T,T)=    phit(1)^2*zt(T-4)+phit(1)^2*zt(T-4)+psit(1)^2*et(T-2)+psit(1)^2*et(T-2)+2*varcsi;
    
difcme(1,1)=2*varv(1);
for j=2:8
difcme(j,j)=varv(j)+varv(j-1);    
end
difcme(9,9)=2*varv(8);

for j=1:8
    difcme(j,j+1)=-varv(j);
end

difc=difcme+difcd;

for i=2:T
    for j=i:T
        difc(j,i-1)=difc(i-1,j);
    end
    
end

% income and consumption matrix

difyc(1,1)=phit(1)*zt(1)+phit(1)*zt(1)+psit(1)*et(1)+teta*psit(1)*et(1);
difyc(2,2)=phit(1)*zt(1)+phit(1)*zt(1)+psit(1)*et(2)+teta*psit(1)*et(2);
difyc(3,3)=phit(1)*zt(1)+phit(1)*zt(1)+psit(1)*et(3)+teta*psit(1)*et(3);
for j=4:T-3    
    difyc(j,j)=phit(1)*zt(j-2)+phit(1)*zt(j-2)+psit(1)*et(j)+teta*psit(1)*et(j);
end
difyc(T-2,T-2)=phit(1)*zt(T-4)+phit(1)*zt(T-4)+psit(1)*et(T-2)+teta*psit(1)*et(T-2);
difyc(T-1,T-1)=phit(1)*zt(T-4)+phit(1)*zt(T-4)+psit(1)*et(T-2)+teta*psit(1)*et(T-2);
difyc(T,T)=phit(1)*zt(T-4)+phit(1)*zt(T-4)+psit(1)*et(T-2)+teta*psit(1)*et(T-2);

for j=2:T-1
    difyc(j-1,j)= -psit(1)*et(j-1) - psit(1)*teta*et(j-1);
end
difyc(T-1,T)=-psit(1)*et(T-2) - psit(1)*teta*et(T-2);

% all matrix

dif(1:T,1:T)          = difc;
dif(T+1:2*T,1:T)      = difyc;
dif(1:T,T+1:2*T)      = difyc';
dif(T+1:2*T,T+1:2*T)  = dify;

fm=vech(dif);


end