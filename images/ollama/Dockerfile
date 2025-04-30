FROM ollama/ollama:0.6.6

# Preload model during image build
RUN ollama run nomic-embed-text:latest || true

# Expose the default port
EXPOSE 11434

# Start Ollama server (this is already the default CMD, can be customized if needed)
CMD ["ollama", "serve"]