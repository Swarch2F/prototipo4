#!/usr/bin/env pwsh
# Script de Testing para GRADEX Proxy Nginx en Windows
# =========================================================

Write-Host "Testing GRADEX Nginx Proxy..." -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Función para testing
function Test-Endpoint {
    param(
        [string]$Url,
        [string]$Description,
        [int]$ExpectedStatus = 200
    )
    
    Write-Host "Testing $Description... " -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 10 -ErrorAction SilentlyContinue
        $status = $response.StatusCode
        
        if ($status -eq $ExpectedStatus) {
            Write-Host "OK ($status)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL ($status, expected $ExpectedStatus)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        $errorStatus = $_.Exception.Response.StatusCode.value__
        if ($errorStatus -eq $ExpectedStatus) {
            Write-Host "OK ($errorStatus)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL (Error: $($_.Exception.Message))" -ForegroundColor Red
            return $false
        }
    }
}

# Función para testing de headers de seguridad
function Test-SecurityHeaders {
    param(
        [string]$Url
    )
    
    Write-Host "Testing Security Headers... " -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 10
        $headers = $response.Headers
        
        $securityHeaders = @(
            "X-Frame-Options",
            "X-Content-Type-Options", 
            "X-XSS-Protection",
            "Content-Security-Policy"
        )
        
        $foundHeaders = 0
        foreach ($header in $securityHeaders) {
            if ($headers.ContainsKey($header)) {
                $foundHeaders++
            }
        }
        
        if ($foundHeaders -ge 3) {
            Write-Host "OK ($foundHeaders/4 headers found)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "FAIL ($foundHeaders/4 headers found)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "FAIL (Error: $($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

# Esperar a que los servicios estén listos
Write-Host "Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Variables de testing
$baseUrl = "http://localhost"
$results = @()

Write-Host ""
Write-Host "Testing Security and Connectivity:" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow

# Test 1: Nginx Health Check
$results += Test-Endpoint "$baseUrl/nginx-health" "Nginx Health Check"

# Test 2: Frontend Access
$results += Test-Endpoint "$baseUrl/" "Frontend Access"

# Test 3: GraphQL API Access  
$results += Test-Endpoint "$baseUrl/graphql" "GraphQL API Access" 405

# Test 4: Security Headers
$results += Test-SecurityHeaders "$baseUrl/"

Write-Host ""
Write-Host "Testing Security Features:" -ForegroundColor Yellow
Write-Host "==============================" -ForegroundColor Yellow

# Test 5: Blocked file types (.env)
$results += Test-Endpoint "$baseUrl/.env" "Block .env files" 403

# Test 6: Blocked file types (.sql)
$results += Test-Endpoint "$baseUrl/backup.sql" "Block .sql files" 403

# Test 7: Blocked hidden files
$results += Test-Endpoint "$baseUrl/.hidden" "Block hidden files" 403

Write-Host ""
Write-Host "Testing Results Summary:" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

$passedTests = ($results | Where-Object { $_ -eq $true }).Count
$totalTests = $results.Count
$percentage = [math]::Round(($passedTests / $totalTests) * 100, 1)

if ($percentage -ge 80) {
    Write-Host "PASSED: $passedTests/$totalTests tests ($percentage percent)" -ForegroundColor Green
    Write-Host "Proxy is working correctly!" -ForegroundColor Green
} elseif ($percentage -ge 60) {
    Write-Host "PARTIAL: $passedTests/$totalTests tests ($percentage percent)" -ForegroundColor Yellow
    Write-Host "Some issues detected, but basic functionality works" -ForegroundColor Yellow
} else {
    Write-Host "FAILED: $passedTests/$totalTests tests ($percentage percent)" -ForegroundColor Red
    Write-Host "Significant issues detected!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "===============" -ForegroundColor Cyan
Write-Host "Frontend:    $baseUrl/" -ForegroundColor White
Write-Host "GraphQL:     $baseUrl/graphql" -ForegroundColor White
Write-Host "Health:      $baseUrl/nginx-health" -ForegroundColor White 