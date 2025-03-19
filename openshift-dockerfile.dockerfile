# Include Python
FROM python:3.11.1-buster

USER root
RUN mkdir /home/default && \
    useradd default -u 1000 -U -d /home/default && \
    chown -R 1000:1000 /home/default
RUN mkdir /models && chown -R 1000:1000 /models
RUN mkdir /app && chown -R 1000:1000 /app

RUN apt-get update && apt-get upgrade -y
RUN apt-get install vim -y

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

USER default
WORKDIR /app

RUN mkdir /app/hg_cache
ENV HF_HOME="/app/hg_cache"

ENV PORT=8000
ENV HOST="0.0.0.0"
ENV SERVE_AS_API="1"
ADD infer.py .

ENV LD_LIBRARY_PATH="/usr/local/lib/python3.11/site-packages/nvidia/cudnn/lib:/usr/local/lib/python3.11/site-packages/nvidia/cublas/lib"

RUN python -c 'import faster_whisper; m = faster_whisper.WhisperModel("systran/faster-whisper-large-v2")'
RUN python -c 'import faster_whisper; m = faster_whisper.WhisperModel("ivrit-ai/faster-whisper-v2-d4")'

CMD ["/bin/sh", "-c", "python infer.py --rp_serve_api --rp_api_host $HOST --rp_api_port $PORT"]
