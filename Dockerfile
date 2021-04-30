FROM smokserwis/build:python3

RUN pip install snakehouse Cython satella nose2

WORKDIR /app
ADD stanag4586 /app/stanag4586
ADD setup.py /app/setup.py
ADD requirements.txt /app/requirements.txt
ADD MANIFEST.in /app/MANIFEST.in

RUN python setup.py bdist_wheel

CMD ["nose2"]
