#!/bin/bash
set -e

echo "📁 Creating project structure for Habbitt Website..."

# Root
mkdir -p habbitt/{apps,jenkins,.github/workflows}
cd habbitt

# Frontend App directories
mkdir -p apps/frontend/{app/{marketing,platform,contact},components/{ui,layout,sections},public,styles}

# Root-level files
touch README.md docker-compose.yml

# Frontend app files
cd apps/frontend
touch package.json tailwind.config.js next.config.mjs Dockerfile
touch .env

# Layout and entry files
mkdir -p app
touch app/layout.tsx app/page.tsx

# Jenkins & GitHub workflows
cd ../../
cat <<'EOF' > jenkins/Jenkinsfile
pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { git 'https://github.com/your-org/habbitt-website.git' }
    }
    stage('Build') {
      steps {
        dir('apps/frontend') {
          sh 'npm ci && npm run build'
        }
      }
    }
    stage('Dockerize') {
      steps {
        sh 'docker build -t habbitt/frontend .'
      }
    }
    stage('Deploy') {
      steps {
        echo 'Deploying locally or to server...'
      }
    }
  }
}
EOF

cat <<'EOF' > .github/workflows/deploy.yml
name: Deploy Habbitt Website

on:
  push:
    branches:
      - main
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repo
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install & Build
        run: |
          cd apps/frontend
          npm ci
          npm run build

      - name: Build Docker Image
        run: docker build -t habbitt/frontend:latest apps/frontend

      - name: Push Docker Image
        run: echo "Will push to local registry or future AWS ECR"
EOF

echo "✅ Habbitt website project structure created successfully!"
