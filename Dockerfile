FROM heroku/heroku:18-build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  libheif-dev

RUN curl -L https://github.com/strukturag/libde265/releases/download/v1.0.5/libde265-1.0.5.tar.gz | tar zx \
  && cd libde265-1.0.5 \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install

RUN curl -L https://github.com/strukturag/libheif/releases/download/v1.6.2/libheif-1.6.2.tar.gz | tar zx \
  && cd libheif-1.6.2 \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install

RUN curl -L http://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.1.0.tar.gz | tar zx \
  && cd libwebp-1.1.0 \
  && ./configure \
  && make \
  && make install

RUN cd /usr/src/ \
  && wget https://imagemagick.org/download/releases/ImageMagick-7.0.10-9.tar.gz \
  && tar xf ImageMagick-7.0.10-9.tar.gz \
  && cd ImageMagick-7* \
  && ./configure --with-heic=yes --prefix=/usr/src/imagemagick \
  && make \
  && make install

RUN cp /usr/local/lib/libde265.so.0 /usr/src/imagemagick/lib \
  && cp /usr/local/lib/libheif.so.1 /usr/src/imagemagick/lib

# clean the build area ready for packaging
RUN cd /usr/src/imagemagick \
  && strip lib/*.a lib/lib*.so*

RUN cd /usr/src/imagemagick \
  && rm -rf build \
  && mkdir build \
  && tar czf \
  /usr/src/imagemagick/build/imagemagick.tar.gz bin include lib
