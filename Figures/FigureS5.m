function FigureS5(pathname)

graphics_style_paper;
rng(1)

n = 1000;
lb = 0; ub = 1;
D = 1;
x = linspace(lb, ub, n);
d =1;
ntr = 100;

x0 = x(:,1);

kernelfun =  @Matern52_kernelfun;%kernel used within the preference learning kernel, for subject = computer
kernelname = 'Matern52';

link = @normcdf; %inverse link function for the classification model


theta.cov=  [-1;1];
theta.mean = 0;

modeltype = 'exp_prop'; % Approximation method
meanfun = @constant_mean;
link = @normcdf; %inverse link function for the classification model
 regularization = 'nugget';
   
hyps.ncov_hyp =2; % number of hyperparameters for the covariance function
hyps.nmean_hyp =1; % number of hyperparameters for the mean function
hyps.hyp_lb = -10*ones(hyps.ncov_hyp  + hyps.nmean_hyp,1);
hyps.hyp_ub = 10*ones(hyps.ncov_hyp  + hyps.nmean_hyp,1);
model = gp_classification_model(D, meanfun, kernelfun, regularization, hyps, lb, ub, 'classification', link, modeltype, kernelname);


post = [];
model.D = 1;
regularization = 'none';

g = 4*mvnrnd(zeros(1,n),kernelfun(theta.cov, x, x, 'false', regularization));


if strcmp(model.kernelname, 'Matern52') || strcmp(model.kernelname, 'Matern32') || strcmp(model.kernelname, 'ARD')
    approximation.method = 'RRGP';
else
    approximation.method = 'SSGP';
end
approximation.decoupled_bases = 1;
approximation.nfeatures = 4096;

model = approximate_kernel(model, theta, approximation);


task = 'max';
hyps_update = 'none';
link = @normcdf;
identification = 'mu_c';
maxiter = 0;
nopt = 0;
ninit = 0;
update_period = 0;
acquisition_fun = '';
ns = 0;
optimization = binary_BO(g, task, identification, maxiter, nopt, ninit, update_period, hyps_update, acquisition_fun, model.D, ns);

 

rd_idx = randsample(n, ntr-80, 'true');
rd_idx = [rd_idx; randsample(850:980, 80, 'true')'];
    
xtrain = x(:,rd_idx);
 ytrain = g(rd_idx);
 ctrain = link(ytrain)>rand(1,ntr);

post = model.prediction(theta, xtrain(:,1:ntr), ctrain(1:ntr), [], post);

[mu_c,  mu_y, sigma2_y, Sigma2_y, dmuc_dx, dmuy_dx, dsigma2y_dx, dSigma2y_dx, var_muc] = model.prediction(theta, xtrain, ctrain, x, post);


g_grid = @(xt) g(dsearchn(x', xt'));


legend_pos = [-0.15,1];
Y = normcdf(mvnrnd(mu_y,Sigma2_y,5000));
[new_EI, new_EI_norm, EI] = EI_Tesch(theta, xtrain, ctrain, model, post, approximation, optimization);
[new_TS, new_TS_norm, TS] = TS_binary(theta, xtrain, ctrain, model, post, approximation, optimization);
[new_UCB, new_UCB_norm, UCB] = UCB_binary(theta, xtrain, ctrain, model, post, approximation, optimization);
[new_UCBf, new_UCBf_norm, UCBf] = UCB_binary_latent(theta, xtrain, ctrain, model, post, approximation, optimization);


[mu_c,  mu_y, sigma2_y, Sigma2_y, dmuc_dx, dmuy_dx, dsigma2y_dx, dSigma2y_dx, var_muc] = model.prediction(theta, xtrain, ctrain, x, post);



mr = 2;
mc = 2;
fig=figure('units','centimeters','outerposition',1+[0 0 fwidth fheight(mr)]);
fig.Color =  background_color;
layout1 = tiledlayout(mr,mc, 'TileSpacing', 'compact', 'padding','compact');
i = 0;
Xlim = [0,1];

nexttile();
i=i+1;
[p1, p2] = plot_distro(x, mu_c, Y, C(3,:), C(1,:), linewidth); hold on;
h4 = scatter(new_UCB, 0, 10*markersize, 'b','x','LineWidth',1.5); hold on;
h5 = scatter(new_UCBf, 0, 10*markersize, 'k','x','LineWidth',1.5); hold on;


xlabel('$x$', 'Fontsize', Fontsize)
ylabel('$P(c=1|x)$', 'Fontsize', Fontsize)
set(gca,'XTick',[0 0.5 1],'Fontsize', Fontsize)
ytick = get(gca,'YTick');
set(gca,'YTick', linspace(min(ytick), max(ytick), 3), 'Fontsize', Fontsize)
box off

[a,b] = min(abs(x-new_UCB));
 vline(new_UCB,'Linewidth',linewidth, 'ymax', mu_c(b),  'LineStyle', '--', ...
    'Linewidth', 1, 'Color', 'b');  

[a,b] = min(abs(x-new_UCBf));
 vline(new_UCBf,'Linewidth',linewidth, 'ymax', mu_c(b),  'LineStyle', '--', ...
    'Linewidth', 1, 'Color', 'k'); hold off;

legend([p2, p1, h4, h5], '$p(\Phi(f(x))|\mathcal{D})$', '$\mu_c(x)$' ,'UCB$_\Phi$','UCB$_f$')
legend box off
text(legend_pos(1), legend_pos(2),['$\bf{', letters(1), '}$'],'Units','normalized','Fontsize', letter_font)

 


fig_n = nexttile();
i=i+1;
[p1, p2] = plot_gp(x, mu_y, sigma2_y, C(1,:),linewidth); hold on;
xl = get(fig_n , 'ylim');
h4 = scatter(new_UCB, xl(1), 10*markersize, 'b','x','LineWidth',1.5); hold on;
h5 = scatter(new_UCBf, xl(1), 10*markersize, 'k','x','LineWidth',1.5); hold on;
box off
xlabel('$x$', 'Fontsize', Fontsize)
ylabel('$f(x)$', 'Fontsize', Fontsize)
set(gca,'XTick',[0 0.5 1],'Fontsize', Fontsize)
ytick = get(gca,'YTick');
set(gca,'YTick', linspace(min(ytick), max(ytick), 3), 'Fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(2), '}$'],'Units','normalized','Fontsize', letter_font)
[a,b] = min(abs(x-new_UCB));
 vline(new_UCB,'Linewidth',linewidth, 'ymax', mu_y(b),  'LineStyle', '--', ...
    'Linewidth', 1, 'Color', 'b');  

[a,b] = min(abs(x-new_UCBf));
 vline(new_UCBf,'Linewidth',linewidth, 'ymax', mu_y(b),  'LineStyle', '--', ...
    'Linewidth', 1, 'Color', 'k'); hold off;

legend(p1, '$p(f(x)|\mathcal{D})$')
legend box off
 
nexttile();
e = norminv(0.99);
sigma_c = sqrt(var_muc);
ucb_val = mu_c + e*sigma_c;
h2 = plot(x, ucb_val, 'Color',  C(2,:),'LineWidth', linewidth); hold on;
 ylabel('$\alpha(x)$')
box off
xlabel('$x$')
% set(gca, 'Xlim', [0,1], 'Xtick', [0,0.5,1], 'Ylim', yl, 'Ytick', floor([yl(1), 0, yl(2)]), 'Fontsize', Fontsize');
text(legend_pos(1), legend_pos(2),['$\bf{', letters(3), '}$'],'Units','normalized','Fontsize', letter_font)
 xlabel('$x$', 'Fontsize', Fontsize)
ylabel('UCB$_\Phi(x)$', 'Fontsize', Fontsize)
set(gca,'XTick',[0 0.5 1],'Fontsize', Fontsize)
ytick = get(gca,'YTick');
set(gca,'YTick', linspace(min(ytick), max(ytick), 3), 'Fontsize', Fontsize)

[max_y, b] = max(ucb_val);
max_x = x(b);
vline(max_x,'Linewidth',linewidth, 'ymax', max_y,  'LineStyle', '--', ...
    'Linewidth', 1, 'Color', 'b'); hold off;


nexttile();
sigma_y = sqrt(sigma2_y);
e = 1; % 1 is used in the original paper by Tesch et al (2013). norminv(0.975);
e = norminv(0.99);
ucb_val = mu_y + e*sigma_y;

h2 = plot(x, ucb_val, 'Color',  C(2,:),'LineWidth', linewidth); hold on;
 ylabel('$\alpha$')
box off
xlabel('$x$')
 text(legend_pos(1), legend_pos(2),['$\bf{', letters(4), '}$'],'Units','normalized','Fontsize', letter_font)
 xlabel('$x$', 'Fontsize', Fontsize)
ylabel('UCB$_f(x)$', 'Fontsize', Fontsize)
set(gca,'XTick',[0 0.5 1],'Fontsize', Fontsize)
ytick = get(gca,'YTick');
set(gca,'YTick', linspace(min(ytick), max(ytick), 3), 'Fontsize', Fontsize)
[max_y, b] = max(ucb_val);
max_x = x(b);
vline(max_x,'Linewidth',linewidth, 'ymax', max_y,  'LineStyle', '--', ...
    'Linewidth', 1); hold off;

 
folder = [pathname, '/Figures'];
figname  = 'FigureS5';
savefig(fig, [folder,'/', figname, '.fig'])
exportgraphics(fig, [folder,'/' , figname, '.pdf']);
exportgraphics(fig, [folder,'/' , figname, '.png'], 'Resolution', 300);

