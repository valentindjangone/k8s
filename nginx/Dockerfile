FROM nginx:alpine

# Copy custom nginx config
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Expose port (use 80 instead of 3000 to match our configuration)
EXPOSE 80

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]

# To build:
# docker build -f docker-nginx.dockerfile --tag danwahlin/nginx ../

# To run: 
# docker run -d -p 80:6379 --name nginx danwahlin/nginx