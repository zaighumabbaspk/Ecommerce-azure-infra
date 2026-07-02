// ── Parameters ───────────────────────────────────────
param name string
param location string

// ── Storage Account ───────────────────────────────────
resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storage
  name: 'default'
}



// ── $web container (Angular build output goes here) ───
resource webContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: blobService
  name: '$web'
  properties: {
    publicAccess: 'Blob'
  }
}

// ── Outputs ───────────────────────────────────────────
output id string = storage.id
output name string = storage.name
output primaryEndpoint string = storage.properties.primaryEndpoints.web
