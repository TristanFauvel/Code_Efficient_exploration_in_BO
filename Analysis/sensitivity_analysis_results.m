function sensitivity_analysis_results(pathname)

data_dir =  [pathname,'/Data/Data_BBO_sensitivity_analysis'];
figure_folder = [pathname,'/Figures/'];

figname =  'Figure2'; 

load('benchmarks_table.mat')
objectives = benchmarks_table.fName;
objectives_names = benchmarks_table.Name;
nobj =numel(objectives);


 
settings= load([pathname, '/Experiments_parameters.mat'],'Experiments_parameters');
settings = settings.Experiments_parameters;
settings = settings({'sensitivity_BBO'},:);

% List of acquisition functions tested in the experiment
all_acq_funs = settings.acquisition_funs{:};
maxiter = settings.maxiter;
nreplicates = settings.nreplicates;
task =  settings.task{:};
identification = settings.identification{:};


a = {};
e_range = settings.accessory_parameters{:};
i = 0;
for acquisition_name = all_acq_funs
    for e = e_range
        i=i+1;
          a{i} =  [acquisition_name{:},'_e=',num2str(e)];
    end
end

acq_funs = all_acq_funs;
% load('Acquisition_funs_table','T')
% acquisition_funs = cellstr(char(T(any(T.acq_funs == acq_funs,2),:).acq_funs));
% acquisition_names = char(T(any(T.acq_funs == acq_funs,2),:).names);
% acquisition_names_citation = char(T(any(T.acq_funs == acq_funs,2),:).names_citations);
% short_acq_names= char(T(any(T.acq_funs == acq_funs,2),:).short_names);

acquisition_funs = a;
 
for i = 1:numel(a)
    a{i} = regexprep(a{i},'_dot_','.');  
    a{i} = regexprep(a{i},'_binary_latent','_f');  
    a{i} = regexprep(a{i},'_binary','_\\Phi');  
    a{i} = regexprep(a{i},'_e=',', \\beta = ');  
end

acquisition_names = a;
acquisition_names_citation = a;
short_acq_names= a;


objectives = benchmarks_table.fName;
 
optim = '';
score_measure = 'score';
[t, Best_ranking, AUC_ranking,b, signobj] = ranking_analysis(data_dir, ...
    char(acquisition_names_citation), objectives, acquisition_funs, nreplicates,maxiter, [],[], optim,score_measure);

if ~isfolder(figure_folder)
    mkdir(figure_folder)
end
table2latex(t, [figure_folder,'BBO_sensitivity_analysis_results'])

selection = [31,32, 34];
objectives = objectives(selection,:);
objectives_names = benchmarks_table(selection,:).Name;

rescaling = 1;
lines = cell(size(acquisition_funs'));
lines(:) = {'-','-','-','-','-','-'};


plot_optimalgos_comparison(objectives, objectives_names, acquisition_funs, ...
    char(acquisition_names), figure_folder,data_dir, figname, nreplicates, maxiter,rescaling, [], [], 'max', score_measure, lines, [])


%%
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
p =  plot_matrix(mat, {}, short_acq_names(:,b));
i=i+1;
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)
nexttile()
mat = flipud(AUC_ranking);
p =  plot_matrix(mat, short_acq_names(:,b), short_acq_names(:,b));
i=i+1;
text(legend_pos(1), legend_pos(2),['$\bf{', letters(i), '}$'],'Units','normalized','Fontsize', letter_font)
figname  = 'FigureS1';
exportgraphics(fig, [figure_folder, figname, '.pdf']);


