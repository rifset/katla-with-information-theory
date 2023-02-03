library(data.table)
library(tidyverse)

# data preparation --------------------------------------------------------

rawdt <- colnames(fread("katla-all-possible-words.txt"))
katla_words <- data.table(word = sort(rawdt))

# all possible pattern permutation ----------------------------------------

box_pattern <- expand_grid(
  p1 = c("E", "P", "N"),
  p2 = c("E", "P", "N"),
  p3 = c("E", "P", "N"),
  p4 = c("E", "P", "N"),
  p5 = c("E", "P", "N")
) %>%
  mutate(label = str_c(p1, p2, p3, p4, p5)) %>% 
  filter(!label %in% c("EEEEP", "EEEPE", "EEPEE", "EPEEE", "PEEEE"))

# define helper function --------------------------------------------------

wordSubtractionPattern <- function(word1, word2) {
  splitWord1 <- str_split(word1, "")
  splitWord2 <- unlist(str_split(word2, ""))
  subtractedWord <- lapply(splitWord1, function(x) {
    str_flatten(x[x != splitWord2])
  }) %>% 
    unlist()
  return(subtractedWord)
}

partialPattern <- function(label, replacement) {
  splitLabel <- unlist(str_split(label, ""))
  splitLabel <- str_remove_all(splitLabel, "E") %>% 
    str_replace_all("N", "\\.")
  listPattern <- vector("list", length(splitLabel[splitLabel == "P"]))
  for (k in 1:length(splitLabel[splitLabel == "P"])) {
    listPattern[[k]] <- splitLabel
    listPattern[[k]][listPattern[[k]] == "P"][k] <- replacement[k]
    listPattern[[k]] <- str_replace_all(listPattern[[k]], "P", "\\.") %>% 
      str_flatten()
  }
  return(unlist(listPattern))
}

letterFilter <- function(label, pattern, contains, not_contains, word_pool) {
  splitContains <- unlist(str_split(contains, ","))
  splitNotContains <- unique(unlist(str_split(not_contains, ",")))
  tempPool <- word_pool[, .(word, word_dup = word)]
  if (pattern != ".....") {
    tempPool <- tempPool[str_detect(word_dup, pattern = pattern), .(word = word, word_dup = wordSubtractionPattern(word_dup, pattern))]
  }
  if (all(splitContains != "")) {
    partialPatternList <- partialPattern(label, splitContains)
    for (k in partialPatternList) {
      tempPool <- tempPool[str_detect(word_dup, k, negate = T)]
    }
    for (i in splitContains) {
      tempPool <- tempPool[str_detect(word_dup, i), .(word = word, word_dup = str_remove(word_dup, i))]
    }
  }
  if (all(splitNotContains != "")) {
    tempPool <- tempPool[str_detect(word_dup, str_flatten(splitNotContains, "|"), negate = TRUE)]
  }
  return(tempPool[,1])
}

# define main function ----------------------------------------------------

getOccurence <- function(test_word, test_bank) {
  unlistWord <- unlist(str_split(test_word, ""))
  box_pattern <- expand_grid(
    p1 = c("N", "P", "E"),
    p2 = c("N", "P", "E"),
    p3 = c("N", "P", "E"),
    p4 = c("N", "P", "E"),
    p5 = c("N", "P", "E")
  ) %>%
    mutate(label = str_c(p1, p2, p3, p4, p5)) %>% 
    filter(!label %in% c("EEEEP", "EEEPE", "EEPEE", "EPEEE", "PEEEE"))
  wordPattern <- box_pattern %>% 
    mutate(
      pattern = str_c(
        if_else(p1 == "E", unlistWord[1], "."),
        if_else(p2 == "E", unlistWord[2], "."),
        if_else(p3 == "E", unlistWord[3], "."),
        if_else(p4 == "E", unlistWord[4], "."),
        if_else(p5 == "E", unlistWord[5], ".")
      ),
      contains = str_c(
        if_else(p1 == "P", unlistWord[1], ""),
        if_else(p2 == "P", unlistWord[2], ""),
        if_else(p3 == "P", unlistWord[3], ""),
        if_else(p4 == "P", unlistWord[4], ""),
        if_else(p5 == "P", unlistWord[5], "")
      ),
      not_contains = str_c(
        if_else(p1 == "N", unlistWord[1], ""),
        if_else(p2 == "N", unlistWord[2], ""),
        if_else(p3 == "N", unlistWord[3], ""),
        if_else(p4 == "N", unlistWord[4], ""),
        if_else(p5 == "N", unlistWord[5], "")
      )
    ) %>% 
    rowwise() %>% 
    mutate(
      contains = contains %>% 
        str_split("") %>% 
        unlist() %>% 
        str_flatten(","),
      not_contains = not_contains %>% 
        str_split("") %>% 
        unlist() %>% 
        str_flatten(",")
    ) %>% 
    ungroup() %>% 
    select(label, pattern, contains, not_contains) %>% 
    as.data.table()
  tempWordPool <- test_bank
  tempListWordPattern <- vector("list", nrow(wordPattern))
  for (k in 1:nrow(wordPattern)) {
    tempListWordPattern[[k]] <- wordPattern[k, .(
      label, pattern, contains, not_contains,
      occurence = list(
        pull(
          letterFilter(
            label = label,
            pattern = pattern,
            contains = contains,
            not_contains = not_contains,
            word_pool = tempWordPool
          )
        )
      )
    )]
    tempWordPool <- tempWordPool[!word %in% tempListWordPattern[[k]][1, occurence][[1]]]
  }
  wordPatternProc <- rbindlist(tempListWordPattern)
  return(wordPatternProc)
}

# get all entropy ---------------------------------------------------------

time_start <- Sys.time()
list_occurence <- lapply(katla_words$word, function(x) {
  getOccurence(x, katla_words)
})
time_end <- Sys.time()
time_end <- Sys.time()

names(list_occurence) <- katla_words$word
summary_entropy <- list_occurence %>% 
  rbindlist(idcol = "word") %>% 
  rowwise() %>% 
  mutate(N = length(occurence)) %>% 
  ungroup() %>% 
  mutate(
    p = N/nrow(katla_words),
    I = if_else(N == 0, 0, log2(1/p)),
    H = p*I
  ) %>% 
  group_by(word) %>% 
  summarize(Entropy = sum(H)) %>% 
  arrange(desc(Entropy))
