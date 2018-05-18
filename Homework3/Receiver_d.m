clc; close all; clear global; clearvars;
set(0,'defaultTextInterpreter','latex')    % latex format

% Load input and noise
load('Useful.mat');

% Channel SNR
snr_db = 10;
snr_lin = 10^(snr_db/10);

sigma_a = 2;

% Channel: NOISE IS ADDED AFTERWARDS
[r_c, sigma_w, ~] = channel_sim(in_bits, snr_db, sigma_a);
s_c = r_c;                  % Useful noise
r_c = r_c + w(:,3);

%% AA filter

Fpass = 0.2;             % Passband Frequency
Fstop = 0.3;             % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.01;            % Stopband Attenuation
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop], [1 0], [Dpass, Dstop]);

% Calculate the coefficients using the FIRPM function.
g_AA  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(g_AA);

r_c_prime = filter(g_AA , 1, r_c);

qg_up = conv(qc, g_AA);
qg_up = qg_up.';
%freqz(qg_up, 1,'whole');
figure, stem(abs(qg_up)), title('convolution of $g_{AA}$ and $q_c$'), xlabel('nT/4')

%% Timing phase and decimation

t0_bar = find(qg_up == max(qg_up));
x = downsample(r_c_prime(t0_bar:end), 2);

qg = downsample(qg_up, 2);
x_prime = x;

h = qg;
% h = h(h ~= 0);

%% Equalization and symbol detection

r_g = xcorr(g_AA);
N0 = (sigma_a * 1) / (4 * snr_lin);
r_w = N0 * downsample(r_g, 2);

% figure, stem(r_w), title('$r_w$'), xlabel('nT/2')
% figure, stem(r_g), title('$r_g$'), xlabel('nT/2')

N1 = floor(length(h)/2);
N2 = 12;

M1 = 5;
D = 2;
M2 = N2 + M1 - 1 - D;

[c, Jmin] = WienerC_frac(h, r_w, sigma_a, M1, M2, D, N1, N2);
psi = conv(h,c);

figure, stem(abs(c)), title('c'), xlabel('nT/2'), grid on
figure, stem(abs(psi)), title('|$\psi$|'), xlabel('nT/2'), grid on

psi_down = downsample(psi(2:end),2); % The b filter act at T
b = -psi_down(find(psi_down == max(psi_down)) + 1:end); 

figure, stem(abs(b)), title('b'), xlabel('nT'), grid on
decisions = equalization_pointC(x_prime, c, b, D);

[Pe_d, errors] = SER(in_bits(1:length(decisions)), decisions);