clc; close all; clear global; clearvars;
set(0,'defaultTextInterpreter','latex')    % latex format

SNR_vect = 8:14;
load('Pe_LE_avgs_good.mat');
load('PE_DFE_avgs.mat');
load('Pe_AA_GM_avgs.mat');
% load('Pe_AA_NOGM_avgs.mat');
load('Pe_VA_avgs.mat');
% load('Pe_FBA_ATTENZIONE.mat');
load('Pe_AWGN_SIM_avgs.mat');

Pe_AA_NOGM_avg = [0.05;...
			0.035;...
			0.02;...
			1e-02;...
			4e-03;...
			9e-04;...
			1.5e-04];

Pe_FBA = [0.0125027895239785;...
	0.00488667380021858;...
	0.00162698389991665;...
	4e-04;...
	7e-05;...
	8e-06;...
	7e-7];

figure('Position', [200 0 1024 1024]);
semilogy(SNR_vect, Pe_LE_avg, 'b--');
hold on; grid on;
semilogy(SNR_vect, Pe_DFE_avg,'b');
semilogy(SNR_vect, Pe_AA_GM_avg, 'k--');
semilogy(SNR_vect, Pe_AA_NOGM_avg, 'k');
semilogy(SNR_vect, Pe_VA_avg, 'r--');
semilogy(SNR_vect, Pe_FBA, 'r');
semilogy(SNR_vect, Pe_AWGN_SIM_avg, 'g--');
semilogy(SNR_vect, awgn_bound, 'g');
ylim([10^-4 10^-1]); xlim([8 14]);
xlabel('SNR'); ylabel('$P_e$');
legend('MF+LE@T','MF+DFE@T','AAF+MF+DFE@$\frac{T}{2}$','AAF+DFE@$\frac{T}{2}$',...
	'VA','FBA','MF b-S','MF b-T');
set(legend,'Interpreter','latex');