#!/bin/bash
# Check and display versions of installed tools

echo "🔍 Vérification des versions :"

echo -n "Git: "; git --version 2>/dev/null || echo "Non installé"
echo -n "PHP: "; php -v 2>/dev/null | head -n 1 || echo "Non installé"
echo -n "Java: "; java -version 2>&1 | head -n 1 || echo "Non installé"
echo -n "Python: "; python3 --version 2>/dev/null || echo "Non installé"

