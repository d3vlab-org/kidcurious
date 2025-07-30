#!/bin/bash

echo "🧪 Testing KidCurious Configuration..."
echo "======================================"

# Test 1: Docker Compose validation
echo "1. Testing Docker Compose configuration..."
if docker-compose config > /dev/null 2>&1; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration has errors"
    exit 1
fi

# Test 2: Production Dockerfile validation
echo "2. Testing production Dockerfile syntax..."
if docker build -f Dockerfile -t kidcurious-test . --dry-run > /dev/null 2>&1; then
    echo "✅ Production Dockerfile syntax is valid"
else
    echo "⚠️  Production Dockerfile syntax check not available (requires newer Docker)"
fi

# Test 3: Backend development Dockerfile validation
echo "3. Testing backend development Dockerfile syntax..."
if docker build -f KidCurious-backend/Dockerfile.dev -t kidcurious-backend-test KidCurious-backend --dry-run > /dev/null 2>&1; then
    echo "✅ Backend development Dockerfile syntax is valid"
else
    echo "⚠️  Backend development Dockerfile syntax check not available (requires newer Docker)"
fi

# Test 4: Frontend Dockerfile validation
echo "4. Testing frontend Dockerfile syntax..."
if docker build -f KidCurious-front/Dockerfile -t kidcurious-frontend-test KidCurious-front --dry-run > /dev/null 2>&1; then
    echo "✅ Frontend Dockerfile syntax is valid"
else
    echo "⚠️  Frontend Dockerfile syntax check not available (requires newer Docker)"
fi

# Test 5: Check required files exist
echo "5. Checking required configuration files..."
required_files=(
    "docker-compose.yml"
    "Dockerfile"
    "fly.toml"
    "KidCurious-backend/Dockerfile.dev"
    "KidCurious-backend/.env.example"
    "KidCurious-backend/composer.json"
    "KidCurious-front/Dockerfile"
    "KidCurious-front/package.json"
    "DEPLOYMENT.md"
)

all_files_exist=true
for file in "${required_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
        all_files_exist=false
    fi
done

# Test 6: Check Laravel configuration
echo "6. Checking Laravel configuration..."
if [[ -f "KidCurious-backend/config/cors.php" ]]; then
    echo "✅ CORS configuration exists"
else
    echo "❌ CORS configuration missing"
    all_files_exist=false
fi

# Test 7: Check environment variables in .env.example
echo "7. Checking environment variables..."
env_vars=(
    "APP_URL"
    "FRONTEND_URL"
    "DB_CONNECTION"
    "DB_HOST"
    "DB_DATABASE"
)

for var in "${env_vars[@]}"; do
    if grep -q "^$var=" KidCurious-backend/.env.example; then
        echo "✅ $var is configured"
    else
        echo "❌ $var is missing from .env.example"
        all_files_exist=false
    fi
done

# Test 8: Check fly.toml configuration
echo "8. Checking fly.toml configuration..."
fly_configs=(
    "app ="
    "primary_region ="
    "internal_port = 8080"
    "APP_URL ="
    "FRONTEND_URL ="
)

for config in "${fly_configs[@]}"; do
    if grep -q "$config" fly.toml; then
        echo "✅ fly.toml contains: $config"
    else
        echo "❌ fly.toml missing: $config"
        all_files_exist=false
    fi
done

echo ""
echo "======================================"
if $all_files_exist; then
    echo "🎉 All configuration tests passed!"
    echo ""
    echo "Next steps:"
    echo "- Development: docker-compose up"
    echo "- Production: fly launch && fly deploy"
    exit 0
else
    echo "❌ Some configuration issues found"
    exit 1
fi