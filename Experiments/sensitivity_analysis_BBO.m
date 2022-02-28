function sensitivity_analysis_BBO(pathname)

data_dir =  [pathname,'/Data/Data_BBO_sensitivity_analysis/'];

settings= load([pathname, '/Experiments_parameters.mat'],'Experiments_parameters');
settings = settings.Experiments_parameters;
settings = settings({'sensitivity_BBO'},:);

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
seeds = 1:nreplicates;
modeltype = settings.modeltype;
rescaling = settings.rescaling;

if rescaling == 0
    load('benchmarks_table.mat')
else
    load('benchmarks_table_rescaled.mat')
end

objectives = benchmarks_table.fName;
nobj =numel(objectives);

e_range =  settings.accessory_parameters{:};

for j = 1:nobj
    objective = char(objectives(j));
    close all
    [g, theta, model] = load_benchmarks(objective, [], benchmarks_table, rescaling, 'classification', 'modeltype', modeltype, 'link', link);

    for a =1:nacq
        acquisition_name = acquisition_funs{a};
        %         if strcmp(acquisition_name, 'BKG')
        %             modeltype = 'laplace';
        %         else
        %             modeltype = 'exp_prop';
        %         end
        acquisition_fun = str2func(acquisition_name);

        for e = e_range
            acq_fun = @(theta, xtrain_norm, ctrain,model, post, approximation,optim) acquisition_fun(theta, xtrain_norm, ctrain,model, post, approximation,optim, 'e', e);
            clear('xtrain', 'ctrain', 'score');

            optim = binary_BO(g, task, identification, maxiter, nopt, ninit, update_period, hyps_update, acq_fun, model.D, ns);
            for k=1:nreplicates
                seed  = seeds(k)
                [xtrain{k}, ctrain{k}, score{k}, xbest{k}]= optim.optimization_loop(seed, theta, model);
            end
            structure_name= [ acquisition_name, '_e_',num2str(e)];
            structure_name = regexprep(structure_name,'\.','_dot_');
            acq = [acquisition_name, '_e=',num2str(e)];
            save_benchmark_results(acq, structure_name, xtrain, ctrain, score, xbest, objective, data_dir, task)
        end
    end
end



