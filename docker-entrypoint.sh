#!/bin/bash

echo "Starting application with hotreload..."

WEBAPP_DIR="/app/target/agenda-jsf"
TOMCAT_PID=""
CHECKSUM_FILE="/tmp/webapp_checksum.txt"

# Função para rebuild completo (Java, XML)
rebuild_full() {
    echo "🔨 Full rebuild detected (Java/XML changes)..."
    mvn clean package -DskipTests
    if [ $? -eq 0 ]; then
        echo "✅ Build successful! Redeploying..."
        if [ ! -z "$TOMCAT_PID" ]; then
            kill $TOMCAT_PID 2>/dev/null || true
        fi
        pkill -f tomcat7 || true
        sleep 2
        mvn tomcat7:run-war &
        TOMCAT_PID=$!
        echo "🚀 Tomcat started with PID: $TOMCAT_PID"
        # Atualiza checksum após rebuild
        find /app/src/main/webapp -type f -exec md5sum {} \; > "$CHECKSUM_FILE" 2>/dev/null
    else
        echo "❌ Build failed! Check the errors above."
    fi
}

# Função para atualizar apenas XHTML (hot copy)
hotcopy_views() {
    echo "⚡ XHTML/View change detected - Hot copying..."
    if [ -d "$WEBAPP_DIR" ]; then
        # Copia todos os arquivos recursivamente para o webapp em execução
        rsync -a --delete /app/src/main/webapp/ $WEBAPP_DIR/
        echo "✅ Views updated! Refresh your browser (Ctrl+Shift+R)"
    else
        echo "⚠️  Webapp directory not found, doing full rebuild..."
        rebuild_full
    fi
}

# Build inicial
echo "🏗️  Initial build..."
mvn clean package -DskipTests
mvn tomcat7:run-war &
TOMCAT_PID=$!
echo "🚀 Tomcat started with PID: $TOMCAT_PID"

# Cria checksum inicial dos arquivos webapp
find /app/src/main/webapp -type f -exec md5sum {} \; > "$CHECKSUM_FILE" 2>/dev/null

# Monitor usando polling (para compatibilidade com Windows + Docker)
echo "🔍 Starting file monitor (polling mode for Windows compatibility)..."
(
    while true; do
        sleep 3
        # Verifica mudanças nos arquivos webapp
        CURRENT_CHECKSUM=$(find /app/src/main/webapp -type f -exec md5sum {} \; 2>/dev/null)
        OLD_CHECKSUM=$(cat "$CHECKSUM_FILE" 2>/dev/null)
        
        if [ "$CURRENT_CHECKSUM" != "$OLD_CHECKSUM" ]; then
            echo "$CURRENT_CHECKSUM" > "$CHECKSUM_FILE"
            hotcopy_views
        fi
    done
) &

(
    JAVA_CHECKSUM_FILE="/tmp/java_checksum.txt"
    find /app/src/main/java -type f -name "*.java" -exec md5sum {} \; > "$JAVA_CHECKSUM_FILE" 2>/dev/null
    find /app/src/main/resources -type f -name "*.xml" -exec md5sum {} \; >> "$JAVA_CHECKSUM_FILE" 2>/dev/null
    
    while true; do
        sleep 5
        # Verifica mudanças em arquivos Java e XML
        CURRENT_JAVA=$(find /app/src/main/java -type f -name "*.java" -exec md5sum {} \; 2>/dev/null)
        CURRENT_XML=$(find /app/src/main/resources -type f -name "*.xml" -exec md5sum {} \; 2>/dev/null)
        CURRENT_ALL="${CURRENT_JAVA}${CURRENT_XML}"
        OLD_ALL=$(cat "$JAVA_CHECKSUM_FILE" 2>/dev/null)
        
        if [ "$CURRENT_ALL" != "$OLD_ALL" ]; then
            echo "$CURRENT_ALL" > "$JAVA_CHECKSUM_FILE"
            rebuild_full
        fi
    done
) &

# Mantém o script rodando
wait
