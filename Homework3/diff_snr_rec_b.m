clc; close all; clear global; clearvars;

% Input
load('Useful.mat');
% load('JminDFE.mat');
SNR_vect = [8 9 10 11 12 13 14];
Pe_DFE = zeros(length(SNR_vect),1);
errors = zeros(length(SNR_vect),1);

sigma_a = 2;
gm = conj(qc(end:-1:1));
h = conv(qc,gm);
% h = h(h>max(h)/100);
% h = h(3:end-2);
h_T = downsample(h,4);
t0_bar = length(gm);
r_gm = xcorr(gm,gm);
N1 = floor(length(h_T)/2);
N2 = N1;
M1 = 6;
D = 4;
M2 = N2 + M1 - 1 - D;

for i=1:length(SNR_vect)
    snr_db = SNR_vect(i);
    snr_lin = 10^(snr_db/10);
    [r_c, sigma_w, ~] = channel_sim(in_bits, snr_db, sigma_a);
    r_c = r_c + w(:,i);
    
    % Filtering received signal
    r_c_prime = filter(gm,1,r_c);
    
    r_c_prime = r_c_prime(t0_bar:end);
    x = downsample(r_c_prime,4);

    rw_tilde = sigma_w/4 .* downsample(r_gm, 4);
    
	[c_opt, Jmin] = Adaptive_DFE(h_T, rw_tilde, sigma_a, M1, M2, D);
    
    psi = conv(c_opt, h_T);
    psi = psi/max(psi);

    b = - psi(end - M2 + 1:end);
    detected = equalization_DFE(x, c_opt, b, M1, M2, D);

    errors(i) = length(find(in_bits(1:length(detected))~=detected));
    Pe_DFE(i) = errors(i)/length(in_bits(1:length(detected)));
end

figure();
semilogy(SNR_vect, Pe_DFE, 'b'); grid on;
ylim([10^-4 10^-1]); xlim([8 14]);
legend('MF+DFE@T'); set(legend,'Interpreter','latex');

% save('Pe_DFE.mat','Pe_DFE');