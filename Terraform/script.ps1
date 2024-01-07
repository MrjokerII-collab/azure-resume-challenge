# Get the storage account key
$keyAccounts = (az storage account keys list --resource-group tf_cloud_resume --account-name tfcloudresume1 --output json | ConvertFrom-Json)
$keyaccount1 = $keyAccounts[0].value
# Upload files to Azure Storage Blob
az storage blob upload-batch --account-name tfcloudresume1 --account-key $keyaccount1 --destination '$web' --source "C:\Users\Fred\Documents\IT\Cloudchall\Cloudchallenge-pythonv1\tf-frontend"

