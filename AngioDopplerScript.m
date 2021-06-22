%Doppler processing of BM-scan data
data = ProcessSpectralInterferogram(4096)
data.SweepFrequency = 90.1e3; %This is wrong for some reason in the raw data. Need to investigate this.
dt = 1/data.SweepFrequency;
lambda = 1685e-9 %got this from spec sheet on demo laser so probably not correct for
theta = pi/4; %need to set this based on your experimental geometry

%% get image theshold
Morph = squeeze(mean(data.mag,1));
[threshold, mask] = SetImageThreshold(log10(Morph));
figure(1);imagesc(log10(Morph)')

%% calculate dphi
Delta = diff(unwrap(data.phase,1));
dphi = squeeze(mean(Delta,1)).*mask;
v_dopp = dphi * lambda/(4*pi*dt)/cos(theta);
figure(2);imagesc(v_dopp'*1000);
c = colorbar;
c.Label.String = 'Velocity (mm/s)';
