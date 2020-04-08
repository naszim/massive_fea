# Get data from the google cloud storage

install.packages("googleCloudStorageR")


library(tidyverse)
library(googleCloudStorageR)

# Sys.setenv("GCS_DEFAULT_BUCKET" = "fea_research",
#            "GCS_AUTH_FILE" = "synetiq-analysis-167618-97bb98ed40e8.json")

gcs_auth(json_file = "synetiq-analysis-167618-97bb98ed40e8.json")
gcs_global_bucket("fea_research")
project <- "synetiq-analysis-167618"

# objects <- gcs_list_objects()

presentation_order <-
  objects %>%
  as_tibble() %>%
  filter(str_detect(name, "merged/00_stimuli_presentation_order_per_tester_default.csv")) %>%
  mutate(project_id = str_extract(name, "\\d{4} \\d{2}"),
         data = map(name, ~gcs_get_object(.x)%>%
                           gather(TestId, order, -stimulus) %>%
                           filter(str_detect(stimulus, "^animal|^rotten|^food|^face")) %>%
                           filter(!str_detect(stimulus, "baseline|end$")) %>%
                           mutate(stimulus = str_remove(stimulus, ".jpg$"))
                          )
         )

# all_presentation <-
#   presentation_order %>%
#   unnest(data)

# write_excel_csv(all_presentation, "data/all_presentation_order.csv")

all_presentation <- read_csv("data/all_presentation_order.csv")

all_presentation %>% 
  drop_na(order) %>% 
  mutate(block = str_extract(stimulus, "^[a-z]+")) %>% 
  group_by(project_id, block) %>% 
  summarise(avg_order = mean(order)) %>% 
  view()
