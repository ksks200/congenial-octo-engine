# Define the list of subscriptions and tag names 
$subscriptions = @(
    "Subscription1",
    "Subscription2",
    "Subscription3",
    "Subscription4",
    "Subscription5",
    "Subscription6",
    "Subscription7"
)

# Define the tag names to look for
$tagNames = @("TagName1", "TagName2", "TagName3")

# Function to remove a tag from a resource
function Remove-TagFromResource {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceId,
        [Parameter(Mandatory=$true)]
        [string]$tagName
    )

    try {
        # Get the resource details
        $resource = Get-AzResource -ResourceId $resourceId

        # Ensure the resource has tags and the specified tag exists
        if ($resource.Tags -ne $null -and $resource.Tags.ContainsKey($tagName)) {
            $resource.Tags.Remove($tagName)
            # Update the resource tags by converting the hashtable to a dictionary
            $updatedTags = @{}
            foreach ($key in $resource.Tags.Keys) {
                $updatedTags[$key] = $resource.Tags[$key]
            }
            Set-AzResource -ResourceId $resourceId -Tag $updatedTags -Force
            Write-Output "Removed tag '$tagName' from resource '$resourceId'"
        } else {
            Write-Output "Tag '$tagName' not found on resource '$resourceId'"
        }
    } catch {
        Write-Output "Error removing tag '$tagName' from resource '$resourceId': $_"
    }
}

# Login to Azure if not already logged in
Connect-AzAccount

# Loop through each subscription
foreach ($subscription in $subscriptions) {
    try {
        Set-AzContext -Subscription $subscription
        Write-Output "Switched to subscription: $subscription"

        # Loop through each tag name
        foreach ($tagName in $tagNames) {
            Write-Output "Looking for resources with tag: $tagName in subscription: $subscription"

            # Find resources with the specific tag name
            $resources = Get-AzResource | Where-Object { $_.Tags -ne $null -and $_.Tags.ContainsKey($tagName) }

            # Loop through each resource and remove the tag
            foreach ($resource in $resources) {
                Remove-TagFromResource -resourceId $resource.ResourceId -tagName $tagName
            }
        }
    } catch {
        Write-Output "Error processing subscription '$subscription': $_"
    }
}
