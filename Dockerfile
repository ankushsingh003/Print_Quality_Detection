FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies from requirements.txt
# This ensures we have the specific versions requested while optimizing Docker layers
COPY requirements.txt .

# Install torch/torchvision first with CPU-only optimization to keep image size small
RUN pip install --no-cache-dir torch==2.1.2+cpu torchvision==0.16.2+cpu \
    -f https://download.pytorch.org/whl/torch_stable.html

# Install remaining requirements
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY API ./API
COPY MODEL ./MODEL
COPY DATA_PREPROCESSING ./DATA_PREPROCESSING
COPY TRAINING ./TRAINING
COPY WEB_APP ./WEB_APP

ENV PORT=10000
EXPOSE $PORT

# Start the application using uvicorn
CMD ["sh", "-c", "uvicorn API.app:app --host 0.0.0.0 --port $PORT"]
