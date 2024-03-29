function uncertainty(pathname)

folder = [pathname, '/Figures'];
n=100;

rng(2)
graphics_style_paper;

colo= othercolor('GnBu7');

link = @normcdf;


%%

N = 100;
sigma2_y_range = linspace(0,10,N);
mu_y_range = linspace(-8,8,N);
h = @(p) -p.*log(p+eps) - (1-p).*log(1-p+eps);

[p,q]= meshgrid(mu_y_range, sigma2_y_range);

inputs  = [p(:),q(:)]';
sigma2_y = inputs(2,:);
mu_y = inputs(1,:);

mu_c = normcdf(mu_y./sqrt(1+sigma2_y));
C = sqrt(pi*log(2)/2);
I1 = h(mu_c);
I2 =  log(2)*C.*exp(-0.5*mu_y.^2./(sigma2_y+C^2))./sqrt(sigma2_y+C^2);
I = I1 - I2;

h = mu_y./sqrt(1+sigma2_y);
a = 1./sqrt(1+2*sigma2_y);

[tfn_output, dTdh, dTda] = tfn(h, a);
var_muc = (mu_c - 2*tfn_output) - mu_c.^2;


aleatoric_unvar=2*tfn_output;
%%


legend_pos = [-0.2,1.1];
i=0;
mr = 2;
mc = 3;
fwidth = 8.255;
fig=figure('units','centimeters','outerposition',1+[0 0 fwidth 0.6*fheight(mr)]);
fig.Color =  background_color;
tiledlayout(mr,mc, 'TileSpacing', 'tight', 'padding','compact');

maxI = max([var_muc, aleatoric_unvar, aleatoric_unvar+var_muc]);


nexttile();
i=i+1;
imagesc(mu_y_range, sigma2_y_range, reshape(aleatoric_unvar+var_muc,N,N)); hold on;
% xlabel('$\mu_f(x)$','Fontsize',Fontsize)
ylabel('$\sigma^2_f(x)$','Fontsize',Fontsize)
set(gca,'YDir','normal','CLim',[0, maxI])
pbaspect([1 1 1])
title('V$(c|x, \mathcal{D})$')
set(gca, 'fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)


nexttile();
i=i+1;
imagesc(mu_y_range, sigma2_y_range, reshape(var_muc,N,N)); hold on;
set(gca,'YDir','normal','CLim',[0, maxI])
pbaspect([1 1 1])
title('V$[\Phi(f(x))|\mathcal{D}]$')
set(gca, 'fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)


nexttile();
i=i+1;
imagesc(mu_y_range, sigma2_y_range, reshape(aleatoric_unvar,N,N)); hold on;
set(gca,'YDir','normal','CLim',[0, maxI])
pbaspect([1 1 1])
title('E$_f$[V$(c|x, f)|\mathcal{D}]$')
set(gca, 'fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)

cb = colorbar;
set(cb, 'Limits', [0, maxI])
cb.FontName = 'CMU Serif';
cb.FontSize = Fontsize;
colormap(cmap)


maxI = max([I1, I2, I]);

nexttile();
imagesc(mu_y_range, sigma2_y_range, reshape(I1,N,N)); hold on;
i=i+1;
xlabel('$\mu_f(x)$','Fontsize',Fontsize)
ylabel('$\sigma^2_f(x)$','Fontsize',Fontsize)
set(gca,'YDir','normal','CLim',[0, maxI])
set(gca,'YDir','normal')
pbaspect([1 1 1])
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)
title('H$(c|x, \mathcal{D})$')
set(gca, 'fontsize', Fontsize)

nexttile();
imagesc(mu_y_range, sigma2_y_range, reshape(I,N,N)); hold on;
i=i+1;
xlabel('$\mu_f(x)$','Fontsize',Fontsize)
set(gca,'YDir','normal','CLim',[0, maxI])
pbaspect([1 1 1])
title('I$(c,f(x)|\mathcal{D})$')
set(gca, 'fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)

nexttile();
imagesc(mu_y_range, sigma2_y_range, reshape(I2,N,N)); hold on;
i=i+1;
xlabel('$\mu_f(x)$','Fontsize',Fontsize)
set(gca,'YDir','normal','CLim',[0, maxI])
set(gca,'YDir','normal')
pbaspect([1 1 1])
title('E$_f[H(c|x, f)|\mathcal{D}]$')
set(gca, 'fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)

cb = colorbar;
cb.FontName = 'CMU Serif';
cb.FontSize = Fontsize;
set(cb, 'Limits', [0, maxI])
set(get(cb,'Title'),'String','(nats)', 'Interpreter', 'latex')

figname  = 'Figure1';
if ~isfolder(folder)
    mkdir(folder)
end
savefig(fig, [folder,'/', figname, '.fig'])
exportgraphics(fig, [folder,'/' , figname, '.pdf']);
exportgraphics(fig, [folder,'/' , figname, '.png'], 'Resolution', 300);

