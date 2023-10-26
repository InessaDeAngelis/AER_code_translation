function il = loan_demand(l, A, ddelta, aalpha)
    % Compute loan rate given loan quantity demanded
    il = aalpha * A * l^(aalpha - 1) - ddelta;
    
end


