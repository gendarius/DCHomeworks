clc; close all; clear global; clearvars;
set(0,'defaultTextInterpreter','latex');

% Load input and noise
load('Useful.mat');

% Channel SNR
snr_db = 10;
snr_lin = 10^(snr_db/10);

sigma_a = 2;	% Input variance

[r_c, sigma_w, ~] = channel_sim(in_bits, snr_db, sigma_a);
r_c = r_c + w(:,3);

gm = conj(qc(end:-1:1));	% Matched filter: complex conjugate of qc

h = conv(qc,gm);				% Impulse response
t0_bar = find(h == max(h));		% Determining timing phase
h_T = downsample(h,4);			% Downsampling impulse response
r_c_prime = filter(gm,1,r_c);	% Filtering received signal

r_c_prime = r_c_prime(t0_bar:end);	% Remove "transient"
x = downsample(r_c_prime,4);		% Downsample received signal

r_gm = xcorr(gm,gm);			% Filter autocorrelation
N0 = (sigma_a * E_qc) / (4 * snr_lin);
rw_tilde = N0 .* downsample(r_gm, 2);

% Parameters for DFE
M1 = 5;
N2 = floor(length(h_T)/2);
D = 4;
M2 = N2 + M1 - 1 - D;
[c_opt, Jmin] = Adaptive_DFE(h_T, rw_tilde, sigma_a, M1, M2, D);

psi = conv(c_opt, h_T);
psi = psi/max(psi);

figure
subplot(121), stem(0:length(c_opt)-1,abs(c_opt)), hold on, grid on
title('$|c|$'), xlabel('n');
subplot(122), stem(0:length(psi)-1,abs(psi)), grid on
title('$|\psi|$'), xlabel('n');

y = conv(x, c_opt);		% Input for ForwardBackward
y = y/max(psi);

L1 = 0;
L2 = 4;
indexD = find(psi == max(psi));

detected = FBA(y, psi(indexD-L1:indexD+L2), L1, L2);

nerr = length(find(in_bits(1:length(detected))~=detected));
Pe = nerr/length(detected);