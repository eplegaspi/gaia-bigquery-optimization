FROM python:3.9.6 AS docsbuilder
WORKDIR /dbt-code
COPY . .

ARG DBT_PROFILES_DIR=.profiles
ENV DBT_PROFILES_DIR=$DBT_PROFILES_DIR

RUN pip install -U pip && pip install -r requirements.txt && dbt debug && dbt docs generate


FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=docsbuilder /dbt-code/target/index.html index.html
COPY --from=docsbuilder /dbt-code/target/catalog.json catalog.json 
COPY --from=docsbuilder /dbt-code/target/manifest.json manifest.json
COPY --from=docsbuilder /dbt-code/target/run_results.json run_results.json

# docker build --build-arg DBT_PROFILES_DIR=${DBT_PROFILES_DIR} -t dbtdocs  -f ./docker-image/dbt_docs.dockerfile .
# docker run -it --rm -p 8080:80 --name dbtdocs dbtdocs
