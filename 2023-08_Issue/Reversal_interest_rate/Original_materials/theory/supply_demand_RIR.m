clear
clf

% Set model parameters
A = 1.0;
ddelta = 0.08;
aalpha = 0.33;

% Vector of loan quantities
lmin = 1.0;
lmax = 5.0;
N = 1000;
l_vec = linspace(lmin, lmax, N);


il_vec = zeros(1, N);
eps_vec = zeros(1, N);
for n=1:N
    % Compute loan rate for each loan quantity (demand curve)
    il_vec(n) = loan_demand(l_vec(n), A, ddelta, aalpha);

    % Elasticity of loan demand (to compute loan supply curve)
    eps_vec(n) = eps_l(l_vec(n), A, aalpha);
end


%% Figures

% Interest rates
i0 = 0.03;
i1 = -0.01;
i2 = 0.06;

% Net worth values
n0 = 0.62;
n1 = 0.45;
n2 = 0.79;

% Capital constraint parameter
psi = 5.0;

figure(1)
plot(l_vec, il_vec, 'b')
hold on
plot(l_vec(l_vec < psi * n2), i2 + 0.02 ./ eps_vec(l_vec < psi * n2), 'r')
plot([psi * n2, psi * n2], [i2 + 0.02 ./ eps_l(psi * n2, A, aalpha), 0.25], 'r')
scatter(2.22, i2 + 0.02 ./ eps_l(2.25, A, aalpha), 'filled', 'k', 'LineWidth', 2.0)
plot(l_vec(l_vec < psi * n0), i0 + 0.02 ./ eps_vec(l_vec < psi * n0), '--r')
plot([psi * n0, psi * n0], [i0 + 0.02 ./ eps_l(psi * n0, A, aalpha), 0.25], '--r')
scatter(2.76, i0 + 0.02 ./ eps_l(2.75, A, aalpha), 'filled', 'k', 'LineWidth', 2.0)
ylabel('$i^L$', 'Interpreter', 'Latex')
xlabel('$L$', 'Interpreter', 'Latex')
text(4.5, 0.055, '$L^D$', 'Interpreter', 'Latex')
text(psi * n2 + 0.05, 0.22, '$L^S(N, i)$', 'Interpreter', 'Latex')
text(psi * n0 + 0.05, 0.22, '$L^S(N'', i'')$', 'Interpreter', 'Latex')
annotation('arrow', [(psi * n2 - 0.2 - 1)/4, (psi * n0 + 0.1 - 1)/4], [0.17/0.25, 0.17/0.25])
text(3.45, 0.16, '$N \downarrow$', 'Interpreter', 'Latex')
annotation('arrow', [1.3/4, 1.3/4], [0.118/0.25, 0.093/0.25])
text(1.72, 0.095, '$i \downarrow$', 'Interpreter', 'Latex')
saveas(gcf, "supply_demand_1.png", "png")


figure(2)
plot(l_vec, il_vec, 'b')
hold on
plot(l_vec(l_vec < psi * n0), i0 + 0.02 ./ eps_vec(l_vec < psi * n0), 'r')
plot([psi * n0, psi * n0], [i0 + 0.02 ./ eps_l(psi * n0, A, aalpha), 0.25], 'r')
scatter(2.76, i0 + 0.02 ./ eps_l(2.75, A, aalpha), 'filled', 'k', 'LineWidth', 2.0)
plot(l_vec(l_vec < psi * n1), i1 + 0.02 ./ eps_vec(l_vec < psi * n1), '--r')
plot([psi * n1, psi * n1], [i1 + 0.02 ./ eps_l(psi * n1, A, aalpha), 0.25], '--r')
scatter(psi * n1, loan_demand(psi*n1, A, ddelta, aalpha), 'filled', 'k', 'LineWidth', 2.0)
ylabel('$i^L$', 'Interpreter', 'Latex')
xlabel('$L$', 'Interpreter', 'Latex')
text(4.5, 0.055, '$L^D$', 'Interpreter', 'Latex')
text(psi * n0 + 0.05, 0.22, '$L^S(N'', i'')$', 'Interpreter', 'Latex')
text(psi * n1 + 0.05, 0.22, '$L^S(N'''', i'''')$', 'Interpreter', 'Latex')
annotation('arrow', [(psi * n0 - 1)/4, (psi * n1 + 0.25 - 1)/4], [0.17/0.25, 0.17/0.25])
text(2.65, 0.16, '$N \downarrow$', 'Interpreter', 'Latex')
annotation('arrow', [1/4, 1/4], [0.09/0.25, 0.06/0.25])
text(1.72, 0.06, '$i \downarrow$', 'Interpreter', 'Latex')
saveas(gcf, "supply_demand_2.png", "png")


