FROM gcc:latest

COPY . /usr/src/yaneura-ou
WORKDIR /usr/src/yaneura-ou/source
RUN mkdir -p ../bin/eval ../bin/book
RUN sed -i \
  -e 's/^YANEURAOU_EDITION.*$/YANEURAOU_EDITION = YANEURAOU_ENGINE_NNUE_KP256/' \
  -e 's/^TARGET_CPU.*$/TARGET_CPU = OTHER/' \
  -e 's/^COMPILER.*$/COMPILER = g++/' \
  -e '/^CFLAGS/a CFLAGS  += -static' \
  -e 's/^LDFLAGS.*$/LDFLAGS  = -Wl,--whole-archive -lpthread -Wl,--no-whole-archive/' \
  ./Makefile \
  && make tournament \
  && cp YaneuraOu-by-gcc ../bin/yaneura-ou
RUN curl -L -O https://github.com/yaneurao/YaneuraOu/releases/download/20190212_k-p-256-32-32/20190212_k-p-256-32-32.zip \
  && unzip 20190212_k-p-256-32-32.zip -d 20190212_k-p-256-32-32 \
  && rm 20190212_k-p-256-32-32.zip \
  && cp 20190212_k-p-256-32-32/nn.bin ../bin/eval
RUN curl -L -O https://github.com/yaneurao/YaneuraOu/releases/download/BOOK-700T-Shock/700T-shock-book.zip \
  && unzip 700T-shock-book.zip -d 700T-shock-book \
  && rm 700T-shock-book.zip \
  && cp 700T-shock-book/user_book1.db ../bin/book/standard_book.db

FROM alpine:latest
COPY --from=0 /usr/src/yaneura-ou/bin /usr/local/yaneura-ou/bin
WORKDIR /usr/local/yaneura-ou/bin
ENTRYPOINT ["./yaneura-ou"]

# setoption name BookDepthLimit value 0
