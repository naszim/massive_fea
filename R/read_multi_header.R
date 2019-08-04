library(dplyr)

read_multi_header <- function(file, header_rows = 3, collapse = "-", delim = ",", ...)
{
        # Read the header rows, and merge them 
        header <-
                sapply(vroom::vroom(file = file,
                                        n_max = header_rows,
                                        col_names = FALSE,
                                        delim = delim),
                           paste, 
                           collapse = collapse) %>% 
                stringr::str_remove("-NA")
        
        # Return the dataset, with the merged names
        vroom::vroom(file = file, 
                     skip = header_rows, 
                     col_names = FALSE,
                     delim = delim,
                     ...) %>% 
          purrr::set_names(., header)
}

