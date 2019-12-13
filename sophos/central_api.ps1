########################################################################################################################
# API Documentation: https://developer.sophos.com/getting-started-tenant

$client_id="<client_id>"
$client_secret="<client_secret>"
########################################################################################################################

$api_token = "https://id.sophos.com/api/v2/oauth2/token"
$api_whoami = "https://api.central.sophos.com/whoami/v1"

$req_token = Invoke-WebRequest -Uri $api_token -Method POST -H @{'Content-Type'="application/x-www-form-urlencoded"} -body "grant_type=client_credentials&client_id=${client_id}&client_secret=${client_secret}&scope=token"
$token = $req_token.Content | convertFrom-Json
$jwt_id = $token.access_token

$req_whoami = Invoke-Webrequest -Uri $api_whoami -Method GET -H @{'Authorization'="Bearer $jwt_id"}
$whoami = $req_whoami.Content | convertFrom-Json

$tenant_id = $whoami.id
$data_region = $whoami.apiHosts.dataRegion

# Get endpoints status
$req_endpoints = Invoke-WebRequest -Uri "$data_region/endpoint/v1/endpoints?pageSize=200" -Method GET -H @{'Authorization'="Bearer $jwt_id" ; 'X-Tenant-ID'=$tenant_id} 
$endpoints =  convertFrom-Json $req_endpoints.Content 
$nextkey = $endpoints.pages.nextkey

$next = $true
$counter=0
while($next) {
    for($i=0;$i -lt $endpoints.items.Count;$i++){
        $counter++
        $endpointProtection = "";
        $deviceEncryption = "";
        $interceptX = "";
        $coreAgent = "";

        for($j=0;$j -lt $endpoints.items[$i].assignedProducts.Length; $j++){
            if($endpoints.items[$i].assignedProducts[$j].code -eq "endpointProtection") {
                $endpointProtection = $endpoints.items[$i].assignedProducts[$j].version
            }
            if($endpoints.items[$i].assignedProducts[$j].code -eq "deviceEncryption") {
                $deviceEncryption = $endpoints.items[$i].assignedProducts[$j].version
            }
            if($endpoints.items[$i].assignedProducts[$j].code -eq "interceptX") {
                $interceptX = $endpoints.items[$i].assignedProducts[$j].version
            }
            if($endpoints.items[$i].assignedProducts[$j].code -eq "coreAgent") {
                $coreAgent = $endpoints.items[$i].assignedProducts[$j].version
            }
        
        }

        $hostname = $endpoints.items[$i].hostname
        $health_overall = $endpoints.items[$i].health.overall
        $health_threats = $endpoints.items[$i].health.threats.status
        $last_seen = $endpoints.items[$i].lastSeenAt
        write-host "$counter;$hostname;$endpointProtection;$deviceEncryption;$interceptX;$coreAgent;$health_overall;$health_threats;$last_seen";
    }

    if($nextkey -eq $null) {
        $next = $false
    }
    else {
        $req_endpoints = Invoke-WebRequest -Uri "$data_region/endpoint/v1/endpoints?pageSize=200&pageFromKey=$nextkey" -Method GET -H @{'Authorization'="Bearer $jwt_id" ; 'X-Tenant-ID'=$tenant_id} 
        $endpoints =  convertFrom-Json $req_endpoints.Content 
        $nextkey = $endpoints.pages.nextkey
    }
}
