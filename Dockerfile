FROM python:2.7.11

COPY ./BAR.py /usr/local/bin

EXPOSE 8080
CMD ["BAR.py"]
