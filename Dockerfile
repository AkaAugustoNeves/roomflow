FROM maven:3.8.6-openjdk-11

# Install inotify-tools for file watching
RUN apt-get update && apt-get install -y inotify-tools && rm -rf /var/lib/apt/lists/*

# Download and install Tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

ENV TOMCAT_VERSION 9.0.82
RUN set -eux; \
    curl -fsSL "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -o tomcat.tar.gz; \
    tar -xf tomcat.tar.gz --strip-components=1; \
    rm bin/*.bat; \
    rm tomcat.tar.gz*; \
    rm -rf webapps/*

# Create app directory
WORKDIR /app

# Copy Maven files first for better caching
COPY pom.xml .
RUN mvn dependency:go-offline || true

# Copy source code
COPY src ./src

# Expose port
EXPOSE 8080

# Create auto-deploy script with polling (works with Windows volumes)
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "🚀 Starting Room Flow Development Server..."\n\
\n\
# Initial build\n\
echo "📦 Building project..."\n\
mvn clean package -DskipTests\n\
\n\
# Deploy WAR\n\
echo "🚢 Deploying application..."\n\
cp target/ROOT.war $CATALINA_HOME/webapps/\n\
\n\
# Start Tomcat in background\n\
echo "🔥 Starting Tomcat..."\n\
catalina.sh start\n\
\n\
# Follow Tomcat logs in background\n\
tail -f $CATALINA_HOME/logs/catalina.out 2>/dev/null &\n\
\n\
echo "✅ Application started at http://localhost:8080"\n\
echo "👀 Watching for file changes (polling mode)..."\n\
echo "💡 Save any file in src/ to trigger rebuild"\n\
\n\
# Store initial checksums\n\
LAST_HASH=$(find ./src -type f -exec md5sum {} \\; 2>/dev/null | sort | md5sum | awk '"'"'{print $1}'"'"')\n\
\n\
# Watch for changes using polling (works with Windows mounts)\n\
while true; do\n\
    sleep 2\n\
    CURRENT_HASH=$(find ./src -type f -exec md5sum {} \\; 2>/dev/null | sort | md5sum | awk '"'"'{print $1}'"'"')\n\
    \n\
    if [ "$LAST_HASH" != "$CURRENT_HASH" ]; then\n\
        echo ""\n\
        echo "🔄 Changes detected! Rebuilding..."\n\
        mvn clean package -DskipTests\n\
        \n\
        echo "🚢 Redeploying application..."\n\
        rm -rf $CATALINA_HOME/webapps/ROOT*\n\
        cp target/ROOT.war $CATALINA_HOME/webapps/\n\
        \n\
        echo "✅ Application redeployed at $(date +%H:%M:%S)!"\n\
        echo "👀 Watching for file changes..."\n\
        \n\
        LAST_HASH=$CURRENT_HASH\n\
    fi\n\
done\n\
' > /app/auto-deploy.sh && chmod +x /app/auto-deploy.sh

CMD ["/app/auto-deploy.sh"]
