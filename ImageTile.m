%plot images in tiled layout

tiledlayout(1,4)

nexttile
imagesc(v_dopp_0mmps(:,300:800)'*1000)
caxis([-10 10])
title('0 mm/s')
xlabel('X, pixels')
ylabel('Z, pixels')

nexttile
imagesc(v_dopp_0p125mmps(:,300:800)'*1000)
caxis([-10 10])
title('0.125 mm/s')
xlabel('X, pixels')
ylabel('Z, pixels')

nexttile
imagesc(v_dopp_0p25mmps(:,300:800)'*1000)
caxis([-10 10])
title('0.25 mm/s')
xlabel('X, pixels')
ylabel('Z, pixels')

nexttile
imagesc(v_dopp_0p5mmps(:,300:800)'*1000)
caxis([-10 10])
c = colorbar();
title('0.5 mm/s')
xlabel('X, pixels')
ylabel('Z, pixels')
c.Label.String = 'Velocity, mm/s';

