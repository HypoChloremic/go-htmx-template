#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if required tools are installed
echo -n "Do you have Go and Air installed and configured in your PATH? (yes/no): "
read answer

if [ "${answer,,}" != "yes" ]; then
    echo -e "${RED}Please install Go and Air before continuing.${NC}"
    exit 1
fi

# Create project structure
echo -e "${GREEN}Creating project structure...${NC}"
mkdir -p cmd views

# Create main.go
cat > cmd/main.go << 'EOL'
package main

import (
	"html/template"
	"io"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type Templates struct {
	templates *template.Template
}

func (t *Templates) Render(w io.Writer, name string, data interface{}, c echo.Context) error {
	return t.templates.ExecuteTemplate(w, name, data)
}

func NewTemplates() *Templates {
	return &Templates{
		templates: template.Must(template.ParseGlob("views/*.html")),
	}
}

func main() {
	e := echo.New()
	e.Use(middleware.Logger())
	
	t := NewTemplates()
	e.Renderer = t

	e.GET("/", func(c echo.Context) error {
		return c.Render(http.StatusOK, "index", nil)
	})
	
	e.Logger.Fatal(e.Start(":8080"))
}
EOL

# Create a sample index.html template
cat > views/index.html << 'EOL'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Go + HTMX App</title>
    <script src="https://unpkg.com/htmx.org@1.9.10"></script>
</head>
<body>
    <h1>Welcome to Go + HTMX App</h1>
</body>
</html>
EOL

# Initialize go module
echo -e "${GREEN}Initializing Go module...${NC}"
go mod init app

# Install dependencies
echo -e "${GREEN}Installing dependencies...${NC}"
go get github.com/labstack/echo/v4
go get github.com/labstack/echo/v4/middleware

# Create .air.toml for hot reload
cat > .air.toml << 'EOL'
root = "."
tmp_dir = "tmp"

[build]
  cmd = "go build -o ./tmp/main cmd/main.go"
  bin = "tmp/main"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor"]
  include_ext = ["go", "tpl", "tmpl", "html"]
  exclude_regex = ["_test\\.go"]
EOL

echo -e "${GREEN}Setup completed successfully!${NC}"
echo "To run the application:"
echo "1. Run 'air' for development with hot reload"
echo "2. Or 'go run cmd/main.go' for regular execution"
