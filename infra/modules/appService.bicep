// ── Parameters ───────────────────────────────────────
param name string
param location string
param sku string = 'B2'
param keyVaultName string
param identityId string
param identityClientId string
param appInsightsConnectionString string

// ── App Service Plan ──────────────────────────────────
resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: '${name}-plan'
  location: location
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// ── App Service ───────────────────────────────────────
resource app 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: [
        {
          name: 'AZURE_CLIENT_ID'
          value: identityClientId
        }
            // ── App Insights ────────────────────────────────────
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        // ── Stripe ────────────────────────────────────
        {
          name: 'Stripe__SecretKey'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=Stripe--SecretKey)'
        }
        {
          name: 'Stripe__PublishableKey'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=Stripe--PublishableKey)'
        }
        {
          name: 'Stripe__WebhookSecret'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=Stripe--WebhookSecret)'
        }
        // ── JWT ───────────────────────────────────────
        {
          name: 'JWT__Secret'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=JWT--Secret)'
        }
        {
          name: 'JWT__ValidIssuer'
          value: 'eCommerceAPI'
        }
        {
          name: 'JWT__ValidAudience'
          value: 'eCommerceClient'
        }
        // ── Email ─────────────────────────────────────
        {
          name: 'EmailSettings__SmtpServer'
          value: 'smtp.gmail.com'
        }
        {
          name: 'EmailSettings__SmtpPort'
          value: '587'
        }
        {
          name: 'EmailSettings__SenderName'
          value: 'LuxeLiving'
        }
        {
          name: 'EmailSettings__Username'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EmailSettings--Username)'
        }
        {
          name: 'EmailSettings__Password'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EmailSettings--Password)'
        }
        {
          name: 'EmailSettings__SenderEmail'
          value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=EmailSettings--Username)'
        }
        // ── SQLite ────────────────────────────────────
        {
          name: 'ConnectionStrings__Default'
          value: 'Data Source=/home/data/ecommerce.db'
        }
        // ── Frontend URL ──────────────────────────────
        {
          name: 'FrontendUrl'
          value: 'storage.outputs.primaryEndpoint'
        }
      ]
    }
  }
}

// ── Outputs ───────────────────────────────────────────
output url string = 'https://${app.properties.defaultHostName}'
output id string = app.id
