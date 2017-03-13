function Add-DeepMind ($A, $B) {
    $body = [pscustomobject]@{
        a = $A;
        b = $B
    } | ConvertTo-Json

    # "http://dupsug10.0115633a.svc.dockerapp.io/deepmind/add"
    
    Invoke-WebRequest -Uri "http://dupsug10.0115633a.svc.dockerapp.io/deepmind/add" -ContentType "application/json" -Body $body -Method Post |
        select -ExpandProperty Content

    # implement the same thing as in Postman
}

Export-ModuleMember -Function "Add-DeepMind"