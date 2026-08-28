FROM docker.io/library/centos:7

ARG JOBS=4
WORKDIR /build

RUN sed -i 's|mirror.centos.org|vault.centos.org|g; s|^#.*baseurl=http|baseurl=http|g; s|^mirrorlist=http|#mirrorlist=http|g' /etc/yum.repos.d/CentOS-*.repo \
    && yum install -y \
      bison flex fontconfig-devel freetype-devel gcc gcc-c++ git \
      libX11-devel libXext-devel libXrender-devel libjpeg-turbo-devel \
      libpng-devel libstdc++-static make patch perl tar xz zlib-devel \
    && yum clean all

ADD https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz /tmp/openssl.tar.gz
RUN mkdir /tmp/openssl \
    && tar -xzf /tmp/openssl.tar.gz -C /tmp/openssl --strip-components=1 \
    && cd /tmp/openssl \
    && ./config no-shared no-dso no-tests -fPIC --prefix=/opt/openssl \
    && make -j"${JOBS}" \
    && make install_sw

RUN git clone https://github.com/wkhtmltopdf/wkhtmltopdf.git app \
    && git --git-dir=app/.git --work-tree=app checkout 2b560d5e4302b5524e47aa61d10c10f63af0801c \
    && git clone https://github.com/wkhtmltopdf/qt.git app/qt \
    && git --git-dir=app/qt/.git --work-tree=app/qt checkout 82b568bd2e1dfb76208128e682fe0ade392e48d4

WORKDIR /build/app

RUN mkdir -p static-build/posix-local/qt \
    && cd static-build/posix-local/qt \
    && CXXFLAGS='-O2' OPENSSL_LIBS='-L/opt/openssl/lib -lssl -lcrypto -ldl' ../../../qt/configure \
      -opensource -confirm-license -release -static -graphicssystem raster \
      -webkit -exceptions -xmlpatterns -system-zlib -system-libpng \
      -system-libjpeg -no-libmng -no-libtiff -no-accessibility -no-stl \
      -no-qt3support -no-phonon -no-phonon-backend -no-opengl \
      -no-declarative -script -no-scripttools -no-multimedia \
      -nomake demos -nomake docs -nomake examples -nomake tools \
      -nomake tests -nomake translations -xrender -largefile -iconv \
      -openssl-linked -I /opt/openssl/include -L /opt/openssl/lib \
      -no-rpath -no-dbus -no-nis -no-cups -no-pch -no-gtkstyle \
      -no-nas-sound -no-sm -no-xshape -no-xinerama -no-xcursor \
      -no-xfixes -no-xrandr -no-mitshm -no-xinput -no-xkb -no-glib \
      -no-gstreamer -D ENABLE_VIDEO=0 -no-openvg -no-xsync \
      -no-audio-backend -no-icu -prefix /build/qt \
    && make -j"${JOBS}" \
    && make install

RUN mkdir -p static-build/posix-local/app \
    && cd static-build/posix-local/app \
    && WKHTMLTOX_VERSION=0.12.1 ../qt/bin/qmake -spec linux-g++ ../../../wkhtmltopdf.pro \
      'QMAKE_LFLAGS += -static-libgcc -static-libstdc++' \
    && make -j"${JOBS}" \
    && mkdir -p /out/bin /out/lib64 \
    && cp bin/wkhtmltopdf bin/wkhtmltoimage /out/bin/ \
    && cp -P bin/libwkhtmltox.so* /out/lib64/ \
    && cp -P /usr/lib64/libjpeg.so.62* /usr/lib64/libpng15.so.15* \
      /usr/lib64/libXrender.so.1* /usr/lib64/libfontconfig.so.1* \
      /usr/lib64/libfreetype.so.6* /usr/lib64/libXext.so.6* \
      /usr/lib64/libX11.so.6* /usr/lib64/libxcb.so.1* \
      /usr/lib64/libXau.so.6* \
      /usr/lib64/libexpat.so.1* /usr/lib64/libbz2.so.1* /out/lib64/

CMD ["cp", "-a", "/out/.", "/output/"]
