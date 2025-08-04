# Use official n8n image
FROM n8nio/n8n:latest

# Switch to root to set up permissions
USER root

# Create n8n data directory with proper permissions
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n && \
    chmod -R 755 /home/node/.n8n

# Volume will be handled by Railway volumes - removed VOLUME keyword

# Install postgresql client for backups
RUN apk add --no-cache postgresql-client

# Switch back to node user
USER node

# Set working directory
WORKDIR /home/node

# Expose the port (Railway will inject $PORT dynamically)
EXPOSE $PORT

# Set n8n to listen on all interfaces and use Railway's PORT
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=$PORT
ENV N8N_LISTEN_ADDRESS=::
ENV N8N_PROTOCOL=https

# Set fallback port for local development
ENV PORT=5678

# Enable basic auth by default (users should override these)
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_BASIC_AUTH_USER=admin
ENV N8N_BASIC_AUTH_PASSWORD=changeme

# Set execution mode to regular (not queue)
ENV EXECUTIONS_MODE=regular

# Enable metrics for health checks
ENV N8N_METRICS=true

# CRITICAL FIX: Start n8n with explicit 'start' command
ENTRYPOINT ["n8n", "start"]
