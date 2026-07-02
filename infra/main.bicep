targetScope = 'resourceGroup'

// ── Parameters ──────────────────────────────────────
@description('Environment name')
@allowed(['dev', 'prod'])
param env string

@description('Azure region for all resources')
param location string = resourceGroup().location

@description('App Service SKU')
param appServiceSku string = 'B2'

// ── Variables ────────────────────────────────────────
var prefix = 'ecommerce-${env}'

// ── Modules ───────────────────────────────────────────

module identity 'modules/managedIdentity.bicep' = {
  name: 'identity'
  params: {
    name: '${prefix}-identity'
    location: location
  }
}

module kv 'modules/keyVault.bicep' = {
  name: 'keyVault'
  params: {
    name: '${prefix}-kv-zai'
    location: location
    appIdentityPrincipalId: identity.outputs.principalId
  }
}

module api 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    name: '${prefix}-api'
    location: location
    sku: appServiceSku
    keyVaultName: kv.outputs.name
    identityId: identity.outputs.id
    identityClientId: identity.outputs.clientId
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
  }
}

module storage 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    name: '${replace(prefix, '-', '')}store'
    location: location
  }
}

module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    prefix: prefix
    location: location
  }
}

// ── Outputs ───────────────────────────────────────────
output apiUrl string = api.outputs.url
output keyVaultName string = kv.outputs.name
