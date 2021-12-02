%Preference learning: synthetic experiments
add_bo_module;
close all
pathname = '..';
data_dir =  [pathname,'/Data/Data_batch_PBO/'];

acquisition_funs = {'batch_MUC','kernelselfsparring_tour','random_acquisition_tour'};

maxiter =30;  %total number of iterations  
nreplicates = 30; 

nacq = numel(acquisition_funs);

rescaling = 0;
if rescaling ==0
    load('benchmarks_table.mat')
else
    load('benchmarks_table_rescaled.mat')
end
objectives = benchmarks_table.fName;
nobj =numel(objectives);
seeds = 1:nreplicates;
update_period = maxiter+2;
tsize= 4; %size of the tournaments
feedback = 'all'; %'all' best
more_repets= 0;
for j = 11:nobj
    objective = char(objectives(j));

     [g, theta, model] = load_benchmarks(objective, [], benchmarks_table, rescaling);
    model.nsamples= tsize;
        model.link = @normcdf;
    model.modeltype = 'exp_prop';
    model.regularization = 'nugget';

    close all
    for a =1:nacq
        acquisition_name = acquisition_funs{a};
        acquisition_fun = str2func(acquisition_name);
        clear('xtrain', 'xtrain_norm', 'ctrain', 'score');

        filename = [data_dir,objective,'_',acquisition_name, '_', feedback];

        if more_repets
            load(filename, 'experiment')
            n = numel(experiment.(['xtrain_',acquisition_name]));
            for k = 1:nreplicates
                disp(['Repetition : ', num2str(n+k)])
                seed =n+k;
                [experiment.(['xtrain_',acquisition_name]){n+k}, experiment.(['xtrain_norm_',acquisition_name]){n+k}, experiment.(['ctrain_',acquisition_name]){n+k}, experiment.(['score_',acquisition_name]){n+k}]=  TBO_loop(acquisition_fun, seed, maxiter, theta, g, update_period, model, tsize,feedback);
            end
        else
            for r=1:nreplicates
                seed  = seeds(r)
                [xtrain{r}, xtrain_norm{r}, ctrain{r}, score{r}] =  TBO_loop(acquisition_fun, seed, maxiter, theta, g, update_period, model, tsize,feedback);
            end
            clear('experiment')
            fi = ['xtrain_',acquisition_name];
            experiment.(fi) = xtrain;
            fi = ['xtrain_norm_',acquisition_name];
            experiment.(fi) = xtrain_norm;
            fi = ['ctrain_',acquisition_name];
            experiment.(fi) = ctrain;
            fi = ['score_',acquisition_name];
            experiment.(fi) = score;
        end

        close all
        save(filename, 'experiment')
    end
end
