clear all
add_bo_module;
graphics_style_paper;
folder = './Figures/';

close all
rng(1)

 
  
n = 3000;
lb = 0; ub = 1;
x = linspace(lb, ub, n);

x0 = 0;
x2d = [x;x0*ones(1,n)];

%%
D =1;
ntr = 50;

condition.x0 =x0;
condition.y0 = 0;
theta.cov= [4;-2];
theta.mean = 0;

modeltype = 'exp_prop'; % Approximation method
kernelfun =  @ARD_kernelfun;%kernel used within the preference learning kernel, for subject = computer
kernelname = 'ARD';
meanfun = @constant_mean;
link = @normcdf; %inverse link function for the classification model
 regularization = 'nugget';
   
hyps.ncov_hyp =2; % number of hyperparameters for the covariance function
hyps.nmean_hyp =1; % number of hyperparameters for the mean function
hyps.hyp_lb = -10*ones(hyps.ncov_hyp  + hyps.nmean_hyp,1);
hyps.hyp_ub = 10*ones(hyps.ncov_hyp  + hyps.nmean_hyp,1);
model = gp_preference_model(D, meanfun, kernelfun, regularization, hyps, lb, ub, 'preference', link, modeltype, kernelname, condition);
 
post = [];
regularization = 'none';

cond_base_kernelfun = @(theta, xi, xj, training, reg) conditioned_kernelfun(theta, kernelfun, xi, xj, training, condition.x0,reg);
g =mvnrnd(zeros(1,n),cond_base_kernelfun(theta.cov, x, x, 'false', regularization));

approximation.method = 'SSGP';
approximation.nfeatures = 4096;
approximation.decoupled_bases= 1;
[approximation.phi_pref, approximation.dphi_pref_dx, approximation.phi, approximation.dphi_dx]= sample_features_preference_GP(theta, model, approximation);


f = g;

g_grid = @(xt) g(dsearchn(x', xt'));

 
rng(1) %2
rd_idx = randsample(size(x2d,2), ntr, 'true');
xtrain= x2d(:,rd_idx);
ytrain= f(rd_idx)';
ctrain = link(ytrain)>rand(ntr,1);


post = model.prediction(theta, xtrain, ctrain, [], post);

rng(1)
nsamples = 4;

KSSx = kernelselfsparring_tour(theta, xtrain, ctrain, model, post, approximation, nsamples);
MVTx = MVT(theta, xtrain, ctrain, model, post, approximation, nsamples);
x1 = MVTx(1);


 
%%
[mu_c,  mu_y, sigma2_y, Sigma2_y, dmuc_dx, dmuy_dx, dsigma2y_dx, dSigma2y_dx, var_muc] = model.prediction(theta, xtrain(:,1:ntr), ctrain(1:ntr), [x;x1*ones(1,n)], post);

mr = 1;
mc = 2;
 
legend_pos = [-0.15,1];
Y = normcdf(mvnrnd(mu_y,Sigma2_y,5000));
fig=figure('units','centimeters','outerposition',1+[0 0 fwidth fheight(1)]);
fig.Color =  background_color;
layout1 = tiledlayout(mr,mc, 'TileSpacing', 'tight', 'padding','compact');
i = 0;
Xlim = [0,1];

nexttile();
i=i+1;
[p1, p2] = plot_distro(x, mu_c, Y, C(3,:), C(1,:), linewidth); hold on;
p3 = plot(x, normcdf(g - g_grid(x1)),'color', C(2,:), 'linewidth', linewidth);
xlabel('$x$', 'Fontsize', Fontsize)
ylabel('$P(x>x_1)$', 'Fontsize', Fontsize)
set(gca,'XTick',[0 0.5 1],'Fontsize', Fontsize)
ytick = get(gca,'YTick');
set(gca,'YTick', linspace(min(ytick), max(ytick), 3), 'Fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)
box off
s1 = scatter(KSSx , normcdf(g_grid(KSSx)- g_grid(x1)), 10*markersize, C(1,:), '+','LineWidth',1.5); hold on;
s2 = scatter(MVTx , normcdf(g_grid(MVTx)- g_grid(x1)), 10*markersize, C(2,:), '+','LineWidth',1.5); hold on;

legend([p3, p2, p1, s1, s2], '$P(x>x_1)$', '$p(\Phi[g(x,x_1)]|\mathcal{D})$', '$\mu_c(x,x_1)$', 'KernelSelfSparring', 'MUC','NumColumns',2)
legend box off

nsamples = 25;
KSSx = kernelselfsparring_tour(theta, xtrain(:,1:ntr), ctrain(1:ntr), model, post, approximation, nsamples);
MVTx = MVT(theta, xtrain(:,1:ntr), ctrain(1:ntr), model, post, approximation, nsamples);
  text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)

nexttile();
i=i+1;
[p1, p2] = plot_distro(x, mu_c, Y, C(3,:), C(1,:), linewidth); hold on;
p3 = plot(x, normcdf(g - g_grid(x1)),'color', C(2,:), 'linewidth', linewidth);
xlabel('$x$', 'Fontsize', Fontsize)
ylabel('$P(x>x_1)$', 'Fontsize', Fontsize)
set(gca,'XTick',[0 0.5 1],'Fontsize', Fontsize)
ytick = get(gca,'YTick');
set(gca,'YTick', linspace(min(ytick), max(ytick), 3), 'Fontsize', Fontsize)
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)
box off
s1 = scatter(KSSx , normcdf(g_grid(KSSx)- g_grid(x1)), 10*markersize, C(1,:), '+','LineWidth',1.5); hold on;
s2 = scatter(MVTx , normcdf(g_grid(MVTx)- g_grid(x1)), 10*markersize, C(2,:), '+','LineWidth',1.5); hold on;

legend([p3, p2, p1, s1, s2], '$P(x>x_1)$','$p(\Phi[g(x,x_1)]|\mathcal{D})$', '$\mu_c(x,x_1)$', 'KernelSelfSparring', 'MUC','NumColumns',2)
legend box off
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)

figname  = 'FigureS6';
savefig(fig, [folder,'/', figname, '.fig'])
exportgraphics(fig, [folder,'/' , figname, '.pdf']);
exportgraphics(fig, [folder,'/' , figname, '.png'], 'Resolution', 300);

