FROM python:3.12-bookworm AS base

WORKDIR /site

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ARG BUN_VERSION=1.2.13

ENV DJANGO_ENV=docker
ENV VIRTUAL_ENV=/venv

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git gcc g++ make libxml2-dev libxslt1-dev zlib1g-dev gettext curl \
    pkg-config default-libmysqlclient-dev bash curl unzip && \
    curl https://bun.sh/install | bash -s -- bun-v${BUN_VERSION} && \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

RUN uv venv --seed --no-managed-python /venv

ENV PATH="${VIRTUAL_ENV}/bin:/root/.bun/bin:${PATH}"

RUN bun install -g sass postcss-cli postcss autoprefixer

COPY online-judge/requirements.txt .

RUN uv pip install -r requirements.txt
RUN uv pip install setuptools

FROM base AS site
EXPOSE 8000

ENTRYPOINT uvx uwsgi --ini /etc/uwsgi.ini

FROM base AS bridged

EXPOSE 9999
EXPOSE 9998

ENTRYPOINT uv run manage.py runbridged

FROM base AS celery

ENTRYPOINT uvx celery -A dmoj_celery worker -l info --concurrency=2
