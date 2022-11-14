currentFile = mfilename( 'fullpath' );
[pathname,~,~] = fileparts( currentFile ); %pathname = '/home/tristan/Desktop/Code_Efficient_exploration_in_BO-dev'

addpath(genpath(pathname))
suffix = ''; %-dev'
addpath(genpath([fileparts(pathname), '/GP_toolbox',suffix]))
addpath(genpath([fileparts(pathname), '/BO_toolbox',suffix]))


%%

ExpName= {'BBO'; 'PBO'; 'batch_PBO'; 'sensitivity_BBO'};
maxiter =  [100;60;30;60]; % Number of iterations
nreplicates = [20;60;30;60]; % Number of experiments replicates;

%%
% maxiter =  [10;10;10;10]; % Number of iterations
% nreplicates = [1;1;1;1]; % Number of experiments replicates;

%%
rescaling = logical([1;1;1;1]); % Whether or not to rescale objective functions

ExpName= {'BBO'; 'PBO'; 'batch_PBO'; 'sensitivity_BBO'};
maxiter =  [10;10;10;10]; % Number of iterations
nreplicates = [1;1;1;1]; % Number of experiments replicates;


nopt = [5;5;5;5]; % Number of time steps before starting using acquisition functions
ninit = [5;5;5;5]; % Number of time steps before updating hyperparameters
update_period = maxiter+[1;1;1;1]; % Hyperparameters update frequency
task = {'max'; 'max'; 'max'; 'max'};
hyps_update = {'none';'none';'none';'none'};
link = {@normcdf; @normcdf; @normcdf;@normcdf};
modeltype = {'exp_prop'; 'exp_prop'; 'exp_prop';'exp_prop'};
identification = {'mu_c';'mu_c';'mu_c';'mu_c'};
ns = [0;0;0;0];
load('benchmarks_table.mat')
objectives = {benchmarks_table.fName; benchmarks_table.fName; benchmarks_table.fName; benchmarks_table.fName};  
objectives_names = {benchmarks_table.Name;benchmarks_table.fName;benchmarks_table.fName;benchmarks_table.fName};

acquisition_funs = {{'EI_Tesch', 'TS_binary','random_acquisition', 'UCB_binary', 'UCB_binary_latent'}; ...
    {'Dueling_UCB_Phi','kernelselfsparring','bivariate_EI','Dueling_UCB','EIIG','random_acquisition_pref',...
    'MUC','Brochu_EI', 'Thompson_challenge','DTS', 'MaxEntChallenge'};...
    {'random_acquisition_tour','kernelselfsparring_tour','batch_MUC'} ; {'UCB_binary', 'UCB_binary_latent'}};

accessory_parameters = {[];[];[3, 5, 7];  [0.1, 1, 10]};

 
Experiments_parameters = table(maxiter, nreplicates, rescaling, nopt, ninit, update_period, task, hyps_update, ...
    link, modeltype, identification, ns, acquisition_funs, accessory_parameters, objectives, objectives_names, 'RowNames', ExpName);

save([pathname, '/Experiments_parameters.mat'],'Experiments_parameters')

%%
PBO_benchmarks(pathname)
BBO_benchmarks(pathname)
batch_PBO_benchmarks(pathname)
sensitivity_analysis_BBO(pathname)

uncertainty(pathname)
BBO_results(pathname)
PBO_results(pathname)

batch_size_range = [3,5,7];
for batch_size = batch_size_range
    batch_PBO_results(pathname, batch_size)
end

FigureS5(pathname)
FigureS6(pathname)

sensitivity_analysis_results(pathname)