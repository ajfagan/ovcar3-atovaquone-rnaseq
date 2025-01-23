df <- read.table('expression_dirty.mat', row.names=1)

colnames(df) <- sapply(colnames(df), function(x) strsplit(x, '[.]')[[1]][1], USE.NAMES = F)
colnames(df) <- sapply(colnames(df), function(x) {
  parts <- strsplit(x, "_")[[1]]
  # If it is in 48 hour group
  if (parts[1] %in% c("A", "B", "C")) {
    batch = paste("_C_", switch(parts[1], 
                                A = 1,
                                B = 2,
                                C = 3
                                ), sep = "")
    # switch to D/ICX labeling
    treatment <- switch (strtrim(parts[2], 1),
                         '3' = "IC50",
                         '4' = "IC75",
                         D = "D"
    )
    
    return(paste(treatment, "_48", batch, sep=""))
  } else {
    # If in batch A, append "_a"
    if (length(parts) == 2) {
      return(paste(parts[1], parts[2], "A_1", sep = "_"))
    }
    
    # In B or C
    return(paste(parts[1], parts[2], switch(parts[3], 
                                            b = "B_1",
                                            c = "B_2"),
                 sep = "_"
    ))
  }
}, USE.NAMES = F)

write.table(df, 'expression.mat', quote=F, sep = "\t")


