
library(readxl)
library(data.table)

res <- setDT(read_excel('data/rdatatable-survey-2023-raw.xlsx'))
colnames(res) <- gsub('[\r]|[\n]', '', colnames(res))

colmap <- fread('doc/colmap.csv')
setnames(res, colmap$name_from, colmap$name_to)

# remove test responses
res <- res[started_at > as.POSIXct('2023-10-17 18:25', tz = 'UTC')]

# some participants don't want their open-field responses to be shared verbatim
open_fields <- colmap[open_field == TRUE]$name_to
for (field in open_fields){
    res[
        responses_sharing %in% 'Only share my responses to open-ended questions in a summarized form',
        (field) := '< masked >'
    ]
}

res[, email_auto := NULL]
res[, name_auto := NULL]
res[, email := NULL]
res[, modified_at := NULL]
res[, started_at := NULL]
res[, ended_at := NULL]

fwrite(res, 'data/clean.csv', na = NA)
