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

% Anti-Aliasing filter
Fpass = 0.45;            % Passband Frequency
Fstop = 0.55;            % Stopband Frequency
Dpass = 0.057501127785;  % Passband Ripple
Dstop = 0.0001;          % Stopband Attenuation
dens  = 20;              % Density Factor
% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fpass, Fstop], [1 0], [Dpass, Dstop]);
% Calculate the coefficients using the FIRPM function.
g_AA  = firpm(N, Fo, Ao, W, {dens});
% G_AA = dfilt.dffir(g_AA);

% Filtering received signal
r_c_prime = filter(g_AA,1,r_c);
t0_bar = length(g_AA);

% Remove "transient" and downsample received signal
r_c_prime = r_c_prime(t0_bar:end);
x = downsample(r_c_prime,2);

% Matched filter
g = conv(qc, g_AA);
gm = conj(g(end:-1:1));
gm = downsample(gm,2);

% Impulse response of the system at the input of the FF filter
h = conv(g,gm);
h = h(h>max(h)/100);

x = filter(gm,1,x);

% Filter autocorrelation
r_gm = xcorr(gm,gm);
rw_tilde = sigma_w/4*r_gm;

% Parameters for DFE
M1 = 8;
M2 = 2;
D = 3;
[c_opt, Jmin] = Adaptive_DFE(h, rw_tilde, sigma_a, M1, M2, D);

psi = conv(c_opt, h_T);
psi = psi/max(psi);

b = - psi(end - M2 + 1:end);

%% FIGURES
[G_AA, f] = freqz(g_AA,1,1024,'whole');
f = linspace(0,4,length(f));

figure()
plot(f,10*log10(abs(G_AA)));
xlim([0 2]);
ylim([-40 10]);
xlabel('f'), grid on
ylabel('$| G_{AA}(f) |$ $[dB]$')




