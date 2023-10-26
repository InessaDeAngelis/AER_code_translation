function eps = eps_l(l, A, aalpha)
    % Elasticity of loan demand
    eps = aalpha * A / (1 - aalpha) * l^(-aalpha);
    
end

