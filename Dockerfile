# Use an official Python runtime as a parent image
FROM python:3.12-slim-trixie
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set the working directory in the container
WORKDIR .

RUN pip install google
RUN pip install protobuf

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

# Copy the rest of the application code
COPY . .

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

ENV PATH="/app/.venv/bin:$PATH"

# Inform Docker that the container listens on the specified network port
EXPOSE 7321

# Run the application using a production WSGI server like Gunicorn
CMD ["uv", "run", "python", "app.py", "--host", "0.0.0.0"]
