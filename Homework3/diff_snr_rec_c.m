clc; close all; clear global; clearvars;

% Input
load('Useful.mat');
load('GAA_filter.mat');
SNR_vect = 8:14;
Pe_AA_GM = zeros(length(SNR_vect),1);
errors = zeros(length(SNR_vect),1);
sigma_a = 2;

qg_up = conv(qc, g_AA);
qg_up = qg_up.';
t0_bar = find(qg_up == max(qg_up));

qg = downsample(qg_up(1:end), 2);
g_m = conj(flipud(qg));

h = conv(qg, g_m);
h = h(h ~= 0);

r_g = xcorr(conv(g_AA, g_m));

N1 = floor(length(h)/2);
N2 = N1;
M1 = 10;
D = 4;
M2 = N2 + M1 - 1 - D;

for i=1:length(SNR_vect)
    snr_db = SNR_vect(i);
    snr_lin = 10^(snr_db/10);
    [r_c, sigma_w, ~] = channel_sim(in_bits, snr_db, sigma_a);
    r_c = r_c + w(:,i);

	r_c_prime = filter(g_AA , 1, r_c);

	x = downsample(r_c_prime(t0_bar:end), 2);

	x_prime = filter(g_m, 1, x);
	x_prime = x_prime(13:end);

	%% Equalization and symbol detection

	N0 = (sigma_a * 1) / (4 * snr_lin);
	r_w = N0 * downsample(r_g, 2);
	[c, Jmin] = WienerC_frac(h, r_w, sigma_a, M1, M2, D, N1, N2);
	psi = conv(h,c);

	psi_down = downsample(psi(2:end),2); % The b filter act at T
	b = -psi_down(find(psi_down == max(psi_down)) + 1:end); 
	x_prime = x_prime/max(psi);
	detected = equalization_pointC(x_prime, c, b, D);
	detected = detected(1:end-D);
	in_bits_2 = in_bits(1:length(detected));
	errors(i) = length(find(in_bits_2~=detected(1:length(in_bits_2))));
    Pe_AA_GM(i) = errors(i)/length(in_bits_2);
end

figure();
semilogy(SNR_vect, Pe_AA_GM, 'k--'); grid on;
ylim([10^-4 10^-1]); xlim([8 14]);
legend('AAF+MF+DFE@$\frac{T}{2}$'); set(legend,'Interpreter','latex');

% save('Pe_AA_GM.mat','Pe_AA_GM');