trash <- function(x = NULL,
                  y = NULL,
                  z = NULL) {
  args <- as.list(environment())
  aapply(assert_character,
         ~x + y,
         null.ok = c(TRUE, TRUE))

  aapply(assert_logical,
        ~z,
        null.ok = c(TRUE))
  return(args)
}


aapply = function(fun, formula, ..., fixed = list()) {
  fun = match.fun(fun)
  terms = terms(formula)
  vnames = attr(terms, "term.labels")
  ee = attr(terms, ".Environment")

  dots = list(...)
  dots$.var.name = vnames
  dots$x = unname(mget(vnames, envir = ee))
  .mapply(fun, dots, MoreArgs = fixed)

  invisible(NULL)
}



trash(x = 1)



surveys()
