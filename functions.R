# Split out all my funcitons here.

printCurrency <- function(x) {
  paste("$", format(x, big.mark=","), sep = "")
}

printNiceNum <- function(x) {
  paste(format(x, big.mark=","))
}

doMarketGrouping <- function(x, feeTable) {
  return(x %>% 
    group_by(Market) %>% 
    summarize(count=n()) %>% 
    inner_join(feeTable))
}