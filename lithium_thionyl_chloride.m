%% =========================================================
%  Lithium-Thionyl Chloride (Li-SOCl2) Battery Simulation
%  =========================================================
%  Based on cell chemistry described in:
%  "Characteristics of Lithium-Thionyl Chloride Batteries"
%
%  Two discharge reactions modelled:
%   Low  current density:  8 Li + 3 SOCl2 -> 6 LiCl + Li2SO3 + 2S
%   High current density:  4 Li + 2 SOCl2 -> 4 LiCl + SO2 + S
%
%  Model features:
%   - State-of-charge (SOC) tracking
%   - Voltage model (OCV + polarisation losses)
%   - LiCl passivation layer resistance
%   - Thermal sub-model (single lumped node)
%   - Selectable constant-current or constant-resistance load
% =========================================================

clear; clc; close all;

%% ---- 1. Battery Parameters --------------------------------
% Geometry & capacity
params.capacity_Ah   = 2.0;          % Nominal capacity [Ah]
params.V_nom         = 3.6;          % Nominal voltage [V]
params.V_OCV_full    = 3.67;         % Open-circuit voltage at full charge [V]
params.V_cutoff      = 2.0;          % End-of-discharge cutoff voltage [V]

% Theoretical capacity from low-current reaction (0.60 Ah/g SOCl2)
params.spec_cap_SOCl2 = 0.60;        % Ah/g (from document)

% Internal resistance components [Ohm]
params.R_bulk        = 0.05;         % Bulk electrolyte resistance
params.R_passive_max = 1.2;         % Max LiCl passivation resistance
params.R_passive_k   = 5.0;          % Passivation growth rate constant

% Activation / concentration polarisation
params.alpha         = 0.5;          % Butler-Volmer symmetry factor
params.i0            = 1e-4;         % Exchange current density [A/cm^2]
params.A_electrode   = 2298;          % Electrode area [cm^2]
params.R_g           = 8.314;        % Gas constant [J/(mol·K)]
params.F             = 96485;        % Faraday constant [C/mol]

% Thermal parameters
params.m_cell        = 0.100;        % Cell mass [kg]
params.Cp            = 800;          % Specific heat capacity [J/(kg·K)]
params.T_amb         = 298.15;       % Ambient temperature [K]  (25 °C)
params.h_conv        = 5.0;          % Convective heat transfer coeff [W/(m^2·K)]
params.A_surf        = 0.004;        % Cell surface area [m^2]
params.Ea_reaction   = 20000;        % Activation energy [J/mol] (approx)

%% ---- 2. Simulation Settings --------------------------------
sim.dt           = 1;            % Time step [s]
sim.t_max        = 10000;        % Max simulation time [s]
sim.I_load       = 0.20;         % Discharge current [A]  (change as desired)
% Uncomment the line below for a high-current-density scenario (> ~2 A)
% sim.I_load     = 3.0;

% Current density threshold: selects reaction regime
params.i_density_threshold = 2.0;   % [mA/cm^2] boundary low/high reaction

%% ---- 3. Initialisation ------------------------------------
n_steps  = floor(sim.t_max / sim.dt);
time     = zeros(1, n_steps);
SOC      = zeros(1, n_steps);
V_term   = zeros(1, n_steps);
V_OCV    = zeros(1, n_steps);
R_pass   = zeros(1, n_steps);
T_cell   = zeros(1, n_steps);
Q_disch  = zeros(1, n_steps);   % Cumulative discharged charge [Ah]
Rxn_type = zeros(1, n_steps);   % 1 = low-i reaction, 2 = high-i reaction

% Initial conditions
SOC(1)    = 1.0;                  % Fully charged
T_cell(1) = params.T_amb;
Q_disch(1)= 0;

current_density = (sim.I_load / params.A_electrode) * 1000;  % mA/cm^2

fprintf('=== Li-SOCl2 Battery Simulation ===\n');
fprintf('Load current        : %.3f A\n', sim.I_load);
fprintf('Current density     : %.3f mA/cm^2\n', current_density);
if current_density < params.i_density_threshold
    fprintf('Reaction regime     : LOW current density\n');
    fprintf('  8 Li + 3 SOCl2 -> 6 LiCl + Li2SO3 + 2S\n');
else
    fprintf('Reaction regime     : HIGH current density\n');
    fprintf('  4 Li + 2 SOCl2 -> 4 LiCl + SO2 + S\n');
end
fprintf('\n');

%% ---- 4. Main Simulation Loop ------------------------------
for k = 1 : n_steps - 1

    soc_k = SOC(k);
    T_k   = T_cell(k);

    % 4a. Determine active reaction regime based on current density
    if current_density < params.i_density_threshold
        rxn = 1;   % Low current: 8 Li + 3 SOCl2 -> 6 LiCl + Li2SO3 + 2S
    else
        rxn = 2;   % High current: 4 Li + 2 SOCl2 -> 4 LiCl + SO2 + S
    end
    Rxn_type(k) = rxn;

    % 4b. Temperature-corrected exchange current (Arrhenius)
    i0_T = params.i0 * exp(-params.Ea_reaction / params.R_g * ...
           (1/T_k - 1/params.T_amb));

    % 4c. Open-circuit voltage (linear SOC dependence + temperature correction)
    dV_dT   = -0.0005;      % V/K (typical for Li-SOCl2)
    V_OCV(k) = (params.V_OCV_full - 0.15*(1 - soc_k)) + ...
               dV_dT * (T_k - params.T_amb);

    % 4d. LiCl passivation layer resistance (grows as SOC decreases)
    %     R_pass = R_max * (1 - exp(-k_pass*(1-SOC)))
    R_pass(k) = params.R_passive_max * ...
                (1 - exp(-params.R_passive_k * (1 - soc_k)));

    % 4e. Butler-Volmer activation overpotential (Newton iteration)
    eta = solve_BV_eta(sim.I_load, i0_T * params.A_electrode, ...
                       params.alpha, params.F, params.R_g, T_k);

    % 4f. Total terminal voltage
    V_ohmic   = sim.I_load * (params.R_bulk + R_pass(k));
    V_term(k) = V_OCV(k) - eta - V_ohmic;

    % 4g. Check cutoff
    if V_term(k) <= params.V_cutoff
        fprintf('Cutoff voltage reached at t = %d s  (step %d)\n', ...
                round(time(k)), k);
        % Trim arrays to current step
        time     = time(1:k);
        SOC      = SOC(1:k);
        V_term   = V_term(1:k);
        V_OCV    = V_OCV(1:k);
        R_pass   = R_pass(1:k);
        T_cell   = T_cell(1:k);
        Q_disch  = Q_disch(1:k);
        Rxn_type = Rxn_type(1:k);
        break;
    end

    % 4h. Coulomb counting: update SOC
    dQ = sim.I_load * sim.dt / 3600;          % Ah consumed this step
    Q_disch(k+1) = Q_disch(k) + dQ;
    SOC(k+1)     = max(0, soc_k - dQ / params.capacity_Ah);

    % 4i. Thermal model (lumped single node)
    %     Heat generated = I^2*R_internal + irreversible overpotential heat
    Q_gen  = sim.I_load^2 * (params.R_bulk + R_pass(k)) + ...
             sim.I_load * abs(eta);
    Q_diss = params.h_conv * params.A_surf * (T_k - params.T_amb);
    dT     = (Q_gen - Q_diss) / (params.m_cell * params.Cp) * sim.dt;
    T_cell(k+1) = T_k + dT;

    % 4j. Advance time
    time(k+1) = time(k) + sim.dt;
end

n_final = length(time);
fprintf('Simulation complete. Steps: %d  |  Discharge time: %.1f s (%.2f min)\n', ...
        n_final, time(end), time(end)/60);
fprintf('Discharged capacity : %.4f Ah  (%.1f%% of nominal)\n', ...
        Q_disch(end), Q_disch(end)/params.capacity_Ah*100);
fprintf('Final temperature   : %.2f K  (%.2f °C)\n', ...
        T_cell(end), T_cell(end)-273.15);

%% ---- 5. Results Plotting ----------------------------------
figure('Name','Li-SOCl2 Battery Simulation','NumberTitle','off', ...
       'Position',[100 80 1100 750]);

% 5a. Voltage vs Time
subplot(2,3,1);
plot(time/60, V_term, 'b-', 'LineWidth', 1.5); hold on;
plot(time/60, V_OCV,  'r--','LineWidth', 1.2);
yline(params.V_cutoff,'k:','LineWidth',1.2);
xlabel('Time (min)'); ylabel('Voltage (V)');
title('Terminal & OCV vs Time');
legend('V_{terminal}','V_{OCV}','V_{cutoff}','Location','southwest');
grid on; ylim([1.8, 3.9]);

% 5b. SOC vs Time
subplot(2,3,2);
plot(time/60, SOC*100, 'g-', 'LineWidth', 1.5);
xlabel('Time (min)'); ylabel('SOC (%)');
title('State of Charge vs Time');
grid on; ylim([0 105]);

% 5c. Passivation Resistance vs SOC
subplot(2,3,3);
plot(SOC*100, R_pass, 'm-', 'LineWidth', 1.5);
set(gca,'XDir','reverse');
xlabel('SOC (%)'); ylabel('R_{passivation} (\Omega)');
title('LiCl Passivation Layer Resistance');
grid on;

% 5d. Temperature vs Time
subplot(2,3,4);
plot(time/60, T_cell - 273.15, 'r-', 'LineWidth', 1.5);
yline(params.T_amb - 273.15, 'k--', 'LineWidth',1);
xlabel('Time (min)'); ylabel('Temperature (°C)');
title('Cell Temperature vs Time');
legend('T_{cell}','T_{ambient}','Location','southeast');
grid on;

% 5e. Discharge Capacity (Ah)
subplot(2,3,5);
plot(time/60, Q_disch, 'c-', 'LineWidth', 1.5);
xlabel('Time (min)'); ylabel('Discharged Capacity (Ah)');
title('Cumulative Discharged Capacity');
grid on;

% 5f. Ragone-style instantaneous power
P_inst = V_term .* sim.I_load;
subplot(2,3,6);
plot(Q_disch, P_inst, 'k-', 'LineWidth', 1.5);
xlabel('Discharged Capacity (Ah)'); ylabel('Power (W)');
title('Power vs Discharged Capacity');
grid on;

sgtitle(sprintf('Li-SOCl_2 Battery Simulation  |  I = %.2f A  |  %s-current regime', ...
    sim.I_load, iif(current_density < params.i_density_threshold,'Low','High')), ...
    'FontSize',13,'FontWeight','bold');

%% ---- 6. Summary Table -------------------------------------
fprintf('\n--- Simulation Summary ---\n');
fprintf('%-30s %10.4f Ah\n',  'Theoretical capacity (0.60 Ah/g):', params.spec_cap_SOCl2);
fprintf('%-30s %10.4f Ah\n',  'Actual discharged capacity:',        Q_disch(end));
fprintf('%-30s %10.4f V\n',   'Initial terminal voltage:',          V_term(1));
fprintf('%-30s %10.4f V\n',   'Final terminal voltage:',            V_term(end));
fprintf('%-30s %10.4f Ohm\n', 'Final passivation resistance:',      R_pass(end));
fprintf('%-30s %10.2f min\n', 'Discharge duration:',                time(end)/60);
fprintf('%-30s %10.2f Wh\n',  'Energy delivered:',                  trapz(time/3600, V_term.*sim.I_load));

%% =========================================================
%  Helper Functions
%% =========================================================

function eta = solve_BV_eta(I, I0, alpha, F, Rg, T)
% Solve Butler-Volmer for overpotential eta given current I
% using Newton-Raphson iteration
%   I = I0 * [exp(alpha*F*eta/(Rg*T)) - exp(-(1-alpha)*F*eta/(Rg*T))]
    if I0 <= 0
        eta = 0; return;
    end
    a   = alpha * F / (Rg * T);
    b   = (1 - alpha) * F / (Rg * T);
    eta = 0.05;   % initial guess [V]
    for iter = 1:50
        f    = I0*(exp(a*eta) - exp(-b*eta)) - I;
        df   = I0*(a*exp(a*eta) + b*exp(-b*eta));
        step = f / df;
        eta  = eta - step;
        if abs(step) < 1e-10, break; end
    end
end

function result = iif(cond, a, b)
% Inline if helper
    if cond, result = a; else, result = b; end
end