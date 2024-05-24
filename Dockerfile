# Set up the Python environment for FastAPI
FROM python:3.9
WORKDIR /app

# Copy the FastAPI files
COPY ./backend /app

# Install Python dependencies
RUN pip install --no-cache-dir -r /app/requirements.txt

# Expose the port FastAPI will run on
EXPOSE 8000

# Define the command to run the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
