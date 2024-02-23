FROM python:3.9

# Install dependencies for building SentencePiece
RUN apt-get update && \
    apt-get install -y protobuf-compiler libprotobuf-dev cmake zlib1g-dev git wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /code
COPY requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

# Copy only the source code after installing the dependencies
COPY . /code

# Upgrade bitsandbytes
RUN pip install --no-cache-dir --force-reinstall --upgrade bitsandbytes

# Install accelerate
RUN pip install accelerate

# Set up a new user named "user" with user ID 1000
RUN useradd -m -u 1000 user

# Switch to the "user" user
USER user

# Set home to the user's home directory
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Set the working directory to the user's home directory
WORKDIR $HOME/app

# Copy the current directory contents into the container at $HOME/app setting the owner to the user
COPY --chown=user . $HOME/app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860"]