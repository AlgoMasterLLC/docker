FROM debian:bookworm-slim

ARG TAG=master

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl file libseccomp-dev ca-certificates ca-certificates-java bzip2 gzip gnupg unzip xz-utils libarchive-tools && \
    { curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; } && \
    { echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main' > /etc/apt/sources.list.d/nodesource.list; } && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs gcc g++ python3-full python3-pip python3-venv python3-dev python3-setuptools python3-wheel cython3 \
    fp-compiler libxtst6 tini openjdk-17-jdk-headless openjdk-17-jre-headless \
    $([ "$(arch)" = aarch64 ] && echo binutils-arm-linux-gnueabihf) && \
    if [ "$(arch)" = x86_64 ]; then PYPY_ARCH=linux64; else PYPY_ARCH="$(arch)"; fi && \
    mkdir /opt/pypy2 && curl -L "$(curl https://pypy.org/download.html | grep "/pypy2.*$PYPY_ARCH" | head -n1 | cut -d'"' -f4)" | \
    tar xj -C /opt/pypy2 --strip-components=1 && /opt/pypy2/bin/pypy -mcompileall && \
    chmod a+rx /opt/pypy2/lib /opt/pypy2/lib/*.so* && \
    rm -f /opt/pypy2/bin/python* && \
    mkdir /opt/pypy3 && curl -L "$(curl https://pypy.org/download.html | grep "/pypy3.*$PYPY_ARCH" | head -n1 | cut -d'"' -f4)" | \
    tar xj -C /opt/pypy3 --strip-components=1 && /opt/pypy3/bin/pypy -mcompileall && \
    rm -f /opt/pypy3/bin/python* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/perl && \
    useradd -m judge

RUN if [ "$(arch)" = x86_64 ]; then SCRATCH_ARCH=amd64; else SCRATCH_ARCH=arm64; fi && \
    SCRATCH_VERSION=$(curl -sL "https://api.github.com/repos/VNOI-Admin/scratch-run/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -sSL https://github.com/VNOI-Admin/scratch-run/releases/download/${SCRATCH_VERSION}/scratch-run_${SCRATCH_VERSION}_linux_${SCRATCH_ARCH}.zip | bsdtar -xvf- -C /usr/bin && \
    chmod +x /usr/bin/scratch-run

# RUN mkdir /ScratchCLI && cd /ScratchCLI && \
#     curl -L https://github.com/cuom1999/ScratchCLI/archive/master.tar.gz | tar -xz --strip-components=1 && \
#     npm i && ln -sf /ScratchCLI/scratch.js /usr/bin/scratch && chmod +x /usr/bin/scratch

RUN mkdir /judge /problems && cd /judge && \
    curl -L https://github.com/LQDJudge/judge-server/archive/"${TAG}".tar.gz | tar -xz --strip-components=1 && \
    python3 -m venv --prompt=DMOJ /env && \
    /env/bin/pip3 install cython setuptools && \
    /env/bin/pip3 install -e . && \
    /env/bin/python3 setup.py develop && \
    HOME=~judge . ~judge/.profile && \
    runuser -u judge -w PATH -- /env/bin/dmoj-autoconf -V > /judge-runtime-paths.yml && \
    echo '  crt_x86_in_lib32: true' >> /judge-runtime-paths.yml

COPY --chmod=755 download_testlib_and_precompile.sh /judge/.docker/download_testlib_and_precompile

RUN /judge/.docker/download_testlib_and_precompile

RUN groupadd -r user && useradd -r -g user user

ENV PATH="/opt/pypy2/bin:/opt/pypy3/bin:${PATH}"

ENTRYPOINT ["/judge/.docker/entry"]
