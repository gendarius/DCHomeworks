clc; close all; clear global; clearvars;
set(0,'defaultTextInterpreter','latex');

load('Useful.mat', 'in_bits', 'qc', 'E_qc');

SNR_vect = 8:14;
sigma_a = 2;
M = 4;
gm = conj(qc(end:-1:1));
h = conv(qc,gm);
t0_bar = find(h == max(h));
h_T = downsample(h,4);
r_gm = xcorr(gm,gm);
in_bits_2  =  in_bits(1+4-0 : end-4+4-2);
realizations = 1:10;
Pe_VA_avg = zeros(length(SNR_vect),1);
Pe_VA = zeros(length(realizations),1);
M1 = 5;
N2 = floor(length(h_T)/2);
D = 2;
M2 = N2 + M1 - 1 - D;

for i=1:length(SNR_vect)
	Pe_VA = zeros(length(SNR_vect),1);
	for k=1:length(realizations)
		snr_db = SNR_vect(i);
		snr_lin = 10^(snr_db/10);
		[r_c, sigma_w, qc] = channel_sim(in_bits, snr_db, sigma_a);
		w = wgn(length(r_c),1, 10*log10(sigma_w), 'complex');
		r_c = r_c + w;
		r_c_prime = filter(gm,1,r_c);
		r_c_prime = r_c_prime(t0_bar:end);
		x = downsample(r_c_prime,4);
		rw_tilde = sigma_w/4 .* downsample(r_gm, 4);
		[c_opt, Jmin] = Adaptive_DFE(h_T, rw_tilde, sigma_a, M1, M2, D);
		psi = conv(c_opt, h_T);
		psi = psi/max(psi);
		y = conv(x, c_opt);
		y = y/max(psi);
		detected = VBA(y, psi, 0, 2, 4, 2);
		in_bits_2  =  in_bits(1+4-0 : end-2+2);
		detected = detected.';
		detected = detected(D+1:end);
		[Pe_VA(k),~] = SER(in_bits_2(1:length(detected)), detected);
	end
	Pe_VA_avg(i) = sum(Pe_VA)/length(Pe_VA);
end

figure();
semilogy(SNR_vect, Pe_VA_avg, 'r--');
grid on;
ylim([10^-4 10^-1]); xlim([8 14]);

% save('PE_VA_avgs.mat', 'Pe_VA_avg');