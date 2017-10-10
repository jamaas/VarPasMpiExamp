## This is a small exaple model of a much bigger model, and it demonstrates a
## way to pass parameter values, essentially "around" the foreach statement so
## they get to each worker when using foreach and running in parallel.  This
## model must be run with two other files, 'DefaultParams.R' and
## 'ForeachParamsPass.R'.  It was created by Jim Maas on 30/09/2017.

## Last updated on 10/10/2017

#' Test function level 1
#' @param num.sim first variable for function 1
#' @param num.per second variable for function 1
#' @param num.day third variable for function 1
#' @export fun1
fun1 <- function (num.sim=10, num.per=8, num.day=5, ...) {
    final.results <- data.frame (foreach::`%dopar%`(
        foreach::`%:%`(foreach::foreach(j = 1:num.sim,
                                        .combine = cbind,
                                        .packages= 'toymod4'),
                       foreach::foreach (i = 1:num.per,
                                         .packages = 'toymod4',
                                         .combine=rbind)), {
            out3 <- replicate(num.day, eval(call("fun2")))
            out2 <- data.frame(mean(out3))
        }
    )
    )
    ## save outputs for subsequent analyses if required
    saveRDS(final.results, file = paste(num.day ,"_", num.per, "_", num.sim, "_",
                                        format(Sys.time(), "%d_%m_%Y"),
                                        ".rds", sep=""))
    return(final.results)
}

## Because the individual variable values arrive in lists, it makes them quite
## difficult to extract, note
## (get('listname', environment of origin))[['variablename']]

#' Test function level 2
#' @param var21 first variable for function 2
#' @param var22 second variable for function 2
#' @param fun22on turn this call to fun3 on or off
#' @export fun2
fun2 <- function () {
    out21 <- ifelse (rpois(1, (get('fun2vars', pos = .mpi.env))[['var21']] ) > 0,
                     (get('fun2vars', pos = .mpi.env))[['var22']] * fun3(),
                     0)
    out22 <- ifelse ((get('fun2vars', pos = .mpi.env))[['fun22on']],
                     fun3(),
                     0)
    out2 <- out21 + out22
}

#' Test function level 3
#' @param var31 first variable for function 3
#' @param fun3on turn the formula on or off
#' @export fun3
fun3 <- function () {
    out31 <- ifelse ((get('fun3vars', pos = .mpi.env))[['fun3on']],
                     (get('fun3vars', pos = .mpi.env))[['var31']],
                     1)
    out32 <- ifelse ((get('fun3vars', pos = .mpi.env))[['fun3on']],
                     fun4(),
                     0)
    out3 <- out31 + out32
}

#' Test function level 4
#' @param var41 first variable for function 4
#' @param fun4on turn the formula on or off
#' @export fun4
fun4 <- function () {
    out4 <- ifelse ((get('fun4vars', pos = .mpi.env))[['fun4on']],
                    (get('fun4vars', pos = .mpi.env))[['var41']],
                    1)
}
