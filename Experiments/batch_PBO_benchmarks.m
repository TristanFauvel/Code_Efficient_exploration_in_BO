function batch_PBO_benchmarks(pathname)
data_dir =  [pathname,'/Data/Data_batch_PBO/'];
 
 
settings= load([pathname, '/Experiments_parameters.mat'],'Experiments_parameters');
settings = settings.Experiments_parameters;
settings = settings({'batch_PBO'},:);

% List of acquisition functions tested in the experiment
acquisition_funs = settings.acquisition_funs{:};
maxiter = settings.maxiter;
nreplicates = settings.nreplicates;
ninit = settings.ninit;
nopt = settings.nopt;
task =  settings.task{:};
hyps_update = settings.hyps_update{:};
link = settings.link{:};
identification = settings.identification{:};
ns = settings.ns;
update_period = settings.update_period;
nacq = numel(acquisition_funs);
rescaling = settings.rescaling;
modeltype = settings.modeltype;

if rescaling ==0
    load('benchmarks_table.mat')
else
    load('benchmarks_table_rescaled.mat')
end
objectives = benchmarks_table.fName;
nobj =numel(objectives);
seeds = 1:nreplicates;
batch_size_range = settings.accessory_parameters{:}; %size of the tournaments
feedback = 'all'; %'all' best

more_repets= 0;
for j = 1:nobj
    objective = char(objectives(j));

    [g, theta, model] = load_benchmarks(objective, [], benchmarks_table, rescaling, 'preference', 'modeltype', modeltype, 'link', link);
    close all
    for a =1:nacq
        acquisition_name = acquisition_funs{a};
        acquisition_fun = str2func(acquisition_name);
        clear('xtrain', 'xtrain_norm', 'ctrain', 'score');

        for batch_size = batch_size_range
            filename = [data_dir,objective,'_',acquisition_name, '_', feedback, '_', num2str(batch_size)];


            optim  = batch_preferential_BO(g, task,identification, maxiter, nopt, ninit, update_period, hyps_update, acquisition_fun, model.D, ns, batch_size);

            if more_repets
                load(filename, 'experiment')
                n = numel(experiment.(['xtrain_',acquisition_name]));
                for k = 1:nreplicates
                    disp(['Repetition : ', num2str(n+k)])
                    seed =n+k;
                    [experiment.(['xtrain_',acquisition_name]){n+k}, experiment.(['xtrain_norm_',acquisition_name]){n+k}, experiment.(['ctrain_',acquisition_name]){n+k}, experiment.(['score_',acquisition_name]){n+k}]= optim.optimization_loop(seed, theta, model);
                end
                save(filename, 'experiment')
            else
                for r=1:nreplicates
                    seed  = seeds(r);
                    [xtrain{r}, xtrain_norm{r}, ctrain{r}, score{r}, xbest{r}] = optim.optimization_loop(seed, theta, model);
                end
                 structure_name= acquisition_name;
                save_benchmark_results(acquisition_name, structure_name, xtrain, ctrain, score, xbest, objective, data_dir, task)
            end
        end
    end
end