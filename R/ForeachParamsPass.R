## This is a set of functions that allows passing of parameter values,
## essentially "around" the foreach statement so they get to each worker when
## using foreach and running in parallel.  This model must be run with two other
## files, 'DefaultParams.R' and 'NestedFuncs.R'.  It was created by Jim Maas
## on 30/09/2017.

## Last updated on 10/10/2017

## Create environment used to hold "global" data used by various package
## functions
.mpi.env <- new.env(parent=emptyenv())

## Assign values to variables in ".mpi.env" in the local R session
#' local regular arguments localregargs function
#' @export localregargs
localregargs <- function(fun2vars, fun3vars, fun4vars) {
    assign('fun2vars', fun2vars, pos = .mpi.env)
    assign('fun3vars', fun3vars, pos = .mpi.env)
    assign('fun4vars', fun4vars, pos = .mpi.env)
    invisible(NULL)
}

## Register values of "fun2vars", "fun3vars", ... that are lists of
## variable values. It does that by calling localregargs directly and in a
## foreach loop. Calling it directly is necessary when the workers are forked,
## and calling it in a foreach loop is necessary when the workers are started
## via makeCluster or startMPIcluster.  Using both mechanisms keeps them
## consistent and avoids the problem of figuring out which mechanism is
## necessary.

#' regular arguments regargs function
#' @export regargs
regargs <- function(fun2vars, fun3vars, fun4vars) {
  ## Necessary for doMC and doParallelMC.
  ## Doesn't hurt for doParallelSNOW and doMPI.
  localregargs(fun2vars, fun3vars, fun4vars)

  ## Necessary for doParallelSNOW and doMPI.
  ## Doesn't hurt for doMC and doParallelMC.
  foreach(seq_len(getDoParWorkers()), .packages='toymod4') %dopar% {
    localregargs(fun2vars, fun3vars, fun4vars)
  }
  invisible(NULL)
}


