pathname = '..';
data_dir =  [pathname,'/Data/Data_batch_PBO'];
figure_folder = [pathname,'/Figures/'];

figname =  'Figure3';

 
load('benchmarks_table.mat')
objectives = benchmarks_table.fName;
objectives_names = benchmarks_table.Name;
nobj =numel(objectives);

acq_funs = {'random_acquisition_tour','kernelselfsparring_tour','batch_MUC'};

 load('Acquisition_funs_table','T')
acquisition_funs = cellstr(char(T(any(T.acq_funs == acq_funs,2),:).acq_funs));
acquisition_names = char(T(any(T.acq_funs == acq_funs,2),:).names);
acquisition_names_citation = char(T(any(T.acq_funs == acq_funs,2),:).names_citations);
short_acq_names= char(T(any(T.acq_funs == acq_funs,2),:).short_names);



objectives = benchmarks_table.fName;


nreps = 30;  
maxiter = 30;
feedback ='all';  %'all' 
suffix = ['_',feedback];
score_measure = 'score';
optim = 'max';

[t, Best_ranking, AUC_ranking,b, signobj, ranking, final_values, AUCs] = ranking_analysis(data_dir, char(acquisition_names_citation), objectives, acquisition_funs, nreps, suffix, prefix, optim, score_measure);

table2latex(t, [figure_folder,'batch_BO_benchmark_results'])


s = [18,28,34];
objectives = benchmarks_table.fName; 
objectives_names = benchmarks_table.Name; 
objectives = objectives(s);
objectives_names = objectives_names(s);
rescaling= 0;
% plot_optimalgos_comparison_TBO(objectives, objectives_names, acquisition_funs, acquisition_names, figure_folder,data_dir, [figname,suffix],  nreps, maxiter,rescaling, feedback)

lines = {'-', ':', ':'};
fig =  plot_optimalgos_comparison(objectives, objectives_names, acquisition_funs, acquisition_names, figure_folder,data_dir, figname, nreps, maxiter, rescaling, suffix, prefix, optim, score_measure, lines, [])
figname  = 'optim_trajectory_batch_PBO';
exportgraphics(fig, [figure_folder, figname, '.pdf']);


mr = 1;
mc= 2;
legend_pos = [-0.1,1];
i=0;
graphics_style_paper;
fig=figure('units','centimeters','outerposition',1+[0 0 fwidth(1) fheight(mr)]);
fig.Color =  background_color;
tiledlayout(mr, mc, 'TileSpacing', 'compact', 'padding','compact');
nexttile()
mat = flipud(Best_ranking);
p =  plot_matrix(mat, short_acq_names(b,:),short_acq_names(b,:));
i=i+1;
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)


nexttile()
mat = flipud(AUC_ranking);
p =  plot_matrix(mat, short_acq_names(b,:), {});
i=i+1;
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)


figname  = 'FigureS4';
exportgraphics(fig, [figure_folder, figname, '.pdf']);

