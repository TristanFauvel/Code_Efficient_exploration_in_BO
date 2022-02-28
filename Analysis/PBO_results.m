function PBO_results(pathname)

data_dir =  [pathname,'/Data/Data_PBO'];
figure_folder = [pathname,'/Figures/'];

figname =  'Figure2';

load('benchmarks_table.mat')
objectives = benchmarks_table.fName;

 
settings= load([pathname, '/Experiments_parameters.mat'],'Experiments_parameters');
settings = settings.Experiments_parameters;
settings = settings({'PBO'},:);

% List of acquisition functions tested in the experiment
acq_funs = settings.acquisition_funs{:};
maxiter = settings.maxiter;
nreplicates = settings.nreplicates;
task =  settings.task{:};
identification = settings.identification{:};
load('Acquisition_funs_table','T')
acquisition_funs = cellstr(char(T(any(T.acq_funs == acq_funs,2),:).acq_funs));
acquisition_names = char(T(any(T.acq_funs == acq_funs,2),:).names);
acquisition_names_citation = char(T(any(T.acq_funs == acq_funs,2),:).names_citations);
short_acq_names= char(T(any(T.acq_funs == acq_funs,2),:).short_names);


objectives = settings.objectives{:};

prefix = [task, '_'];

[t, Best_ranking, AUC_ranking,b,signobj,ranking, final_values, AUCs] = ranking_analysis(data_dir,...
    acquisition_names_citation, objectives, acquisition_funs , nreplicates, maxiter, [], prefix, task, 'score');

table2latex(t,[figure_folder,'PBO_benchmarks_results'])



mr = 2;
mc= 1;
legend_pos = [-0.1,1];
i=0;
graphics_style_paper;
fig=figure('units','centimeters','outerposition',1+[0 0 fwidth(mc) fheight(mr)]);
fig.Color =  background_color;
tiledlayout(mr, mc, 'TileSpacing', 'compact', 'padding','compact');
nexttile()
mat = flipud(Best_ranking);
p =  plot_matrix(mat, {}, short_acq_names(b,:));
i=i+1;
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)


nexttile()
mat = flipud(AUC_ranking);
p =  plot_matrix(mat, short_acq_names(b,:), short_acq_names(b,:));
i=i+1;
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)

figname  = 'FigureS3';
figure_file = [figure_folder,'/' figname];
exportgraphics(fig, [figure_file, '.pdf']);


acq_funs = {'Dueling_UCB', 'MUC', 'bivariate_EI', 'DTS', 'Thompson_challenge'};
acquisition_funs = cellstr(char(T(any(T.acq_funs == acq_funs,2),:).acq_funs)); 
acquisition_names = char(T(any(T.acq_funs == acq_funs,2),:).names); 
acquisition_names_citation = char(T(any(T.acq_funs == acq_funs,2),:).names_citations); 
short_acq_names= char(T(any(T.acq_funs == acq_funs,2),:).short_names); 

[~,~,~,~,signobj] = ranking_analysis(data_dir, acquisition_names_citation, objectives, acquisition_funs, nreplicates, maxiter, [], [], 'max', 'score');
s =[1,14,34];

objectives = benchmarks_table.fName; 
objectives_names = benchmarks_table.Name; 
objectives = objectives(s);
objectives_names = objectives_names(s);

 clear('lines')
 lines(:) = {'-',':',':',':',':'};

 rescaling = 0;
fig = plot_optimalgos_comparison(objectives, objectives_names, acquisition_funs, char(acquisition_names), figure_folder,data_dir, figname, nreplicates, maxiter, rescaling, [], [], 'max', 'score',lines, []);

figname  = 'FigureS3';
figure_file = [figure_folder, figname];
exportgraphics(fig, [figure_file, '.pdf']);
