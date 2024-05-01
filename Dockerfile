FROM python:3.10-slim-buster
WORKDIR /python-docker
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY server.py server.py
CMD exec gunicorn -b 0.0.0.0:8080 -w 1 server:app
# CMD exec python server.py