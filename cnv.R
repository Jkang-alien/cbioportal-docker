library(cnv4cbio)
setwd('/home/molpath/Downloads/NGS_OCA/Variants/tsv/')

f_list <- list.files('.')

table <- as.numeric(entrez_id)
for (j in f_list) {
  table <- cbind(table, cnv_table(j))
}

colnames(table)[1] <- 'Entrez_Gene_Id'

discrete_table <- table

discrete_table[is.na(discrete_table)] <- 0
discrete_table[discrete_table>=2] <- 2
discrete_table[,1] <- as.numeric(entrez_id)

write.table(table, 'data_log2_CNA.txt', append = FALSE, quote = FALSE,
            sep = "\t", na = "NA", dec = ".", col.names = TRUE, row.names = FALSE)

write.table(discrete_table, '/home/molpath/cbioportal_data_file/data_CNA.txt', append = FALSE, quote = FALSE,
            sep = "\t", na = "NA", dec = ".", col.names = TRUE, row.names = FALSE)
