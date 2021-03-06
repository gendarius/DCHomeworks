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

r_c = r_c + w(:,3);

% Matched filter
gm = conj(qc(end:-1:1));

figure()
stem(abs(gm));
xlabel('$m\frac{T}{4}$');
ylabel('$g_m$')
xlim([1 length(gm)]);
grid on

% Filtering received signal
r_c_prime = filter(gm,1,r_c);

% Impulse response of the system at the input of the FF filter
h = conv(qc,gm);

% Determining timing phase
t0_bar = find(h == max(h));

h = h(h>max(h)/100);
h = h(3:end-2);

% Downsampling impulse response
h_T = downsample(h,4);

% Remove "transient" and downsample received signal
r_c_prime = r_c_prime(t0_bar:end);
x = downsample(r_c_prime,4);

% Filter autocorrelation
r_gm = xcorr(gm,gm);
rw_tilde = sigma_w/4 .* downsample(r_gm, 4);

% Parameters for Linear Equalizer
M1 = 7;
M2 = 0;
D = 6;
[c_opt, Jmin] = Adaptive_DFE(h_T, rw_tilde, sigma_a, M1, M2, D);

psi = conv(c_opt, h_T);

figure
subplot(121), stem(0:length(c_opt)-1,abs(c_opt)), hold on, grid on
ylabel('$|c|$'), xlabel('n'); xlim([0 7]);
subplot(122), stem(-2:length(psi)-3,abs(psi)), grid on
ylabel('$|\psi|$'), xlabel('n'); xlim([-2 8]);

detected = equalization_LE(x, c_opt, M1, D, max(psi));

nerr = length(find(in_bits(1:length(detected))~=detected));
Pe = nerr/length(in_bits(1:length(detected)));