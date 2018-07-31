FROM rocker/tidyverse

RUN apt-get update -y \
	&& apt-get -y --no-install-recommends install \
		libssl-dev \
		libsasl2-dev \
		libjpeg-dev \
	&& install2.r --error \
		--deps TRUE \
		-r "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"	\
		yaml \
		httr \
		mongolite \
		cli

# docker compose wait
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.3.0/wait /wait
RUN chmod +x wait 

COPY . /tester

WORKDIR /tester