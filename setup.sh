#!/bin/bash

# Go PostgreSQL API Template Setup Script
# This script helps customize the template for your specific project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Welcome to Go PostgreSQL API Template Setup${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Function to prompt for input with validation
prompt_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    local value=""
    
    while [[ -z "$value" ]]; do
        echo -ne "${YELLOW}${prompt}"
        if [[ -n "$default" ]]; then
            echo -ne " [${default}]"
        fi
        echo -ne ": ${NC}"
        read -r value
        
        if [[ -z "$value" && -n "$default" ]]; then
            value="$default"
        fi
        
        if [[ -z "$value" ]]; then
            echo -e "${RED}This field is required. Please enter a value.${NC}"
        fi
    done
    
    # Store in global variable
    declare -g "$var_name"="$value"
}

# Collect user input
echo -e "${BLUE}Please provide the following information:${NC}"
echo ""

prompt_input "Go module name (e.g., github.com/yourusername/your-api)" "" "MODULE_NAME"
prompt_input "Project display name (e.g., My Product API)" "" "PROJECT_NAME"  
prompt_input "Service name for logging (e.g., my-product-api)" "" "SERVICE_NAME"
prompt_input "API title for Swagger (e.g., Product Management API)" "" "API_TITLE"
prompt_input "API description (e.g., API for managing product inventory)" "" "API_DESCRIPTION"
prompt_input "Database name" "products_db" "DB_NAME"

echo ""
echo -e "${BLUE}Summary of your configuration:${NC}"
echo -e "${GREEN}Module Name:${NC} $MODULE_NAME"
echo -e "${GREEN}Project Name:${NC} $PROJECT_NAME"
echo -e "${GREEN}Service Name:${NC} $SERVICE_NAME"
echo -e "${GREEN}API Title:${NC} $API_TITLE"
echo -e "${GREEN}API Description:${NC} $API_DESCRIPTION"
echo -e "${GREEN}Database Name:${NC} $DB_NAME"
echo ""

# Confirm before proceeding
echo -ne "${YELLOW}Do you want to proceed with this configuration? (y/N): ${NC}"
read -r confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Setup cancelled.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🔧 Applying configuration...${NC}"

# Backup files first
echo -e "${YELLOW}Creating backup directory...${NC}"
mkdir -p .template-backup
cp -r . .template-backup/ 2>/dev/null || true

# Function to replace placeholders in files
replace_in_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        echo -e "  📝 Updating $file"
        # Use temporary file for cross-platform compatibility
        sed "s|{{MODULE_NAME}}|$MODULE_NAME|g; s|{{PROJECT_NAME}}|$PROJECT_NAME|g; s|{{SERVICE_NAME}}|$SERVICE_NAME|g; s|{{API_TITLE}}|$API_TITLE|g; s|{{API_DESCRIPTION}}|$API_DESCRIPTION|g; s|{{DB_NAME}}|$DB_NAME|g" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
}

# List of files to update
files_to_update=(
    "go.mod"
    "cmd/api/main.go"
    "internal/config/config.go"
    "internal/handlers/product.go"
    "internal/repository/product.go"
    "internal/router/router.go"
    ".devcontainer/devcontainer.json"
    ".devcontainer/docker-compose.yml"
    ".devcontainer/init-test-db.sql"
    ".vscode/launch.json"
    "docker-compose.yml"
)

# Replace placeholders in each file
echo -e "${YELLOW}Updating template files:${NC}"
for file in "${files_to_update[@]}"; do
    replace_in_file "$file"
done

# Initialize go module
echo -e "${YELLOW}Initializing Go module...${NC}"
rm -f go.mod go.sum
go mod init "$MODULE_NAME"
go mod tidy

# Generate Swagger documentation
echo -e "${YELLOW}Generating Swagger documentation...${NC}"
if command -v swag &> /dev/null; then
    swag init -g cmd/api/main.go
    echo -e "${GREEN}✓ Swagger documentation generated${NC}"
else
    echo -e "${YELLOW}⚠ swag not found. Install it with: go install github.com/swaggo/swag/cmd/swag@latest${NC}"
    echo -e "${YELLOW}  Then run: swag init -g cmd/api/main.go${NC}"
fi

# Clean up
echo -e "${YELLOW}Cleaning up...${NC}"
rm -f setup.sh  # Remove this setup script

echo ""
echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. ${GREEN}Open in VS Code:${NC} code ."
echo -e "2. ${GREEN}Reopen in Dev Container${NC} when prompted"
echo -e "3. ${GREEN}Press F5${NC} to start debugging"
echo -e "4. ${GREEN}Visit${NC} http://localhost:8080/swagger/index.html for API docs"
echo ""
echo -e "${BLUE}Your API will be available at:${NC}"
echo -e "  • Health check: ${GREEN}http://localhost:8080/api/v1/health${NC}"
echo -e "  • Products API: ${GREEN}http://localhost:8080/api/v1/products${NC}"
echo -e "  • Swagger docs: ${GREEN}http://localhost:8080/swagger/index.html${NC}"
echo ""
echo -e "${BLUE}Happy coding! 🚀${NC}"