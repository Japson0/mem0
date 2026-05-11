FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/python:3.12.9

WORKDIR /app

COPY server/tmp /tmp
# Install Poetry

RUN python3 /tmp/install-poetry.py

ENV PATH="/root/.local/bin:$PATH"

# Copy requirements first for better caching
COPY server/requirements.txt .
RUN pip install -r requirements.txt

# Install mem0 in editable mode using Poetry
WORKDIR /app/packages
COPY pyproject.toml .
COPY poetry.lock .
COPY README.md .
COPY mem0 ./mem0
RUN pip install -e .[graph]

# Return to app directory and copy server code
WORKDIR /app
COPY server .

RUN pip install  ./tmp/en_core_web_sm-3.7.1-py3-none-any.whl

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]