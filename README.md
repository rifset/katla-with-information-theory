# How to Guess Optimally Your First Katla Word According to Theory Information

# Introduction

[Katla](https://katla.vercel.app/) is the adaption version of [Wordle](https://www.nytimes.com/games/wordle/)—a viral daily word game by the New York Times—which has the goal to guess a five-letter “secret” word. While Wordle is in the English language, Katla is an adaption version of it in Bahasa Indonesia. Katla was created by [Fatih Kalifa](https://fatihkalifa.com/), a software engineer from Indonesia, and was launched on January 20th, 2022 [1].

# Game Rules

As mentioned above, the goal is to guess a five-letter “secret” word. Each person has six attempts to guess the correct “secret” word. 

![katla.vercel.app_(iPhone SE).png](imgs/katla.vercel.app_(iPhone_SE).png)

For each guess the game will provide feedbacks on which letters are correct and incorrect.

![game-rules.PNG](imgs/game-rules.png)

- Grey: the letter is not in the “secret” word
- Yellow: the letter is in the “secret” word, but misplaced
- Green: the letter is in the “secret” word, and placed correctly

# What is the Optimal First Guess for Katla?

Depending on what the definition of “optimal” is, here are my three approaches to it:

## Unique Letters

Words containing more unique letters should be better than words with duplicated letters in them. The idea is simple, more unique letters mean more information I could get from each guess’ feedback. There are a plethora of words to use as the first guess such as KAGET, LOBAK, MANDI, etc. Yet, with this approach, I could not decide what specific word is the optimal first guess.

## Most Frequent Letters

After a quick research, I found that the letters A, N, and E are the most frequent letters in the Indonesian language. You can view the full distribution [here](https://www.sttmedia.com/characterfrequency-indonesian), and this is the top 10 most frequent letters:

| Letter | Frequency |
| --- | --- |
| A | 20.39 % |
| N | 9.33 % |
| E | 8.28 % |
| I | 7.98 % |
| T | 5.58 % |
| K | 5.14 % |
| D | 5.00 % |
| R | 4.64 % |
| U | 4.62 % |
| M | 4.21 % |

Using this information, the guess ANTIK or ETIKA might be better than random five-letter word guesses. But is there any measurement of how better the guesses are? Is there any justification to claim that ANTIK is a better first guess than MANDI, or ETIKA is a better first guess than LOBAK? Even with these findings, the optimal first guess could not be determined.

## Statistical Approach

Information theory is a statistical way to measure the quantity of information. It is used widely in the data mining and machine learning field. In Natural Language Processing (NLP) domain, every lexicon of words shares information in such phrases and sentences constructed from it. This implies, if I can capture as much information from my guesses, I can determine which word is the most optimal as the first guess.

# Finding Optimal First Guess Using Information Theory

## What is Information?

Information is measured in bits. The concept of "information" is essentially about storage and the storage of information is bits [2]. Information as a function of probability is denoted as:

$$
h(x)=\log_{2}(1/p(x))=-\log_{2}p(x)
$$

The lower the probability of the event, the higher the information. The meaning of the term “event” may not be intuitively straightforward, yet you can find the practical application later on.

## Entropy

Since $h(x)$ is a function of a random variable, it has many possible outcomes. Thus, to aggregate those information pieces, we take the expectation over $h(x)$, assuming it is a discrete random variable.

$$
H(X)=\mathop{{}\mathbb{E}}[h(x)]=-\sum_{x\in X}p(x)\log_{2}p(x)
$$

The function $H(X)$ is called entropy (or Shannon entropy). It is the expected or the average amount of information we could obtain from certain events. The higher the entropy, the more information it contains.

## Calculating Entropy

To calculate each guess’ entropy, we should first understand what is the “event” we are going to observe. As stated in the game rules section, after each guess the game system will provide us feedback. There are three possible colors (grey, yellow, and green) and there are five boxes representing five letters each, so there would be $3^5=243$ possible permutation of patterns.

### Breaking Down the Case

Let’s take a look at one of the possible patterns, using my favorite guess ANIMO.

![animo-case.PNG](imgs/animo-case.png)

The letter A and M are correct but misplaced. While the remaining letter N, I, and O are incorrect. How many five-letter words in the Indonesian language do not contain N, I, and O, but contain A and M not in the 1st and 4th place respectively? 

To answer this question, let’s break down the case. Assume that each possible pattern (of feedback) is a discrete random variable, this is what the “event” we ought to observe. Each event has a probability of happening. Its probability is counted by comparing how many five-letter words satisfy a certain pattern with how many five-letter words exist.

$$
p(x)=\frac{\#\ words\ that\ satisfy\ pattern}{\#\  all\ possible\ words}
$$

### Katla Implementation

In Katla, 8311 five-letter words could be a “secret” word. I have downloaded this word list from Katla’s [GitHub](https://github.com/pveyes/katla) page. Knowing this, we can answer the question we left above.

> How many five-letter words in Indonesian language that do not contain N, I, and O, but contain A and M not in the 1st and 4th place respectively?
> 

With a simple analytical move, I found 433 words that satisfy this particular pattern.

| # | Word |
| --- | --- |
| 1 | BACEM |
| 2 | BADAM |
| 3 | BAHAM |
| 4 | BAKAM |
| … | … |
| 431 | WEDAM |
| 432 | ZAKUM |
| 433 | ZUMBA |

Hence, the probability is

$$
p(🟨⬛⬛🟨⬛)=\frac{433}{8311}=0.05209
$$

And the amount of information we get is

$$
h(🟨⬛⬛🟨⬛)=-\log_{2}(0.05209)=4.26\ bits
$$

The information we got from this specific pattern is 4.26 bits, and this pattern is just one of all 243 possible patterns. To get the expected or average amount of information, we must first calculate the possibility of each pattern.

| Pattern | # word | Probability | Information amount |
| --- | --- | --- | --- |
| 🟨⬛⬛⬛⬛ | 1765 | 0.21237 | 2.2354 |
| ⬛⬛⬛⬛⬛ | 777 | 0.09349 | 3.4190 |
| 🟨⬛🟨⬛⬛ | 772 | 0.09289 | 3.4283 |
| ⬛⬛🟨⬛⬛ | 649 | 0.07809 | 3.6787 |
| … | … | … | … |
| 🟩🟩🟩⬛🟨 | 1 | 0.00012 | 13.0208 |
| 🟩🟩🟩🟩⬛ | 1 | 0.00012 | 13.0208 |
| 🟩🟩🟩🟩🟩 | 1 | 0.00012 | 13.0208 |

In case you wonder how the distribution looks like, here is the probability distribution sorted from highest to lowest probability

![probability-plot.PNG](imgs/probability-plot.png)

Calculating the expectation

$$
H(X)=-\sum_{x\in X} p(x)\log_{2}p(x)=4.57\ bits
$$

So, the expected amount of information we got from using ANIMO as a first guess in Katla is 4.57 bits.

### Finding the Highest Entropy

There are 8311 five-letter words we need to calculate its entropy value. I have been working with an algorithm to calculate each pattern probability and aggregate them for each word. Since I am not an expert in programming, my algorithm worked but took 3.14 hours (yes, 3 hours lol) to finish the whole process, its around 1.36 second per word. And here is the result:

| Rank | Word | Entropy |
| --- | --- | --- |
| 1 | SARIK | 6.0599 |
| 2 | KERAI | 6.0443 |
| 3 | TARIK | 6.0421 |
| 4 | KURAI | 6.0331 |
| … | … |  |
| 8309 | GOGOH | 2.3500 |
| 8310 | KOKOK | 2.3433 |
| 8311 | FONON | 2.3325 |

### Behind the Process

In this section, I will break down the algorithm I used to calculate entropy. If you want to skip this part, you can jump to the conclusion section.

**First**, finding words that satisfy certain patterns. I partitioned this process into five subprocesses:

(1) identifying each pattern’s meaning;
********************I encoded each pattern with E, P, and N which stands for Exact match (green box), Partial match (yellow box), and No match (grey box). Patterns that have E(s) mean it contains an exact pattern that can be searched via regex. Patterns that have P(s) mean two things, words contain P(s) letters but not in the same position as the P(s), and duplicated P(s) letters must be considered. Patterns that have N(s) mean it should not contain any of the N(s) letters.********************

```r
#>    label pattern contains not_contains
#> 1: PPNPP   .....  a,n,m,o            i
#> 2: EPNPE   a...o      n,m            i
#> 3: NENNE   .n..o                 a,i,m
#> 4: EPNEE   a..mo        n            i
#> 5: PPENP   ..i..    a,n,o            m
```

(2) narrowing the list with correct letters;

```r
katla_words %>% 
  filter(str_detect(word, "..i.."))
#>       word
#>   1: abian
#>   2: abing
#>   3: acian
#>   4: adidi
#>   5: adika
#>  ---      
#> 152: urita
#> 153: using
#> 154: waima
#> 155: waina
#> 156: yaitu
```

(3) filtering out words with misplaced letters;

```r
katla_words %>% 
  filter(str_detect(word, "..i..")) %>% 
  filter(str_detect(word, "a..m.", negate = TRUE)) 
#>       word
#>   1: abian
#>   2: abing
#>   3: acian
#>   4: adidi
#>   5: adika
#>  ---      
#> 150: urita
#> 151: using
#> 152: waima
#> 153: waina
#> 154: yaitu
```

(4) narrowing the list again with correct but misplaced letters;

```r
katla_words %>% 
  filter(str_detect(word, "..i..")) %>% 
  filter(str_detect(word, "a..m.", negate = TRUE)) %>% 
  filter(str_detect(word, "a"), str_detect(word, "m"))
#>      word
#>  1: agium
#>  2: amida
#>  3: amido
#>  4: amien
#>  5: amina
#>  6: amino
#>  7: caima
#>  8: fmipa
#>  9: kaimo
#> 10: maido
#> 11: maiwa
#> 12: nrima
#> 13: prima
#> 14: waima
```

(5) finally, filtering out words incorrect letters

```r
katla_words %>% 
  filter(str_detect(word, "..i..")) %>% 
  filter(str_detect(word, "a..m.", negate = TRUE)) %>% 
  filter(str_detect(word, "a"), str_detect(word, "m")) %>% 
  filter(str_detect(word, "n|o", negate = TRUE))
#>     word
#> 1: agium
#> 2: amida
#> 3: caima
#> 4: fmipa
#> 5: maiwa
#> 6: prima
#> 7: waima
```

Recap: the guess ANIMO with PNEPN (🟨⬛🟩🟨⬛) pattern leaving just 7 words AGIUM, AMIDA, CAIMA, FMIPA, MAIWA, PRIMA, and WAIMA.

**Second**, iterating the first process for each pattern. Note that each word can only belong to one pattern, this is crucial since the total of each pattern’s filtered word can not larger than the number of all possible words. Hence, for each iteration, the all possible words’ size is reduced corresponding to the size of filtered words in that iteration. So, the pattern PNEPN filtered words would not be seven words.

```r
#>    label pattern contains not_contains                     occurence
#> 1: PNENP   ..i..      a,o          n,m                         oliva
#> 2: PNENE   ..i.o        a          n,m iaido,kaido,sailo,taiko,taiso
#> 3: PNEPN   ..i..      a,m          n,o                   fmipa,maiwa
#> 4: PNEPP   ..i..    a,m,o            n                              
#> 5: PNEPE   ..i.o      a,m            n                         maido
```

**Last**, counting filtered words, calculate its probability, and information.

```r
#> # A tibble: 5 x 8
#>   label pattern contains not_contains occurence     N        p     I
#>   <chr> <chr>   <chr>    <chr>        <list>    <int>    <dbl> <dbl>
#> 1 PNENP ..i..   a,o      n,m          <chr [1]>     1 0.000120  13.0
#> 2 PNENE ..i.o   a        n,m          <chr [5]>     5 0.000602  10.7
#> 3 PNEPN ..i..   a,m      n,o          <chr [2]>     2 0.000241  12.0
#> 4 PNEPP ..i..   a,m,o    n            <chr [0]>     0 0          0  
#> 5 PNEPE ..i.o   a,m      n            <chr [1]>     1 0.000120  13.0
```

**Then**, repeat the process for 8311 words :)

# Conclusion

## Optimal First Guess

Using Information Theory, we learned that the word SARIK is expected to give the most information when used as a first guess. Note that the letter S is not in the top 10 frequent letters in the Indonesian language, while the other four letters are. Also, there is no duplicated letter in the word SARIK, nor for the top 10 words with the highest entropy. 

## Next Steps

After knowing the optimal first guess, the next step to do is to solve the game itself. Since you know the optimal first guess only, there are still 5 guesses remaining. For now, there is no algorithm to solve Katla using Information Theory, but there is various study done for Wordle. One of the studies, that is also the inspiration of this study, that is well spoken is by [Grant Sanderson](https://www.3blue1brown.com/lessons/wordle). Hence, I leave it to you to do further exploration! :D

Have you done your Katla today? :)

# Reference

[1] Narabahasa, “Sesi Twitter spaces narabahasa: Fatih Kalifa Ungkap Fakta Menarik Seputar Katla,” *Narabahasa*, 01-Mar-2022. [Online]. Available: https://narabahasa.id/berita/sesi-twitter-spaces-narabahasa-fatih-kalifa-ungkap-fakta-menarik-seputar-katla. [Accessed: 31-Jan-2023]. 

[2] M. Vlastelica, “What is the ‘information’ in information theory?,” *Towards Data Science*, 27-Feb-2020. [Online]. Available: https://towardsdatascience.com/what-is-the-information-in-information-theory-d916250e4899. [Accessed: 31-Jan-2023].
