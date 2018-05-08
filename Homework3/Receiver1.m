clc; close all; clear global; clearvars;

% Input signal
load('rec_input.mat');
T = 1;
sigma_a = 2;

snr_db = 10;
snr_lin = 10^(snr_db/10);

% Matched filter
q_mf = qc(end:-1:1);

% h
h = conv(q_mf, qc);

figure()
stem(h);

t0 = find(h==max(h));

%--------------------------------------------------------------
% m_min = 0;
% m_max = 30;
% crossvec = zeros(m_max - m_min, 1);
% for m = m_min : m_max
%     r_part = r_c(m+1 : T : m+1+T*(L-1));  % pick L samples from r, spaced by T
%     crossvec(m+1) = abs(sum(r_part.*conj(in_bits(1:L)))/L); % as in 7.269
% end
% 
% [~, m_opt] = max(crossvec);
% m_opt = m_opt - 1; % because of MATLAB indexing
% init_offs = mod(m_opt, T);
% delay = floor(m_opt / T);   % timing phase @T, that is the delay of the channel @T
%-----------------------------------------------------------------

y = filter(q_mf,1,r_c);

y = y(t0:end);
y = downsample(y,4);

detected = zeros(length(y),1);

for i=1:length(detected)
    detected(i) = QPSK_detector(y(i));
end

numerrs = 0;
for i=t0:length(detected)
    if ( detected(i) ~= in_bits(i-t0+1) )
        numerrs = numerrs + 1;
    end
end

%% reciver of page 622
[Qc, f] = freqz(qc,1,4096,'whole');
C = 





