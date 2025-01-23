

library(dplyr) 
library(rlang)
library(purrr)
library(pheatmap)
library(bslib)
library(ggplot2)
library(colorspace)
library(stringr)

str_wrap_factor <- function(x, var_width) {
  levels(x) <- str_wrap(levels(x), var_width)
  x
}

build_df <- function(
    df,
    genesets,
    treatments = c(45, 30),
    times = c(8, 24, 48)
) {
  geneset_names <- factor(names(genesets), ordered = T)
  nsets <- length(genesets)
  genes <- c()
  for (i in 1:nsets) {
    genes <- c(genes, genesets[[i]])
  }
  genes <- unique(genes)
  
  if (length(genes) == 0) return(NULL)
  
  df <- df %>%
    filter(Gene %in% genes) %>%
    filter(time %in% times) %>%
    filter(treatment %in% treatments) %>%
    mutate(group = "")
  
  for (i in 1:nsets) {
    df[,names(genesets)[i]] <- 0
    df[df$Gene %in% genesets[[i]], names(genesets)[i]] <- 1
    for (gene in genesets[[i]]) {
      if (all(df[df$Gene == gene, "group"] == "")) {
        df[df$Gene == gene, "group"] <- names(genesets)[i]
      } else {
        df[df$Gene == gene, "group"] <- paste(df[df$Gene == gene, "group"], names(genesets)[i], sep=",")
      }
    }
  }
  
  df$group <- factor(df$group, levels = geneset_names)
  df
}



p_vals_to_stars <- Vectorize(function(p) {
  if (pval < 0.0001) { return("****") }
  if (p < 0.001) { return("***") }
  if (p < 0.01) {return("**") }
  if (p < 0.05) { return("*") }
  if (p < 0.1) { return(".") }
  return("")
}, "p")
p_vals_to_annotations <- Vectorize(function(p) {
  if (p < 0.0001) { return("p < 0.0001****") }
  if (p < 0.001) { return("p < 0.001***") }
  if (p < 0.01) {return("p < 0.01**") }
  if (p < 0.05) { return("p < 0.05*") }
  return("p > 0.05")
}, "p")

expression_barplot <- function(
    df, genesets,
    
    time_label = "Time (Hours)",
    time_color_palette = F,#"Lajolla",
    colors = c(
      '#285291',
      '#91188E',
      '#539027'
    ),
    plot_title = "Barplot of estimated effect sizes for Atovaquone vs DMSO",
    pval_to_star = F,
    pval_annotation = T,
    x_offset = 0.5,
    var_width = 60,
    geneset_fontsize = 14,
    wrap_param = 10,
    p.size=3,
    ...
) { 
  #print(head(de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n])))
  #print(length(unique((de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n]))$gene)))
  
  #print(head(de.time2 %>% filter(gene %in% gene_ord[[order_by]][1:n]) %>% filter(gene %in% genes)))
  df <- build_df(df, genesets) %>%
    mutate(treatment = paste(treatment, "μM", sep = ""))
  names(colors) <- unique(df$time)
  
  if (pval_to_star) {
    df$Gene <- paste( p_vals_to_stars(df$p.adj), df$Gene)
  }
  
  position <- position_dodge2(width=0.9)
  
  pp <- ggplot(
    df,
    aes(
      y = Gene,
      x = log2FoldChange,
      fill = factor(time),
      group = factor(group, labels = str_wrap(levels(group), var_width), levels = names(genesets))
    )
  ) +
    geom_col(position= position, ...) + 
    geom_vline(aes(xintercept=0.0), size=1) +
    facet_grid(
      str_wrap_factor(group, var_width) ~ factor(treatment, ordered=T), 
      scales = "free_y", 
      space = 'free',
      labeller = labeller(groupwrap = label_wrap_gen(wrap_param))) +
    xlab("log2-Fold Change") +
    ylab("Gene") + 
    theme_bw() +
    theme(
      strip.text.y = element_text(face="bold", size=geneset_fontsize)
    ) +
    labs(title = plot_title, fill = time_label) +
    scale_fill_manual(values = colors)
    #scale_fill_discrete_sequential(palette = time_color_palette) 
  
  if (pval_annotation) {
    pp <- pp +
      geom_text(
        data = df %>% 
          filter(time == median(time)) %>% 
          filter(treatment == min(treatment)), 
        aes(
          y = Gene, x = min(df$log2FoldChange) - x_offset, 
          label=p_vals_to_annotations(p.adj)
        ), 
        hjust="left", 
        position = position, 
        size = p.size,
        color = 'red'
      )
  }
  
  pp
}





