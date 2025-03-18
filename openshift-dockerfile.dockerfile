# Include Python
FROM python:3.11.1-buster

USER root
RUN mkdir /home/default && \
    useradd default -u 1000 -U -d /home/default && \
    chown -R 1000:1000 /home/default
RUN mkdir /models && chown -R 1000:1000 /models

RUN apt-get update && apt-get upgrade -y
RUN apt-get install vim -y

# RUN pip install runpod==1.6.2 && pip install torch==2.3.1
# RUN pip install faster-whisper==1.0.3 && pip install ctranslate2==4.3.1

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

USER default
WORKDIR /app

RUN mkdir /tmp/hg_cache
ENV HF_HOME="/tmp/hg_cache"

RUN python3 -c 'import faster_whisper; m = faster_whisper.WhisperModel("ivrit-ai/faster-whisper-v2-d4")'

ENV PORT=8000
ENV HOST="0.0.0.0"
ENV SERVE_AS_API="1"


ADD infer.py .

ENV LD_LIBRARY_PATH="/usr/local/lib/python3.11/site-packages/nvidia/cudnn/lib:/usr/local/lib/python3.11/site-packages/nvidia/cublas/lib"

CMD ["/bin/sh", "-c", "python infer.py --rp_serve_api --rp_api_host $HOST --rp_api_port $PORT"]
