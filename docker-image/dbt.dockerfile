FROM python:3.9.6
WORKDIR /dbt-code
COPY . .

ARG DBT_PROFILES_DIR=.profiles
ENV DBT_PROFILES_DIR=$DBT_PROFILES_DIR

# Install DBT
RUN pip install -U pip && pip install -r requirements.txt

ENTRYPOINT [ "dbt" ]

# docker build --build-arg DBT_PROFILES_DIR=${DBT_PROFILES_DIR} -t dbtrun  -f ./docker-image/dbt.dockerfile .
# docker run -it dbtrunall run
