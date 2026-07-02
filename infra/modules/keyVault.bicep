// ── Parameters ───────────────────────────────────────
param name string
param location string
param appIdentityPrincipalId string

// ── Resource ──────────────────────────────────────────
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true
  }
}

// ── Grant App Service identity permission to read secrets ──
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, appIdentityPrincipalId, 'KeyVaultSecretsUser')
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '4633458b-17de-408a-b874-0445c86b69e6'
    )
    principalId: appIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ── Outputs ───────────────────────────────────────────
output name string = kv.name
output uri string = kv.properties.vaultUri
