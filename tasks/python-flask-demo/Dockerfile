FROM python:3.8-slim AS py-builder

COPY ./src/requirements.txt /requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir --user -r /requirements.txt && \
    rm -rf /root/.cache/* && \
    rm -rf /root/.config/pip

FROM python:3.8-slim AS runtime-image
COPY --from=py-builder /root/.local /root/.local
# Make sure scripts in .local are usable:
ENV PATH=/root/.local/bin:$PATH

RUN mkdir /app/
WORKDIR /app/

COPY ./src/ /app/
ENV TZ=Asia/Shanghai \
    FLASK_APP=server.py

CMD flask run -h 0.0.0 -p 5000