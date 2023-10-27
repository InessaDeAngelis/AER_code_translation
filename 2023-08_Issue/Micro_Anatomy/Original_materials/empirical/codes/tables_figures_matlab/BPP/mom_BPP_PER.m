function fm = mom_BPP_PER(param,T)

%% parameters
teta = param(1); % MA(1) coefficient
varcsi = param(2); % variance unobserved
zt = param(3); % variance permanent
et = param(4); % variance transitory
phit = param(5); % permanent elasticity coefficient
psit = param(6); % temporary elasticity coefficient
varv = param(7:7+2); % C error measurement

%% matrix second moments

dify  =zeros(T,T); % income
difcd =zeros(T,T); % consumption measure
difcme=zeros(T,T); % consumption error
difyc =zeros(T,T); % income and consumption
dif   =zeros(2*T,2*T); % all mom matrix

% income matrix

for j = 1:T
        dify(j,j) = zt(1)+et(1)+(1-teta)^2*et(1)+teta^2*et(1); % diagonal = variance
end

for j=2:T 
    dify(j-1,j) = -(1-teta)*et(1)+teta*(1-teta)*et(1); % cov y_{t} y_{t+1} growth
end

for j=3:T
dify(j-2,j)=-teta*et(1); % cov y_{t} y_{t+2} growth 
end

for i = 2:T
for j=i:T
dify(j,i-1)=dify(i-1,j); % other terms
end
end

% consumption matrix

for j=1:T
    difcd(j,j)=phit(1)^2*zt(1)+psit(1)^2*et(1)+varcsi;
end

%missing_v = (varv(1)+varv(2)+varv(3)+varv(4))/4;
    
difcme(1,1)=2*varv(1);
for j=2:T-1
difcme(j,j)=varv(j)+varv(j-1);    
end
difcme(T,T)=2*varv(end);

difc=difcme+difcd;

for i=2:T
    for j=i:T
        difc(j,i-1)=difc(i-1,j);
    end    
end

% income and consumption matrix


for j=1:T
    difyc(j,j)=phit(1)*zt(1)+psit(1)*et(1);
end

for j=2:T
    difyc(j-1,j)=-(1-teta)*psit(1)*et(1);
end

for j=3:T-1
    difyc(j-2,j)=-teta*psit(1)*et(1);
end

% all matrix

dif(1:T,1:T)          = difc;
dif(T+1:2*T,1:T)      = difyc;
dif(1:T,T+1:2*T)      = difyc';
dif(T+1:2*T,T+1:2*T)  = dify;

%difa1=[dif(1:8,:);dif(12:2*T,:)]; % for the missing years
%difa2=[difa1(:,1:8),difa1(:,12:2*T)];

fm=vech(dif);



end