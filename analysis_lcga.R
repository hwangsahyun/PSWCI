# ============================================================
# 0. 패키지 설치 및 로드
# ============================================================
install.packages("progressr")
library(progressr)

handlers(global = TRUE)
handlers("progress")

# 1. 먼저 이것만 실행
install.packages("stringi", type = "binary")

# 2. 완료되면
install.packages("tidyverse")

# 3. 확인
library(tidyverse)

library(lcmm)
library(tidyverse)
library(ggplot2)


# ============================================================
# 1. 데이터 로드
# ============================================================

df <- read.csv("pswci_riri_lcga.csv", fileEncoding = "UTF-8-BOM")

# 분석에 필요한 변수만 선택
df_lcga <- df %>%
  select(pid, RIRI_w3, RIRI_w4, RIRI_w5, sqrtRIRI_w3, sqrtRIRI_w4, sqrtRIRI_w5) %>%
  filter(!is.na(sqrtRIRI_w3) | !is.na(sqrtRIRI_w4) | !is.na(sqrtRIRI_w5))

# wide → long 변환 (lcmm은 long 형태 필요)
df_long <- df_lcga %>%
  pivot_longer(
    cols      = c(sqrtRIRI_w3, sqrtRIRI_w4, sqrtRIRI_w5),
    names_to  = "wave",
    values_to = "sqrtRIRI"
  ) %>%
  mutate(
    time = case_when(
      wave == "sqrtRIRI_w3" ~ 0,   # 3차 = 기준시점(0)
      wave == "sqrtRIRI_w4" ~ 1,   # 4차 = 1년 후
      wave == "sqrtRIRI_w5" ~ 2    # 5차 = 2년 후
    )
  ) %>%
  arrange(pid, time)

cat("Long 데이터 shape:", nrow(df_long), "행 x", ncol(df_long), "열\n")
head(df_long, 10)


# ============================================================
# 2. LCGA 모델 적합 (k=1~5 집단)
#    - link = "linear" : 연속형 결과변수
#    - idiag = TRUE    : 각 집단 분산 동일 가정 (LCGA 기본)
#    - ng            : 집단 수
# ============================================================

set.seed(42)

# k=1 (기저 모델)
m1 <- hlme(sqrtRIRI ~ time,
           subject = "pid",
           ng      = 1,
           data    = df_long)

# k=2
m2 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 2,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

# k=3
m3 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 3,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

# k=4
m4 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 4,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

# k=5
m5 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 5,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)


# ============================================================
# 3. 모델 비교 (BIC, AIC, Entropy)
# ============================================================

cat("\n========================================\n")
cat("모델 적합도 비교\n")
cat("========================================\n")

summarytable(m1, m2, m3, m4, m5,
             which = c("G", "loglik", "conv", "npm", "AIC", "BIC", "entropy", "ICL"))


# ============================================================
# 4. 최적 모델 선택 후 집단 정보 추출
#    → BIC 최소 + Entropy ≥ 0.8 기준
#    → 아래는 m3(k=3) 예시, 결과 보고 변경
# ============================================================

best_model <- m3   # BIC 보고 수정

# 집단별 소속 확률 및 최종 집단 할당
df_class <- best_model$pprob %>%
  as.data.frame() %>%
  rename(pid = pid, class = class)

cat("\n집단별 인원:\n")
table(df_class$class)

cat("\nEntropy:\n")
cat(best_model$entropy, "\n")

# 원본 데이터에 집단 병합
df_lcga <- df_lcga %>%
  left_join(df_class %>% select(pid, class), by = "pid")


# ============================================================
# 5. 집단별 평균 궤적 시각화
# ============================================================

# 집단별 평균 계산
traj_mean <- df_long %>%
  left_join(df_class %>% select(pid, class), by = "pid") %>%
  group_by(class, time) %>%
  summarise(
    mean_sqrtRIRI = mean(sqrtRIRI, na.rm = TRUE),
    mean_RIRI     = mean_sqrtRIRI^2,   # 역변환
    n             = n(),
    .groups = "drop"
  ) %>%
  mutate(year = time + 2020)

# 집단 레이블 (결과 보고 수정)
class_labels <- c(
  "1" = "만성미회복형",
  "2" = "부분회복형",
  "3" = "안정회복형"
)

traj_mean <- traj_mean %>%
  mutate(class_label = class_labels[as.character(class)])

# 플롯
ggplot(traj_mean, aes(x = year, y = mean_RIRI,
                       color = class_label, group = class_label)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 4) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = 50,  linetype = "dotted", color = "orange") +
  annotate("text", x = 2022.05, y = 102, label = "RIRI=100", size = 3.5, color = "gray50") +
  annotate("text", x = 2022.05, y = 52,  label = "RIRI=50",  size = 3.5, color = "orange") +
  scale_x_continuous(breaks = c(2020, 2021, 2022)) +
  scale_color_manual(values = c("만성미회복형" = "#E74C3C",
                                 "부분회복형"   = "#F39C12",
                                 "안정회복형"   = "#2E86C1")) +
  labs(
    title    = "산재 노동자 RIRI 잠재계층 성장분석 (LCGA)",
    subtitle = paste0("최적 집단 수: k=", best_model$ng,
                      " | Entropy=", round(best_model$entropy, 3)),
    x        = "조사 연도",
    y        = "RIRI (평균, 역변환)",
    color    = "집단"
  ) +
  theme_bw(base_family = "AppleGothic") +
  theme(
    plot.title    = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    legend.position = "bottom"
  )

ggsave("lcga_trajectory.png", width = 8, height = 6, dpi = 150)
cat("lcga_trajectory.png 저장 완료\n")


# ============================================================
# 6. 집단별 기술통계 (RIRI 원본 단위)
# ============================================================

cat("\n========================================\n")
cat("집단별 RIRI 기술통계 (원본 단위)\n")
cat("========================================\n")

df_lcga %>%
  group_by(class) %>%
  summarise(
    n         = n(),
    pct       = round(n() / nrow(df_lcga) * 100, 1),
    RIRI3_mean = round(mean(RIRI_w3, na.rm = TRUE), 1),
    RIRI4_mean = round(mean(RIRI_w4, na.rm = TRUE), 1),
    RIRI5_mean = round(mean(RIRI_w5, na.rm = TRUE), 1),
  ) %>%
  print()

set.seed(42)

m1 <- hlme(sqrtRIRI ~ time,
           subject = "pid",
           ng      = 1,
           data    = df_long)

m2 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 2,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

m3 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 3,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

m4 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 4,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

m5 <- gridsearch(
  hlme(sqrtRIRI ~ time, subject = "pid", ng = 5,
       mixture = ~ time, data = df_long),
  rep = 30, maxiter = 30, minit = m1
)

cat(best_model$entropy, "\n")





# best_model을 m4로 설정
best_model <- m4

# 집단 소속 추출
df_class <- best_model$pprob %>%
  as.data.frame() %>%
  rename(pid = pid, class = class)

cat("집단별 인원:\n")
print(table(df_class$class))
cat("Entropy:", round(best_model$entropy, 3), "\n")

# 원본에 집단 병합
df_lcga <- df_lcga %>%
  select(-any_of("class")) %>%   # 기존 class 컬럼 제거
  left_join(df_class %>% select(pid, class), by = "pid")

# 집단별 평균 궤적 계산
traj_mean <- df_long %>%
  left_join(df_class %>% select(pid, class), by = "pid") %>%
  group_by(class, time) %>%
  summarise(
    mean_sqrtRIRI = mean(sqrtRIRI, na.rm = TRUE),
    mean_RIRI     = mean_sqrtRIRI^2,
    n             = n(),
    .groups       = "drop"
  ) %>%
  mutate(
    year        = time + 2020,
    class_label = paste0("집단", class)
  )

# 시각화
ggplot(traj_mean, aes(x = year, y = mean_RIRI,
                       color = class_label, group = class_label)) +
  geom_line(linewidth = 1.5) +
  geom_point(size = 4) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = 50,  linetype = "dotted", color = "orange") +
  scale_x_continuous(breaks = c(2020, 2021, 2022)) +
  labs(
    title    = "LCGA 집단별 평균 궤적 (k=4)",
    subtitle = paste0("Entropy=", round(best_model$entropy, 3)),
    x        = "조사 연도",
    y        = "RIRI (평균)",
    color    = "집단"
  ) +
  theme_bw()

ggsave("lcga_k4_trajectory.png", width = 8, height = 6, dpi = 150)

# 집단별 기술통계
df_lcga %>%
  group_by(class) %>%
  summarise(
    n          = n(),
    pct        = round(n() / nrow(df_lcga) * 100, 1),
    RIRI3_mean = round(mean(RIRI_w3, na.rm = TRUE), 1),
    RIRI4_mean = round(mean(RIRI_w4, na.rm = TRUE), 1),
    RIRI5_mean = round(mean(RIRI_w5, na.rm = TRUE), 1)
  ) %>%
  print()