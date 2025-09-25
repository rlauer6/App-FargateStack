 FROM debian:trixie
 
 # Install dependencies
 RUN apt-get update && apt-get install \-y apache2 && \
     # Enable necessary apache modules
     a2enmod rewrite && \
     # Clean up
     rm -rf /var/lib/apt/lists/*

 # Copy in custom configs and start script
 COPY apache2.conf /etc/apache2/apache2.conf
 COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
 COPY start-apache /usr/local/bin/start-apache
 RUN chmod +x /usr/local/bin/start-apache
 
 # The command that will run when the container starts
 CMD ["/usr/local/bin/start-apache"]
